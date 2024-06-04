codepipeline = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "CodePipeline.job": {
            "type": "object",
            "properties": {
                "id": {"type": "string"},
                "accountId": {"type": "string"},
                "data": {
                    "type": "object",
                    "properties": {
                        "actionConfiguration": {"type": "object"},
                        "inputArtifacts": {
                            "type": "array",
                            "items": [{"type": "object"}]
                        },
                        "outputArtifacts": {
                            "type": "array",
                            "items": [{"type": "object"}]
                        },
                        "artifactCredentials": {
                            "type": "object",
                            "properties": {
                                "accessKeyId": {"type": "string"},
                                "secretAccessKey": {"type": "string"},
                                "sessionToken": {"type": "string"},
                                "expirationTime": {"type": "integer"}
                            },
                            "required": [
                                "accessKeyId", "secretAccessKey",
                                "sessionToken", "expirationTime"
                            ]
                        }
                    },
                    "required": [
                        "actionConfiguration", "inputArtifacts",
                        "outputArtifacts", "artifactCredentials"
                    ]
                }
            },
            "required": ["id", "accountId", "data"]
        }
    },
    "required": ["CodePipeline.job"]
}
