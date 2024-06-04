apigateway_autholizer = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "type": {"type": "string"},
        "authorizationToken": {"type": "string"},
        "methodArn": {"type": "string"}
    },
    "required": ["type", "authorizationToken", "methodArn"]
}

apigateway_request_autholizer = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "type": {"anyOf": [{"type": "null"}, {"type": "string"}]},
        "methodArn": {"anyOf": [{"type": "null"}, {"type": "string"}]},
        "resource": {"anyOf": [{"type": "null"}, {"type": "string"}]},
        "path": {"anyOf": [{"type": "null"}, {"type": "string"}]},
        "httpMethod": {"anyOf": [{"type": "null"}, {"type": "string"}]},
        "headers": {"type": "object"},
        "queryStringParameters": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "pathParameters": {"anyOf": [{"type": "null"}, {"type": "object"}]},
        "stageVariables": {"anyOf": [{"type": "null"}, {"type": "object"}]},
        "requestContext": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "accountId": {"type": "string"},
                "resourceId": {"type": "string"},
                "stage": {"type": "string"},
                "requestId": {"type": "string"},
                "identity": {"anyOf": [{"type": "null"}, {"type": "object"}]},
                "resourcePath": {"type": "string"},
                "httpMethod": {"type": "string"},
                "apiId": {"type": "string"}
            },
            "required": [
                "path", "accountId", "resourceId", "stage", "requestId",
                "identity", "resourcePath", "httpMethod", "apiId"
            ]
        }
    },
    "required": [
        "type", "methodArn", "resource", "path", "httpMethod", "headers",
        "queryStringParameters", "pathParameters", "stageVariables",
        "requestContext"
    ]
}

apigateway_proxy = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "body": {"anyOf": [{"type": "null"}, {"type": "string"}]},
        "resource": {"type": "string"},
        "path": {"type": "string"},
        "httpMethod": {"type": "string"},
        "isBase64Encoded": {"type": "boolean"},
        "queryStringParameters": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "multiValueQueryStringParameters": {
            "anyOf": [{"type": "null"}, {"type": "object"}]
        },
        "pathParameters": {
            "type": "object", "properties": {"proxy": {"type": "string"}},
        },
        "stageVariables": {"anyOf": [{"type": "null"}, {"type": "object"}]},
        "headers": {"anyOf": [{"type": "null"}, {"type": "object"}]},
        "multiValueHeaders": {"anyOf": [{"type": "null"}, {"type": "object"}]},
        "requestContext": {
            "type": "object",
            "properties": {
                "accountId": {"anyOf": [{"type": "null"}, {"type": "string"}]},
                "resourceId": {
                    "anyOf": [{"type": "null"}, {"type": "string"}]
                },
                "stage": {"anyOf": [{"type": "null"}, {"type": "string"}]},
                "requestId": {"anyOf": [{"type": "null"}, {"type": "string"}]},
                "requestTime": {
                    "anyOf": [{"type": "null"}, {"type": "string"}]
                },
                "requestTimeEpoch": {"type": "integer"},
                "identity": {"type": "object"},
                "path": {"anyOf": [{"type": "null"}, {"type": "string"}]},
                "resourcePath": {
                    "anyOf": [{"type": "null"}, {"type": "string"}]
                },
                "httpMethod": {"anyOf": [{"type": "null"}, {"type": "string"}]},
                "apiId": {"anyOf": [{"type": "null"}, {"type": "string"}]},
                "protocol": {"anyOf": [{"type": "null"}, {"type": "string"}]}
            },
            "required": [
                "accountId", "resourceId", "stage", "requestId", "requestTime",
                "requestTimeEpoch", "identity", "path", "resourcePath",
                "httpMethod", "apiId", "protocol"
            ]
        }
    },
    "required": [

        "body", "resource", "path", "httpMethod", "isBase64Encoded",
        "queryStringParameters", "multiValueQueryStringParameters",
        "pathParameters", "stageVariables", "headers", "multiValueHeaders",
        "requestContext"
    ]
}

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

apigateway_http = {
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



