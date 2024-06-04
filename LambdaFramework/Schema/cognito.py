cognito = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "datasetName": {"type": "string"},
        "eventType": {"type": "string"},
        "region": {"type": "string"},
        "identityId": {"type": "string"},
        "datasetRecords": {"type": "object"},
        "identityPoolId": {"type": "string"},
        "version": {"type": "integer"}
    },
    "required": [
        "datasetName",
        "eventType",
        "region",
        "identityId",
        "datasetRecords",
        "identityPoolId",
        "version"
    ]
}
