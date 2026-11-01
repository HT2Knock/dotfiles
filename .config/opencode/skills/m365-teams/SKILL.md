---
name: m365-teams
description: >-
  Read Microsoft 365 as the signed-in user: Teams chats and channels, SharePoint
  files, Outlook mail, and calendars, through the claude.ai connector in Claude
  Code. Use for any Teams, SharePoint, or M365 search or read request. Prefer
  this over browser automation.
allowed-tools: Bash(claude:*)
---

# m365-teams

Answer Microsoft 365 questions by asking Claude Code. Claude Code has the
claude.ai Microsoft 365 connector attached, so it calls Microsoft Graph as the
signed-in user. No local Microsoft token and no tenant admin consent are needed.

## Run

```bash
claude -p "<question>" \
  --allowedTools "mcp__claude_ai_Microsoft_365__teams_list_chats" \
  --append-system-prompt "Read only: never call a tool that sends, posts, uploads, or deletes." \
  --output-format text
```

Write the question the way you want the answer. There is no fixed output shape,
so ask for a markdown table, JSON, CSV, or a plain list. For a large answer, add
`--add-dir /tmp/m365` and ask Claude to save the full result to a file there,
then read that file.

Use `--output-format json` when you need the run metadata: `result`,
`permission_denials`, cost, and turn count. Use `--model` to override the model.

## Tools

Allow only the tools the question needs. Each name has the form
`mcp__claude_ai_Microsoft_365__<tool>`. Allowing the server alone
(`mcp__claude_ai_Microsoft_365`) permits every tool on it, including write
tools.

| Need | Tools |
| --- | --- |
| Teams chats | `teams_list_chats`, `chat_message_search` |
| Teams channels | `teams_list_teams`, `teams_list_channels`, `teams_list_channel_messages` |
| SharePoint, OneDrive | `sharepoint_search`, `sharepoint_folder_search` |
| Outlook mail | `outlook_email_search` |
| Calendar | `outlook_calendar_search`, `find_meeting_availability` |
| People | `get_me`, `search_people` |
| Open one result | `read_resource` |

Many results return a reference that `read_resource` expands, such as a chat or
a file. Allow `read_resource` with any read set.

Write tools exist, such as `teams_send_chat_message`. Add one only when the user
asks to change data.

## Auth

Claude Code holds the credential. If a call fails with an auth error, run
`claude mcp list` and check that `claude.ai Microsoft 365` is connected. To
re-authenticate, open Claude Code and run `/mcp`.

## Notes

- Claude Code loads the M365 tools on demand. Name Microsoft 365 or the tool in
  the question, or Claude can answer that no M365 tools exist.
- Each call starts a fresh session and resends the tool schemas. One call per
  question costs less than several small calls. Use `--continue` to ask a
  follow-up in the same session.
- Microsoft Graph rate-limits repeated read calls. Space out runs, or expect one
  wait of about a minute.
- Do not add `--dangerously-skip-permissions`. In a non-interactive run a denied
  tool is the safe result.
- These are Claude Code tools, not OpenCode tools. The answer returns as text.
