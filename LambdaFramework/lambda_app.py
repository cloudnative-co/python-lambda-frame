import awslambdaric
import boto3
import botocore
import base64
import json
import re
import os
import sys
import time
import traceback
from .Schema import validator
from .slack_exception import SlackException
from .lambda_log import LambdaLog


class LambdaApp(object):
    """
    @brief  LambdaのExceptionとリトライ、ロギング処理
    """

    __context: awslambdaric.lambda_context.LambdaContext
    retry_count: int = 0
    function_arn: str = ""

    def __init__(self):
        self.__kms = boto3.client(
            'kms', os.environ.get("AWS_REGION", "ap-northeast-1"))
        key_bool = ["AWS_SAM_LOCAL"]
        key_int = [
            "maximum_retry", "sleep_radix", "SHLVL",
            "AWS_LAMBDA_FUNCTION_TIMEOUT", "AWS_LAMBDA_FUNCTION_MEMORY_SIZE"
        ]
        for k, v in os.environ.items():
            v = self.kms_decrypted(v)
            if k in key_bool:
                v = bool(v)
            if k in key_int:
                v = int(v)
            setattr(self, k.lower(), v)
        self.__lambda_client = boto3.client('lambda', self.aws_region)
        self.aws_sam_local = False if "AWS_SAM_LOCAL" not in os.environ\
            else True

    def to_dict(self):
        ret = dict()
        m = vars(self)
        return dict(filter(lambda i: not i[0].startswith("_"), m.items()))

    def __repr__(self):
        return json.dumps(self.to_dict(), ensure_ascii=False)

    def __str__(self):
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=4)

    def __first_call(
        self,
        event: dict,
        context: awslambdaric.lambda_context.LambdaContext
    ):
        validator(event)
        self.event = event
        self.retry_count = event.get("retry_count", 0)
        self.__context = context
        self.aws_request_id = context.aws_request_id
        self.function_arn = context.invoked_function_arn

    def handler(self, f):
        """
        @brief      Lambdaハンドラーとして用いるMain関数に付けるデコレーター
        """
        self.__handler = f
        def _wrapper(*args, **keywords):
            self.__first_call(*args, **keywords)
            return self.__main(*args, **keywords)
        return _wrapper

    def disabler(self, f):
        self.__handler = f
        def _wrapper(*args, **keywords):
            self.__first_call(*args, **keywords)
            return self.__disable(*args, **keywords)
        return _wrapper

    def __disable(
        self,
        event: dict,
        context: awslambdaric.lambda_context.LambdaContext
    ):
        self.info("ログ受信")
        try:
            if event.get("trigger", {}).get("service", None) != "aws:logs":
                return self.__handler(event, context)
            log_events = event["awslogs"]["data"]["logEvents"]
            for log in log_events:
                lambda_log = LambdaLog(log, self.aws_region, self.aws_sam_local)
                lambda_log.notify()
                flag = lambda_log.stop()
                if flag:
                    self.inf("Lambda呼び出しイベントを停止しました")
                else:
                    self.error(
                        log = "Lambda呼び出しイベントの停止処理に失敗しました"
                    )
            return self.__handler(event, context)
        except Exception as e:
            self.error(e, log="Lambda呼び出しイベントの停止処理に失敗しました")

    def __main(
        self,
        event: dict,
        context: awslambdaric.lambda_context.LambdaContext
    ):
        if self.retry_count > 0:
            retry = event.get("retry_count")
            self.info(f"リトライ {retry} 回目 起動")
        elif "reclusive" in event:
            self.info("再帰呼び出し")
        else:
            self.info("イベント受信")
        try:
            return self.__handler(event, context)
        except Exception as e:
            self.__exception(e)

    def info(self, log: dict | str) -> dict:
        return self.log(log)

    def debug(self, log: dict | str) -> dict:
        if isinstance(log, str):
            return self.log(log, "debug")
        if isinstance(log, dict):
            log["level"] = "debug"
            return self.log(log)

    def error(self, e: Exception = None, log: dict | str = None) -> dict:
        if log is not None:
            if isinstance(log, str):
                log = {"level": "error", "type": "lambda", "message": log}
            elif not isinstance(log, dict):
                log = dict()
        else:
            log = {"level": "error", "type": "lambda"}
        if e is not None:
            log = self.__parse_exception(log, e)
        return self.log(log)

    def critical(self, e: Exception, log: dict | str = None) -> dict:
        if log is not None:
            if isinstance(log, str):
                log = {"level": "critical", "type": "lambda", "message": log}
            elif not isinstance(log, dict):
                log = dict()
        else:
            log = {"level": "critical", "type": "lambda"}

        log = self.__parse_exception(log, e)
        return self.log(log)

    def __parse_exception(self, log: dict, e: Exception):
        log["exception"] = str(e)
        if isinstance(e, SlackException):
            log["slack_error_code"] = e.error_code
        if isinstance(e, botocore.exceptions.ClientError):
            log["aws_error_code"] = e.response['Error']['Code']
            log["aws_error_message"] = e.response['Error']['Message']
            log["aws_operation_name"] = e.operation_name
        log["trac"] = self.__trace(e)
        return log

    def log(self, log: dict | str, level = "info") -> dict:
        if isinstance(log, str) or isinstance(log, list):
            log = {"level": level, "type": "lambda", "message": log}
        log["level"] = "info" if "level" not in log else log["level"]
        log["type"] = "lambda" if "type" not in log else log["type"]
        log["request-id"] = self.aws_request_id
        log["function-name"] = self.aws_lambda_function_name
        log["function-arn"] = self.function_arn
        log["event"] = self.event
        if self.aws_sam_local:
            print(json.dumps(log, ensure_ascii=False, indent=4))
        elif log["level"] != "debug":
            print(json.dumps(log, ensure_ascii=False))
        return log

    def reclusive(self):
        try:
            self.event["reclusive"] = True
            if self.aws_sam_local:
                return self.__main(self.event, self.__context)
            else:
                self.__lambda_client.invoke(
                    FunctionName=self.aws_lambda_function_name,
                    InvocationType='Event',
                    Payload=json.dumps(self.event)
                )
        except Exception as e:
            raise e

    def __invoke(self):
        """
        @brief      Lambdaの再帰処理
        """
        try:
            self.info({"message": "Re-Invoke", "event": self.event})
            if self.aws_sam_local:
                return self.__main(self.event, self.__context)
            else:
                return self.__lambda_client.invoke(
                    FunctionName=self.aws_lambda_function_name,
                    InvocationType='Event',
                    Payload=json.dumps(self.event)
                )
        except Exception as e:
            raise e

    def __exception(self, e):
        self.error(e)
        if self.retry_count < self.maximum_retry:
            # Exception retry
            self.retry_count = self.retry_count + 1
            self.event["retry_count"] = self.retry_count
            sec = self.sleep_radix * self.retry_count
            self.debug({"message": f"{sec}sec sleep in"})
            time.sleep(self.sleep_radix * self.retry_count)
            self.debug({"message": f"{sec}sec sleep out"})
            try:
                return self.__invoke()
            except Exception as e:
                return self.critical(e)
        else:
            # Critical
            return self.critical(e)

    def __trace(self, e):
        """
        @brief      Tracebackを用いてExceptionから発生元を辿る
        """
        info = sys.exc_info()
        tbinfo = traceback.format_tb(info[2])
        exception_name = str(info[1])
        result = {}
        result["msg"] = exception_name
        result["trace"] = []
        for info in tbinfo:
            message = info.split("\n")
            temp = message[0].split(", ")
            del message[0]
            places = {
                "file": temp[0].replace("  File", ""),
                "line": temp[1].replace("line ", ""),
                "func": temp[2].replace("in ", ""),
                "trac": message
            }
            result["trace"].append(places)
        return result

    def kms_decrypted(self, encrypted, default=None):
        try:
            blob = base64.b64decode(encrypted)
            decrypted = self.__kms.decrypt(CiphertextBlob=blob)['Plaintext']
            return decrypted.decode('utf-8')
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == "InvalidCiphertextException":
                return encrypted
            raise e
        except base64.binascii.Error as e:
            return encrypted
        except ValueError as e:
            return encrypted
        except Exception as e:
            return default

