cloudfront = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "Records": {
            "type": "array",
            "items": [
                {
                    "type": "object",
                    "properties": {
                        "cf": {
                            "type": "object",
                            "properties": {
                                "config": {
                                    "type": "object",
                                    "properties": {
                                        "distributionId": {"type": "string"}
                                    },
                                    "required": ["distributionId"]
                                },
                                "request": {
                                    "type": "object",
                                    "properties": {
                                        "clientIp": {"type": "string"},
                                        "method": {"type": "string"},
                                        "uri": {"type": "string"},
                                        "headers": {
                                            "type": "object",
                                            "properties": {
                                                "host": {
                                                    "type": "array",
                                                    "items": [{"type": "object"}]
                                                },
                                                "user-agent": {
                                                    "type": "array",
                                                    "items": [{"type": "object"}]
                                                }
                                            },
                                            "required": ["host", "user-agent"]
                                        }
                                    },
                                    "required": [
                                        "clientIp", "method", "uri", "headers"
                                    ]
                                }
                            },
                            "required": ["config", "request"]
                        }
                    },
                    "required": ["cf"]
                }
            ]
        }
    },
    "required": ["Records"]
}
