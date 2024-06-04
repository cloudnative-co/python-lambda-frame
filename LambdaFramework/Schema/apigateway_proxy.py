apigateway_proxy = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "version": {
            "type": "string"
        },
        "routeKey": {
            "type": "string"
        },
        "rawPath": {
            "type": "string"
        },
        "rawQueryString": {
            "type": "string"
        },
        "cookies": {
            "type": "array",
            "items": [{"type": "string"}]
        },
        "headers": {
            "type": "object",
        },
        "requestContext": {
            "type": "object",
        },
        "isBase64Encoded": {
            "type": "boolean"
        }
    },
    "required": [
        "version",
        "routeKey",
        "rawPath",
        "rawQueryString",
        "cookies",
        "headers",
        "requestContext",
        "isBase64Encoded"
    ]
}
