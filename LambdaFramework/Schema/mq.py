active_mq = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "eventSource": {"type": "string"},
        "eventSourceArn": {"type": "string"},
        "messages": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "messageID": {"type": "string"},
                        "messageType": {"type": "string"},
                        "deliveryMode": {"type": "integer"},
                        "replyTo": {
                            "anyOf": [{"type": "null"}, {"type": "string"}]
                        },
                        "type": {
                            "anyOf": [{"type": "null"}, {"type": "string"}]
                        },
                        "expiration": {
                            "anyOf": [{"type": "null"}, {"type": "string"}]
                        },
                        "priority": {"type": "integer"},
                        "correlationId": {"type": "string"},
                        "redelivered": {"type": "boolean"},
                        "destination": {"type": "object"},
                        "data": {"type": "string"},
                        "timestamp": {"type": "integer"},
                        "brokerInTime": {"type": "integer"},
                        "brokerOutTime": {"type": "integer"},
                        "properties": {"type": "object"},
                    }
                }
            ]
        }
    },
    "required": ["eventSource", "eventSourceArn", "messages"]
}


rabbit_mq = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "eventSource": {"type": "string"},
        "eventSourceArn": {"type": "string"},
        "rmqMessagesByQueue": {
            "type": "object"
        }
    },
    "required": ["eventSource", "eventSourceArn", "rmqMessagesByQueue"]
}
