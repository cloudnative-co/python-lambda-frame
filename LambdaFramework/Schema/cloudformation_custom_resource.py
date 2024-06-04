cloudformation_custom_resource = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "RequestType": {"type": "string"},
        "ServiceToken": {"type": "string"},
        "ResponseURL": {"type": "string"},
        "StackId": {"type": "string"},
        "RequestId": {"type": "string"},
        "LogicalResourceId": {"type": "string"},
        "ResourceType": {"type": "string"},
        "ResourceProperties": {
            "type": "object",
            "properties": {
                "ServiceToken": {"type": "string"},
                "FunctionName": {"type": "string"}
            },
            "required": [
                "ServiceToken",
                "FunctionName"
            ]
        }
    },
    "required": [
        "RequestType",
        "ServiceToken",
        "ResponseURL",
        "StackId",
        "RequestId",
        "LogicalResourceId",
        "ResourceType",
        "ResourceProperties"
    ]
}
