import base64
import gzip
import json
import jsonpath_ng
import jsonschema
from .apigateway import apigateway_autholizer
from .apigateway import apigateway_request_autholizer
from .apigateway import apigateway_http
from .apigateway import apigateway_rest
from .apigateway import apigateway_proxy
from .cloudtrail import cloudtrail
from .cloudwatch_logs import cloudwatch_logs
from .cloudformation_custom_resource import cloudformation_custom_resource
from .cloudfront import cloudfront
from .codecommit import codecommit
from .codepipeline import codepipeline
from .cognito import cognito
from .connect import connect
from .documentdb import documentdb
from .dynamodb import dynamodb
from .elb import elb
from .eventbridge import eventbridge_ec2
from .eventbridge import eventbridge_rds
from .eventbridge import eventbridge
from .iot_events import iot_events
from .apache_kafka import apache_kafka
from .apache_kafka import apache_kafka_msk
from .kinesis import kinesis_firehose
from .kinesis import kinesis_stream
from .mq import active_mq
from .mq import rabbit_mq
from .s3 import s3
from .s3_batch import s3_batch
from .ses import ses
from .sns import sns
from .sqs import sqs


validates = [
    {
        "trigger": {
            "service": "aws:apigateway",
            "operation": "request_autholizer",
        },
        "validate": apigateway_request_autholizer
    },
    {
        "trigger": {
            "service": "aws:apigateway",
            "operation": "autholizer",
            "arn": "$.methodArn"
        },
        "validate": apigateway_autholizer,
    },
    {
        "trigger": {
            "service": "aws:apigateway",
            "operation": "proxy",
        },
        "validate": apigateway_proxy,
        "base64_decoded": ["$.body"],
    },
    {
        "trigger": {
            "service": "aws:apigateway",
            "operation": "rest",
        },
        "validate": apigateway_rest,
        "base64_decoded": ["$.body"],
    },
    {
        "trigger": {
            "service": "aws:cloudtrail",
        },
        "validate": cloudtrail
    },
    {
        "trigger": {
            "service": "aws:logs"
        },
        "validate": cloudwatch_logs,
        "decompress": ["$.awslogs.data"],
        "parse_json": ["$.awslogs.data.logEvents[*].message"]
    },
    {
        "trigger": {
            "service": "aws:cloudformation",
            "operation": "customresource"
        },
        "validate": cloudformation_custom_resource
    },
    {
        "trigger": {
            "service": "aws:cloudfront",
        },
        "validate": cloudfront
    },
    {
        "trigger": {
            "service": "aws:codecommit",
            "arn": "$.Records[0].eventSourceARN"
        },
        "validate": codecommit
    },
    {
        "trigger": {
            "service": "aws:codepipeline",
        },
        "validate": codepipeline
    },
    {
        "trigger": {
            "service": "aws:cognito",
            "operation": "$.eventType"
        },
        "validate": cognito
    },
    {
        "trigger": {
            "service": "aws:connect",
            "arn": "$.Details.ContactData.InstanceARN"
        },
        "validate": connect
    },
    {
        "trigger": {
            "service": "$.eventSource",
            "arn": "$.eventSourceArn"
        },
        "validate": documentdb
    },
    {
        "trigger": {
            "service": "aws:dynamodb",
            "arn": "$.eventSourceARN"
        },
        "validate": dynamodb
    },
    {
        "trigger": {
            "service": "aws:ec2",
            "type": "eventbridge",
            "arn": "$.resources[0]",
            "detail-type": "$.detail-type",
            "instance-id": "$.detail.instance-id",
        },
        "validate": eventbridge_ec2
    },
    {
        "trigger": {
            "service": "aws:rds",
            "type": "eventbridge",
            "arn": "$.detail.SourceArn",
            "detail-type": "$.detail-type"
        },
        "validate": eventbridge_rds
    },
    {
        "trigger": {
            "service": "$.source",
            "type": "eventbridge",
            "arn": "$.resources[0]",
            "detail-type": "$.detail-type"
        },
        "validate": eventbridge
    },
    {
        "trigger": {
            "service": "aws:elb",
            "arn": "$.requestContext.elb.targetGroupArn"
        },
        "base64_decoded": ["$.body"],
        "validate": elb
    },
    {
        "trigger": {
            "service": "aws:iot",
        },
        "validate": iot_events
    },
    {
        "trigger": {
            "service": "aws:kafka",
            "arn": "$.eventSourceArn",
            "servers": "$.bootstrapServers",
        },
        "validate": apache_kafka_msk
    },
    {
        "trigger": {
            "service": "apache:kafka",
            "servers": "$.bootstrapServers",
        },
        "validate": apache_kafka
    },
    {
        "trigger": {
            "service": "aws:kinesis:firehose"
        },
        "validate": kinesis_firehose
    },
    {
        "trigger": {
            "service": "aws:kinesis",
            "arn": "$.Records[0].eventSourceARN"
        },
        "validate": kinesis_stream
    },
    {
        "trigger": {
            "service": "$.eventSource",
            "arn": "$.eventSourceArn"
        },
        "validate": active_mq
    },
    {
        "trigger": {
            "service": "$.eventSource",
            "arn": "$.eventSourceArn"
        },
        "base64_decoded": ["$.rmqMessagesByQueue.*[*].data"],
        "validate": rabbit_mq
    },
    {
        "trigger": {
            "service": "aws:s3",
            "arn": "$.Records[0].s3.bucket.arn",
            "operation": "$.Records[0].eventName",
        },
        "validate": s3
    },
    {
        "trigger": {
            "service": "aws:s3",
            "arn": "$.tasks[0].s3BucketArn",
            "operation": "batch"
        },
        "validate": s3_batch
    },
    {
        "trigger": {
            "service": "aws:ses",
        },
        "validate": ses
    },
    {
        "trigger": {
            "service": "$.Records[0].EventSource",
            "arn": "$.Records[0].EventSubscriptionArn"
        },
        "validate": sns
    },
    {
        "trigger": {
            "service": "$.Records[0].eventSource",
            "arn": "$.Records[0].eventSourceARN"
        },
        "validate": sqs
    },
]


def validator(event: dict) -> bool:
    def b64decode(orig, data, field):
        return b64dec(orig)

    def decompress_gzip(orig, data, field):
        return gzip_decomp(orig)

    def parse_json(orig, data, field):
        return json_load(orig)

    for val in validates:
        try:
            ret = jsonschema.validate(event, val["validate"])
            trigger = val["trigger"]
            for k, v in trigger.items():
                if v[0:2] == "$.":
                    mm = jsonpath_ng.parse(v).find(event)
                    trigger[k] = [m.value for m in mm][0]
            event["trigger"] = trigger
            for v in val.get("base64_decoded", []):
                jsonpath_ng.parse(v).update(event, b64decode)
            for v in val.get("decompress", []):
                jsonpath_ng.parse(v).update(event, decompress_gzip)
            for v in val.get("parse_json", []):
                jsonpath_ng.parse(v).update(event, parse_json)
            return True
        except jsonschema.ValidationError as e:
            continue
    return False


def b64dec(encoded: str) -> str:
    try:
        decoded = base64.b64decode(encoded).decode("utf-8")
        decoded = json_load(decoded)
    except Exception as e:
        return encoded
    return decoded


def gzip_decomp(comp: str) -> str | dict:
    decomp = gzip.decompress(base64.b64decode(comp))
    return json_load(decomp)


def json_load(json_string: str) -> dict:
    try:
        return json.loads(json_string)
    except json.decoder.JSONDecodeError as e:
        return json_string

