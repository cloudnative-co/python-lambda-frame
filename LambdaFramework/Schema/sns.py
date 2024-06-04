sns = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "EventVersion": {"type": "string"},
                        "EventSubscriptionArn": {"type": "string"},
                        "EventSource": {"type": "string"},
                        "Sns": {
                            "type": "object",
                            "properties": {
                                "SignatureVersion": {"type": "string"},
                                "Timestamp": {"type": "string"},
                                "Signature": {"type": "string"},
                                "SigningCertUrl": {"type": "string"},
                                "MessageId": {"type": "string"},
                                "Message": {"type": "string"},
                                "MessageAttributes": {"type": "object"},
                                "Type": {"type": "string"},
                                "UnsubscribeUrl": {"type": "string"},
                                "TopicArn": {"type": "string"},
                                "Subject": {"type": "string"}
                            },
                            "required": [
                                "SignatureVersion",
                                "Timestamp",
                                "Signature",
                                "SigningCertUrl",
                                "MessageId",
                                "Message",
                                "MessageAttributes",
                                "Type",
                                "UnsubscribeUrl",
                                "TopicArn",
                                "Subject"
                            ]
                        }
                    },
                    "required": [
                        "EventVersion", "EventSubscriptionArn",
                        "EventSource", "Sns"
                    ]
                }
            ]
        }
    },
    "required": ["Records"]
}
