cloudwatch_logs = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "awslogs": {
            "type": "object",
            "properties": {
                "data": {
                    "type": "string"
                }
            },
            "required": [
                "data"
            ]
        }
    },
    "required": [
        "awslogs"
    ]
}
