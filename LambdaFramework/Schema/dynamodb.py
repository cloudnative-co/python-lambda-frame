dynamodb = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "eventID": {"type": "string"},
                        "eventVersion": {"type": "string"},
                        "dynamodb": {"type": "object"},
                        "awsRegion": {"type": "string"},
                        "eventName": {"type": "string"},
                        "eventSourceARN": {"type": "string"},
                        "eventSource": {"type": "string"}
                    },
                    "required": [
                        "eventID", "eventVersion", "dynamodb", "awsRegion",
                        "eventName", "eventSourceARN", "eventSource"
                    ]
                }
            ]
        }
    },
    "required": ["Records"]
}
