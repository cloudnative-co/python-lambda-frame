eventbridge = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "id": {"type": "string"},
        "account": {"type": "string"},
        "source": {"type": "string"},
        "time": {"type": "string"},
        "region": {"type": "string"},
        "resources": {
            "type": "array",
            "items": [{"type": "string"}]
        },
        "detail-type": {"type": "string"}
    },
    "required": [
        "id", "account", "source", "time",
        "region", "resources", "detail-type"
    ]
}

eventbridge_ec2 = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "version": {"type": "string"},
        "id": {"type": "string"},
        "detail-type": {"type": "string"},
        "source": {"type": "string"},
        "account": {"type": "string"},
        "time": {"type": "string"},
        "region": {"type": "string"},
        "resources": {
            "type": "array",
            "items": [{"type": "string"}]
        },
        "detail": {
            "type": "object",
            "properties": {
                "instance-id": {"type": "string"},
                "state": {"type": "string"}
            },
            "required": [
                "instance-id",
                "state"
            ]
        }
    },
    "required": [
        "version", "id", "detail-type", "source", "account", "time", "region",
        "resources", "detail"
    ]
}

eventbridge_rds = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "version": {"type": "string"},
        "id": {"type": "string"},
        "detail-type": {"type": "string"},
        "source": {"type": "string"},
        "account": {"type": "string"},
        "time": {"type": "string"},
        "region": {"type": "string"},
        "resources": {
            "type": "array",
            "items": [{"type": "string"}]
        },
        "detail": {
            "type": "object",
            "properties": {
                "EventCategories": {"type": "array"},
                "SourceType": {"type": "string"},
                "SourceArn": {"type": "string"},
                "Date": {"type": "string"},
                "Message": {"type": "string"},
                "SourceIdentifier": {"type": "string"}
            },
            "required": [
                "EventCategories",
                "SourceType",
                "SourceArn",
                "Date",
                "Message",
                "SourceIdentifier"
            ]
        }
    },
    "required": [
        "version", "id", "detail-type", "source", "account", "time",
        "region", "resources", "detail"
    ]
}
