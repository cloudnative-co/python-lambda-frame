documentdb = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "eventSourceArn": {"type": "string"},
        "events": {
            "type": "array",
            "items": [{"type": "object"}]
        },
        "eventSource": {"type": "string"}
    },
    "required": ["eventSourceArn", "events", "eventSource"]
}
