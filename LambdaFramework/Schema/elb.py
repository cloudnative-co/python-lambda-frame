elb = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "requestContext": {
            "type": "object",
            "properties": {
                "elb": {
                    "type": "object",
                    "properties": {
                        "targetGroupArn": {"type": "string"}
                    },
                    "required": ["targetGroupArn"]
                }
            },
            "required": ["elb"]
        },
        "httpMethod": {"type": "string"},
        "path": {"type": "string"},
        "queryStringParameters": {"type": "object"},
        "headers": {"type": "object"},
        "body": {"type": "string"},
        "isBase64Encoded": {"type": "boolean"}
    },
    "required": [
        "requestContext", "httpMethod", "path", "queryStringParameters",
        "headers", "body", "isBase64Encoded"
    ]
}
