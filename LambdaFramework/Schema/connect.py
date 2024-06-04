connect = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Details": {
            "type": "object",
            "properties": {
                "ContactData": {
                    "type": "object",
                    "properties": {
                        "Attributes": {"type": "object"},
                        "Channel": {"type": "string"},
                        "ContactId": {"type": "string"},
                        "CustomerEndpoint": {"anyOf": [{"type": "null"}, {"type": "object"}]},
                        "InitialContactId": {"type": "string"},
                        "InitiationMethod": {"type": "string"},
                        "InstanceARN": {"type": "string"},
                        "PreviousContactId": {"type": "string"},
                        "Queue": {"anyOf": [{"type": "null"}, {"type": "object"}]},
                        "SystemEndpoint": {"anyOf": [{"type": "null"}, {"type": "object"}]}
                    },
                    "required": [
                        "Attributes",
                        "Channel",
                        "ContactId",
                        "CustomerEndpoint",
                        "InitialContactId",
                        "InitiationMethod",
                        "InstanceARN",
                        "PreviousContactId",
                        "Queue",
                        "SystemEndpoint"
                    ]
                },
                "Parameters": {"type": "object"}
            },
            "required": ["ContactData", "Parameters"]
        },
        "Name": {"type": "string"}
    },
    "required": ["Details", "Name"]
}
