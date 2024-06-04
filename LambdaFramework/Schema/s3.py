s3 = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "eventVersion": {"type": "string"},
                        "eventSource": {"type": "string"},
                        "awsRegion": {"type": "string"},
                        "eventTime": {"type": "string"},
                        "eventName": {"type": "string"},
                        "s3": {
                            "type": "object",
                            "properties": {
                                "bucket": {
                                    "type": "object",
                                    "properties": {
                                        "name": {"type": "string"},
                                        "arn": {"type": "string"}
                                    },
                                    "required": ["name", "arn"]
                                }
                            },
                            "required": ["bucket"]
                        }
                    },
                    "required": [
                        "eventVersion", "eventSource", "awsRegion",
                        "eventTime", "eventName", "s3"
                    ]
                }
            ]
        }
    },
    "required": ["Records"]
}
