cloudtrail = {
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
                        "userIdentity": {"type": "object"},
                        "eventTime": {"type": "string"},
                        "eventSource": {"type": "string"},
                        "eventName": {"type": "string"},
                        "awsRegion": {"type": "string"},
                        "sourceIPAddress": {"type": "string"},
                        "userAgent": {"type": "string"},
                        "requestParameters": {"type": "object"},
                        "responseElements": {
                            "type": "object",
                            "properties": {
                                "topicArn": {"type": "string"}
                            },
                            "required": ["topicArn"]
                        },
                        "requestID": {"type": "string"},
                        "eventID": {"type": "string"},
                        "eventType": {"type": "string"},
                        "recipientAccountId": {"type": "string"}
                    },
                    "required": [
                        "eventVersion", "userIdentity", "eventTime",
                        "eventSource", "eventName", "awsRegion",
                        "sourceIPAddress", "userAgent", "requestParameters",
                        "responseElements", "requestID", "eventID",
                        "eventType", "recipientAccountId"
                    ]
                },
                {
                    "type": "object",
                    "properties": {
                        "eventVersion": {"type": "string"},
                        "userIdentity": {"type": "object"},
                        "eventTime": {"type": "string"},
                        "eventSource": {"type": "string"},
                        "eventName": {"type": "string"},
                        "awsRegion": {"type": "string"},
                        "sourceIPAddress": {"type": "string"},
                        "userAgent": {"type": "string"},
                        "requestParameters": {
                            "type": "object",
                            "properties": {
                                "topicArn": {"type": "string"}
                            },
                            "required": [
                                "topicArn"
                            ]
                        },
                        "responseElements": {
                            "anyOf": [{"type": "null"}, {"type": "object"}]
                        },
                        "requestID": {"type": "string"},
                        "eventID": {"type": "string"},
                        "eventType": {"type": "string"},
                        "recipientAccountId": {"type": "string"}
                    },
                    "required": [
                        "eventVersion",
                        "userIdentity",
                        "eventTime",
                        "eventSource",
                        "eventName",
                        "awsRegion",
                        "sourceIPAddress",
                        "userAgent",
                        "requestParameters",
                        "responseElements",
                        "requestID",
                        "eventID",
                        "eventType",
                        "recipientAccountId"
                    ]
                }
            ]
        }
    },
    "required": [
        "Records"
    ]
}
