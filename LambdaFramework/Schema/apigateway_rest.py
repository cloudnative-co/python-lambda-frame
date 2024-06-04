apigateway_rest = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "resource": {"type": "string"},
        "path": {"type": "string"},
        "httpMethod": {"type": "string"},
        "headers": {"type": "object"},
        "multiValueHeaders": {"type": "object"},
        "queryStringParameters": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "multiValueQueryStringParameters": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "pathParameters": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "stageVariables": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "requestContext": {
            "type": "object",
            "properties": {
                "resourceId": {"type": "string"},
                "resourcePath": {"type": "string"},
                "httpMethod": {"type": "string"},
                "extendedRequestId": {"type": "string"},
                "requestTime": {"type": "string"},
                "path": {"type": "string"},
                "accountId": {"type": "string"},
                "protocol": {"type": "string"},
                "stage": {"type": "string"},
                "domainPrefix": {"type": "string"},
                "requestTimeEpoch": {"type": "integer"},
                "requestId": {"type": "string"},
                "identity": {"type": "object"},
                "domainName": {"type": "string"},
                "apiId": {"type": "string"}
            },
            "required": [
                "resourceId",
                "resourcePath",
                "httpMethod",
                "extendedRequestId",
                "requestTime",
                "path",
                "accountId",
                "protocol",
                "stage",
                "domainPrefix",
                "requestTimeEpoch",
                "requestId",
                "identity",
                "domainName",
                "apiId"
            ]
        },
        "body": {
            "anyOf": [{"type": "null"}, {"type": "string"}]
        },
        "isBase64Encoded": {"type": "boolean"}
    },
    "required": [
        "resource",
        "path",
        "httpMethod",
        "headers",
        "multiValueHeaders",
        "queryStringParameters",
        "multiValueQueryStringParameters",
        "pathParameters",
        "stageVariables",
        "requestContext",
        "body",
        "isBase64Encoded"
    ]
}
