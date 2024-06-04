ses = {
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
                        "ses": {"type": "object"},
                        "eventSource": {"type": "string"}
                    },
                    "required": ["eventVersion", "ses", "eventSource"]
                }
            ]
        }
    },
    "required": ["Records"]
}
