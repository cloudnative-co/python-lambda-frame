apache_kafka = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "eventSource": {"type": "string"},
        "bootstrapServers": {"type": "string"},
        "records": {"type": "object"}
    },
    "required": [ "eventSource", "bootstrapServers", "records"]
}

apache_kafka_msk = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "eventSource": {"type": "string"},
        "eventSourceArn": {"type": "string"},
        "bootstrapServers": {"type": "string"},
        "records": {"type": "object"}
    },
    "required": [ "eventSource", "bootstrapServers", "records"]
}
