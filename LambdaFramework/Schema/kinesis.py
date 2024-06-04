kinesis_firehose = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "invocationId": {"type": "string"},
        "deliveryStreamArn": {"type": "string"},
        "region": {"type": "string"},
        "records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "data": {"type": "string"},
                        "recordId": {"type": "string"},
                        "approximateArrivalTimestamp": {"type": "integer"},
                        "kinesisRecordMetadata": {
                            "type": "object",
                            "properties": {
                                "shardId": {
                                    "type": "string"
                                },
                                "partitionKey": {
                                    "type": "string"
                                },
                                "approximateArrivalTimestamp": {
                                    "type": "string"
                                },
                                "sequenceNumber": {
                                    "type": "string"
                                },
                                "subsequenceNumber": {
                                    "type": "string"
                                }
                            },
                            "required": [
                                "shardId",
                                "partitionKey",
                                "approximateArrivalTimestamp",
                                "sequenceNumber",
                                "subsequenceNumber"
                            ]
                        }
                    },
                    "required": [
                        "data",
                        "recordId",
                        "approximateArrivalTimestamp",
                        "kinesisRecordMetadata"
                    ]
                },
                {
                    "type": "object",
                    "properties": {
                        "data": {"type": "string"},
                        "recordId": {"type": "string"},
                        "approximateArrivalTimestamp": {"type": "integer"},
                        "kinesisRecordMetadata": {"type": "object"}
                    },
                    "required": [
                        "data", "recordId",
                        "approximateArrivalTimestamp",
                        "kinesisRecordMetadata"
                    ]
                }
            ]
        }
    },
    "required": [
        "invocationId", "deliveryStreamArn", "region", "records"
    ]
}

kinesis_stream = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "kinesis": {"type": "object"},
                        "eventSource": {"type": "string"},
                        "eventVersion": {"type": "string"},
                        "eventID": {"type": "string"},
                        "eventName": {"type": "string"},
                        "invokeIdentityArn": {"type": "string"},
                        "awsRegion": {"type": "string"},
                        "eventSourceARN": {"type": "string"}
                    },
                    "required": [
                        "kinesis",
                        "eventSource",
                        "eventVersion",
                        "eventID",
                        "eventName",
                        "invokeIdentityArn",
                        "awsRegion",
                        "eventSourceARN"
                    ]
                }
            ]
        }
    },
    "required": ["Records"]
}
