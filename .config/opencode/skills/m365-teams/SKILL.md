---
name: m365-teams
description: >-
  Read Microsoft 365 as the signed-in user: Teams chats and channels, SharePoint
  files, Outlook mail, and calendars, through the claude.ai connector. Use for any
  Teams, SharePoint, or M365 search or read request. Prefer this over browser
  automation.
allowed-tools: Bash(m365:*)
---

# m365-teams

`m365` answers one Microsoft 365 question per call. It sends a request to the
Anthropic Messages API with the claude.ai Microsoft 365 connector attached. Anthropic
runs the connector server-side as the signed-in user, so no local Microsoft token and
no tenant admin consent are needed.

Source: [`m365.go`](m365.go) (Go, standard library only).

## Setup

```bash
go build -o ~/.local/bin/m365 ~/.config/opencode/skills/m365-teams/m365.go
```

## Run

```bash
m365 "list my 3 most recent Teams chats"
m365 -preset teams "summarize today in a team channel"
m365 -preset docs "find Q4 planning decks in SharePoint"
m365 -trace -preset chat "search my Teams messages for 'launch'"
```

`-trace` writes tool calls and token usage to stderr, and `-json` prints the raw
response. `m365 -h` lists every flag.

## Presets

Each preset enables only its tools. Unfiltered, the connector ships every tool schema
and costs about 61,000 input tokens; a preset costs about 3,000 to 8,000.

| Preset | Covers |
| --- | --- |
| `chat` (default) | Teams chats: list chats, search messages |
| `teams` | chats plus teams, channels, channel messages |
| `docs` | SharePoint and OneDrive files |
| `mail` | Outlook email |
| `calendar` | calendar and meeting availability |
| `people` | profile and people search |
| `all` | every read tool above |

Keep the preset as narrow as the question allows, and widen it only when the question
spans sources. The model defaults to `claude-haiku-4-5-20251001`; use
`-model claude-sonnet-5` for heavy synthesis over many messages.

`-tools a,b,c` narrows to exact connector tool names. Presets are read-only; add a
write tool such as `teams_send_chat_message` with `-tools` when the user asks to send.

## Auth

`m365` reads the Claude Code keychain item `Claude Code-credentials`, which carries the
`user:mcp_servers` scope, and rotates the token on expiry, writing the new token back.
Hold one refresh path at a time: `m365` locks `/tmp/m365-teams.lock` and serializes its
own runs.

## Notes

- Connector tools run inside one Anthropic API call. Results return as text, not
  OpenCode-native M365 tools.
- It uses a subscription token against enterprise-governed connectors from a
  non-official client. Confirm this against your organization's policy.
- Tool results are echoed into context, so large result sets raise cost. Prefer
  specific questions.
