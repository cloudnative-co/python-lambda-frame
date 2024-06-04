iot_events = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "event": {
            "type": "object",
            "properties": {
                "eventName": {"type": "string"},
                "eventTime": {"type": "integer"},
                "payload": {
                    "type": "object",
                    "properties": {
                        "detector": {"type": "object"},
                        "eventTriggerDetails": {"type": "object"},
                        "actionExecutionId": {"type": "string"},
                        "state": {"type": "object"}
                    },
                    "required": [
                        "detector", "eventTriggerDetails",
                        "actionExecutionId", "state"
                    ]
                }
            },
            "required": ["eventName", "eventTime", "payload"]
        }
    },
    "required": ["event"]
}
