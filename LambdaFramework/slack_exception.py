class SlackException(Exception):
    def __init__(self, error):
        match error:
            case "as_user_not_supported":
                msg = "The as_user parameter does not function with workspace apps."
            case "channel_not_found":
                msg = "Value passed for channel was invalid."
            case "duplicate_channel_not_found":
                msg = "Channel associated with client_msg_id was invalid."
            case "duplicate_message_not_found":
                msg = "No duplicate message exists associated with client_msg_id."
            case "ekm_access_denied":
                msg = "Administrators have suspended the ability to post a message."
            case "invalid_blocks":
                msg = "Blocks submitted with this message are not valid"
            case "invalid_blocks_format":
                msg = "The blocks is not a valid JSON object or doesn't match the Block Kit syntax."
            case "invalid_metadata_format":
                msg = "Invalid metadata format provided"
            case "invalid_metadata_schema":
                msg = "Invalid metadata schema provided"
            case "is_archived":
                msg = "Channel has been archived."
            case "message_limit_exceeded":
                msg = "Members on this team are sending too many messages. For more details, see https://slack.com/help/articles/115002422943-Usage-limits-for-free-workspaces"
            case "messages_tab_disabled":
                msg = "Messages tab for the app is disabled."
            case "metadata_must_be_sent_from_app":
                msg = "Message metadata can only be posted or updated using an app-level token"
            case "metadata_too_large":
                msg = "Metadata exceeds size limit"
            case "msg_too_long":
                msg = "Message text is too long"
            case "no_text":
                msg = "No message text provided"
            case "not_in_channel":
                msg = "Cannot post user messages to a channel they are not in."
            case "rate_limited":
                msg = "Application has posted too many messages, read the Rate Limit documentation for more information"
            case "restricted_action":
                msg = "A workspace preference prevents the authenticated user from posting."
            case "restricted_action_non_threadable_channel":
                msg = "Cannot post thread replies into a non_threadable channel."
            case "restricted_action_read_only_channel":
                msg = "Cannot post any message into a read-only channel."
            case "restricted_action_thread_locked":
                msg = "Cannot post replies to a thread that has been locked by admins."
            case "restricted_action_thread_only_channel":
                msg = "Cannot post top-level messages into a thread-only channel."
            case "slack_connect_canvas_sharing_blocked":
                msg = "Admin has disabled Canvas File sharing in all Slack Connect communications"
            case "slack_connect_file_link_sharing_blocked":
                msg = "Admin has disabled Slack File sharing in all Slack Connect communications"
            case "slack_connect_lists_sharing_blocked":
                msg = "Admin has disabled Lists sharing in all Slack Connect communications"
            case "team_access_not_granted":
                msg = "The token used is not granted the specific workspace access required to complete this request."
            case "too_many_attachments":
                msg = "Too many attachments were provided with this message. A maximum of 100 attachments are allowed on a message."
            case "too_many_contact_cards":
                msg = "Too many contact_cards were provided with this message. A maximum of 10 contact cards are allowed on a message."
            case "cannot_reply_to_message":
                msg = "This message type cannot have thread replies."
            case "missing_file_data":
                msg = "Attempted to share a file but some required data was missing."
            case "attachment_payload_limit_exceeded":
                msg = "Attachment payload size is too long."
            case "access_denied":
                msg = "Access to a resource specified in the request is denied."
            case "account_inactive":
                msg = "Authentication token is for a deleted user or workspace when using a bot token."
            case "deprecated_endpoint":
                msg = "The endpoint has been deprecated."
            case "enterprise_is_restricted":
                msg = "The method cannot be called from an Enterprise."
            case "invalid_auth":
                msg = "Some aspect of authentication cannot be validated. Either the provided token is invalid or the request originates from an IP address disallowed from making the request."
            case "method_deprecated":
                msg = "The method has been deprecated."
            case "missing_scope":
                msg = "The token used is not granted the specific scope permissions required to complete this request."
            case "not_allowed_token_type":
                msg = "The token type used in this request is not allowed."
            case "not_authed":
                msg = "No authentication token provided."
            case "no_permission":
                msg = "The workspace token used in this request does not have the permissions necessary to complete the request. Make sure your app is a member of the conversation it's attempting to post a message to."
            case "org_login_required":
                msg = "The workspace is undergoing an enterprise migration and will not be available until migration is complete."
            case "token_expired":
                msg = "Authentication token has expired"
            case "token_revoked":
                msg = "Authentication token is for a deleted user or workspace or the app has been removed when using a user token."
            case "two_factor_setup_required":
                msg = "Two factor setup is required."
            case "accesslimited":
                msg = "Access to this method is limited on the current network"
            case "fatal_error":
                msg = "The server could not complete your operation(s) without encountering a catastrophic error. It's possible some aspect of the operation succeeded before the error was raised."
            case "internal_error":
                msg = "The server could not complete your operation(s) without encountering an error, likely due to a transient issue on our end. It's possible some aspect of the operation succeeded before the error was raised."
            case "invalid_arg_name":
                msg = "The method was passed an argument whose name falls outside the bounds of accepted or expected values. This includes very long names and names with non-alphanumeric characters other than _. If you get this error, it is typically an indication that you have made a very malformed API call."
            case "invalid_arguments":
                msg = "The method was either called with invalid arguments or some detail about the arguments passed is invalid, which is more likely when using complex arguments like blocks or attachments."
            case "invalid_array_arg":
                msg = "The method was passed an array as an argument. Please only input valid strings."
            case "invalid_charset":
                msg = "The method was called via a POST request, but the charset specified in the Content-Type header was invalid. Valid charset names are: utf-8 iso-8859-1."
            case "invalid_form_data":
                msg = "The method was called via a POST request with Content-Type application/x-www-form-urlencoded or multipart/form-data, but the form data was either missing or syntactically invalid."
            case "invalid_post_type":
                msg = "The method was called via a POST request, but the specified Content-Type was invalid. Valid types are: application/json application/x-www-form-urlencoded multipart/form-data text/plain."
            case "missing_post_type":
                msg = "The method was called via a POST request and included a data payload, but the request did not include a Content-Type header."
            case "ratelimited":
                msg = "The request has been ratelimited. Refer to the Retry-After header for when to retry the request."
            case "request_timeout":
                msg = "The method was called via a POST request, but the POST data was either missing or truncated."
            case "service_unavailable":
                msg = "The service is temporarily unavailable"
            case "team_added_to_org":
                msg = "The workspace associated with your request is currently undergoing migration to an Enterprise Organization. Web API and other platform operations will be intermittently unavailable until the transition is complete."
            case "_":
                msg = None
        self.error_code = error
        super().__init__(msg)
