import json


class SlackErrorMessage(object):
    blocks = list()

    def __init__(self, msg: dict):
        trg = msg.get("event", {}).get("trigger", {})
        level = msg.get("level", "critical")
        match level:
            case "warning":
                emoji = "warning"
            case "error":
                emoji = "x"
            case "critical":
                emoji = "x"
            case "_":
                emoji = "x"
        self.blocks.append({
           "type": "header",
           "text": {
              "type": "plain_text", "text": f":{emoji}: {level}", "emoji": True
            }
        })
        self.blocks.append({"type": "divider"})
        self.blocks.append({
            "type": "rich_text",
            "elements": [
                {
                    "type": "rich_text_section",
                    "elements": [
                        {"type": "emoji", "name": emoji},
                        {
                            "type": "text", "text": "Message: ",
                            "style": { "bold": True }
                        },
                        {
                            "type": "text", "style": { "bold": True },
                            "text": msg.get('exception', None),
                        }
                    ]
                },
                {
                    "type": "rich_text_section",
                    "elements": [
                        {
                            "type": "text", "text": "Function-Name: ",
                            "style": { "bold": True }
                        },
                        {
                            "type": "text", "text": msg.get('function-name', None)
                        }
                    ]
                },
                {
                    "type": "rich_text_section",
                    "elements": [
                        {
                            "type": "text", "text": "Function-Arn: ",
                            "style": { "bold": True }
                        },
                        {
                            "type": "text", "text": msg.get('function-arn', None)
                        }
                    ]
                }
            ]
        })
        self.blocks.append({"type": "divider"})

        trg_elms = []
        for ky, v in trg.items():
            trg_elms.append({
                "type": "rich_text_section",
                "elements": [
                    {
                        "type": "text", "text": f"{ky}: ",
                        "style": { "bold": True }
                    },
                    {"type": "text", "text": v}
                ]
            })
        self.blocks.append({
            "type": "rich_text",
            "elements": trg_elms
        })


        self.blocks.append({"type": "divider"})
        traces = msg.get("trac", {}).get("trace", [])
        for trace in traces:
            self.blocks.append({
                "type": "rich_text",
                "elements": [
                    {
                        "type": "rich_text_section",
                        "elements": [{"type": "text", "text": trace["file"]}]
                    },
                    {
                        "type": "rich_text_list",
                        "style": "bullet",
                        "elements": [
                            {
                                "type": "rich_text_section",
                                "elements": [
                                    {
                                        "type": "text", "style": {"bold": True},
                                        "text": "function: "
                                    },
                                    {"type": "text", "text": trace.get("func")}
                                ]
                            },
                            {
                                "type": "rich_text_section",
                                "elements": [
                                    {
                                        "type": "text", "style": {"bold": True},
                                        "text": "line: "
                                    },
                                    {"type": "text", "text": trace.get("line")}
                                ]
                            },
                            {
                                "type": "rich_text_section",
                                "elements": [
                                    {
                                        "type": "text", "style": {"bold": True},
                                        "text": "trace: "
                                    },
                                    {
                                        "type": "text",
                                        "text": trace.get("trac")[0]
                                    }
                                ]
                            }
                        ]
                    }
                ]
            })

    def to_dict(self):
        return self.blocks

    def __str__(self):
        return json.dumps(self.to_dict())
