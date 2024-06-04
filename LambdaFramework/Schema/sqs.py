sqs = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "messageId": {"type": "string"},
                        "receiptHandle": {"type": "string"},
                        "body": {"type": "string"},
                        "attributes": {"type": "object"},
                        "messageAttributes": {"type": "object"},
                        "md5OfBody": {"type": "string"},
                        "eventSource": {"type": "string"},
                        "eventSourceARN": {"type": "string"},
                        "awsRegion": {"type": "string"}
                    },
                    "required": [
                        "messageId",
                        "receiptHandle",
                        "body",
                        "attributes",
                        "messageAttributes",
                        "md5OfBody",
                        "eventSource",
                        "eventSourceARN",
                        "awsRegion"
                    ]
                }
            ]
        }
    },
    "required": ["Records"]
}
