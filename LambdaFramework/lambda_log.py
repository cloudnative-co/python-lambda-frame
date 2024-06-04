import boto3
import botocore.exceptions
import json
import re
import urllib.error
import urllib.request
from .slack_message import SlackErrorMessage
from .slack_exception import SlackException


class LambdaLog(object):

    def __init__(
        self, log: dict, region: str = "ap-noetheast-1", is_debug: bool = False
    ):
        self.__is_debug = is_debug
        self.__region = region
        self.__message = log.get("message", dict())
        for name, value in self.__message.items():
            key = f"__{name}"
            key = re.sub(r"-", "_", key)
            setattr(self, key, value)

        self.__trigger = self.event.get("trigger", {})
        for name, value in self.__trigger.items():
            key = f"__trigger_{name}"
            key = re.sub(r"-", "_", key)
            setattr(self, key, value)

    def __getattr__(self, name):
        if name[0:2] == "__":
            return None
        key = f"__{name}"
        if not hasattr(self, key):
            return None
        return getattr(self, key)

    def notify(self, message: str = None):
        log = None
        if message is None:
            msg = SlackErrorMessage(self.__message)
            blocks = msg.to_dict()
            text = None
            log = {
                "level": "info", "type": "slack", "message": msg.to_dict()
            }
        else:
            text = message
            blocks = None
            log = {
                "level": "info", "type": "slack", "message": message
            }
        if self.__is_debug:
            print(json.dumps(log, ensure_ascii=False, indent=4))
        else:
            print(json.dumps(log, ensure_ascii=False))
        return self.post_slack(blocks=blocks, text=text)

    def post_slack(self, blocks: dict=None, text: str=None):
        args = locals()
        channel = "C05PXQGSJJ"
        token = "xoxb-321254953874-6958253998913-T4jHowTfhJGXxxpOa7CYSaMz"
        url = "https://slack.com/api/chat.postMessage"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}"
        }
        data = {
            "channel": channel,
            "blocks": blocks,
            "text": text
        }

        req = urllib.request.Request(url, json.dumps(data).encode(), headers)
        with urllib.request.urlopen(req) as res:
            status = res.getcode()
            body = json.loads(res.read().decode("utf-8"))
            slack_status = body.get("ok", False)
            if not slack_status:
                slack_err = body.get("error", False)
                raise SlackException(slack_err)
            return True

    def stop(self) -> bool:
        """
        @brief      Triggerの停止処理
        """
        if self.level != "critical":
            return True
        stop_method_name = self.trigger_service.replace("aws.", "stop_")
        if not hasattr(self, stop_method_name):
            return False
        stop_method = getattr(self, stop_method_name)
        if stop_method is None:
            return False
        return stop_method()

    def stop_events(self) -> bool:
        """
        @brief      EventBridge Rule無効化処理
        """
        if self.trigger_arn is None:
            return False
        try:
            m = re.search(r"^arn:aws:(.+?):(.+?):(.+?):.+", self.trigger_arn)
            if not m:
                return False
            service = m.group(1)
            region = m.group(2)
            client = boto3.client(service, region)
            name = self.trigger_arn.split("/")[-1]
            response = client.disable_rule(Name=name)
            return True
        except Exception as e:
            raise e

    def stop_scheduler(self) -> bool:
        """
        @brief      EventBridge Scheduler無効化処理
        """
        if self.trigger_arn is None:
            return False
        try:
            m = re.search(r"^arn:aws:(.+?):(.+?):(.+?):.+", self.trigger_arn)
            if not m:
                return False
            service = m.group(1)
            region = m.group(2)
            client = boto3.client(service, region)
            name = self.trigger_arn.split("/")[-1]
            response = client.get_schedule(Name=name)
            args = dict()
            keys = [
                "FlexibleTimeWindow", "Name",
                "ScheduleExpression", "Target"
            ]
            for key in keys:
                value = response.get(key, None)
                if value is None:
                    return False
                args[key] = value
            args["State"] = "DISABLED"
            response = client.update_schedule(**args)
            return True
        except Exception as e:
            raise e
