codecommit = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "awsRegion": {"type": "string"},
                        "codecommit": {
                            "type": "object",
                            "properties": {
                                "references": {
                                    "type": "array",
                                    "items": [
                                        {
                                            "type": "object",
                                            "properties": {
                                                "commit": {"type": "string"},
                                                "ref": {"type": "string"}
                                            },
                                            "required": ["commit", "ref"]
                                        }
                                    ]
                                }
                            },
                            "required": ["references"]
                        },
                        "eventId": {"type": "string"},
                        "eventName": {"type": "string"},
                        "eventPartNumber": {"type": "integer"},
                        "eventSource": {"type": "string"},
                        "eventSourceARN": {"type": "string"},
                        "eventTime": {"type": "string"},
                        "eventTotalParts": {"type": "integer"},
                        "eventTriggerConfigId": {"type": "string"},
                        "eventTriggerName": {"type": "string"},
                        "eventVersion": {"type": "string"},
                        "userIdentityARN": {"type": "string"}
                    },
                    "required": [
                        "awsRegion", "codecommit", "eventId", "eventName",
                        "eventPartNumber", "eventSource", "eventSourceARN",
                        "eventTime", "eventTotalParts", "eventTriggerConfigId",
                        "eventTriggerName", "eventVersion", "userIdentityARN"
                    ]
                }
            ]
        }
    },
    "required": ["Records"]
}
