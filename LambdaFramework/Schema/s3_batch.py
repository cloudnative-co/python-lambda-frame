s3_batch = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "invocationSchemaVersion": {
            "type": "string"
        },
        "invocationId": {
            "type": "string"
        },
        "job": {
            "type": "object",
            "properties": {
                "id": {
                    "type": "string"
                }
            },
            "required": [
                "id"
            ]
        },
        "tasks": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "taskId": {
                            "type": "string"
                        },
                        "s3Key": {
                            "type": "string"
                        },
                        "s3VersionId": {
                            "type": "string"
                        },
                        "s3BucketArn": {
                            "type": "string"
                        }
                    },
                    "required": [
                        "taskId",
                        "s3Key",
                        "s3VersionId",
                        "s3BucketArn"
                    ]
                }
            ]
        }
    },
    "required": [
        "invocationSchemaVersion",
        "invocationId",
        "job",
        "tasks"
    ]
}
