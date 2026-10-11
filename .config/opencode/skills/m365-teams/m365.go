// Command m365 answers one Microsoft 365 question per call by attaching the
// claude.ai Microsoft 365 connector to a request to the Anthropic Messages API.
// Anthropic runs the connector server-side as the signed-in user, so no local
// Microsoft token and no tenant admin consent are needed.
//
// Auth reuses the Claude Code keychain credential and rotates it on expiry. Cost is
// bounded by the tool preset, because the connector ships tool schemas in every
// request. See SKILL.md beside this file for usage, presets, and limits.
package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"syscall"
	"time"
)

const (
	keychainService = "Claude Code-credentials"
	lockPath        = "/tmp/m365-teams.lock"
	tokenURL        = "https://platform.claude.com/v1/oauth/token"
	clientID        = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"
	apiURL          = "https://api.anthropic.com/v1/messages"
	connectorURL    = "https://microsoft365.mcp.claude.com/mcp"
	connectorName   = "Microsoft 365"
	// mcp-client-2025-11-20 accepts an mcp_toolset. The older
	// mcp-client-2025-04-04 beta attaches every tool and cannot filter.
	beta            = "mcp-client-2025-11-20"
	defaultModel    = "claude-haiku-4-5-20251001"
	refreshMarginMS = 60_000
)

const defaultSystem = "You are a read-only Microsoft 365 assistant. Call the fewest " +
	"tools needed. Use small result limits (10 or fewer) unless the user asks for " +
	"more, because large tool results raise cost. Answer only from tool results."

var httpClient = &http.Client{Timeout: 300 * time.Second}

func httpNewRequest(method, url string, body []byte) (*http.Request, error) {
	return http.NewRequest(method, url, bytes.NewReader(body))
}

// Read-only presets. Names are the bare connector tool names, without the
// "Microsoft 365_" prefix. Add write tools (teams_send_chat_message,
// sharepoint_upload_file, ...) only on purpose.
var presets = map[string][]string{"chat": {"teams_list_chats", "chat_message_search", "read_resource"},
	"teams":    {"teams_list_chats", "teams_list_teams", "teams_list_channels", "teams_list_channel_messages", "chat_message_search", "read_resource"},
	"docs":     {"sharepoint_search", "sharepoint_folder_search", "read_resource"},
	"mail":     {"outlook_email_search", "read_resource"},
	"calendar": {"outlook_calendar_search", "find_meeting_availability"},
	"people":   {"get_me", "search_people"},
	"all": {
		"teams_list_chats", "teams_list_teams", "teams_list_channels",
		"teams_list_channel_messages", "chat_message_search", "read_resource",
		"sharepoint_search", "sharepoint_folder_search", "outlook_email_search",
		"outlook_calendar_search", "find_meeting_availability", "get_me", "search_people",
	},
}

type mcpServer struct {
	Type string `json:"type"`
	URL  string `json:"url"`
	Name string `json:"name"`
}

type mcpToolset struct {
	Type          string                     `json:"type"`
	ServerName    string                     `json:"mcp_server_name"`
	DefaultConfig map[string]bool            `json:"default_config"`
	Configs       map[string]map[string]bool `json:"configs"`
}

type chatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type apiRequest struct {
	Model      string        `json:"model"`
	MaxTokens  int           `json:"max_tokens"`
	MCPServers []mcpServer   `json:"mcp_servers"`
	Tools      []mcpToolset  `json:"tools"`
	Messages   []chatMessage `json:"messages"`
	System     string        `json:"system,omitempty"`
}

type contentBlock struct {
	Type    string          `json:"type"`
	Text    string          `json:"text"`
	Name    string          `json:"name"`
	Input   json.RawMessage `json:"input"`
	IsError bool            `json:"is_error"`
}

type apiResponse struct {
	Content []contentBlock `json:"content"`
	Usage   struct {
		InputTokens  int `json:"input_tokens"`
		OutputTokens int `json:"output_tokens"`
	} `json:"usage"`
}

type refreshResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
}

func run(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	var out, errBuf bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &errBuf
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("%s: %w: %s", name, err, strings.TrimSpace(errBuf.String()))
	}
	return out.String(), nil
}

func keychainAccount() string {
	out, err := run("security", "find-generic-password", "-s", keychainService)
	if err == nil {
		for _, line := range strings.Split(out, "\n") {
			if strings.Contains(line, "\"acct\"") {
				if i := strings.Index(line, "="); i >= 0 {
					return strings.Trim(strings.TrimSpace(line[i+1:]), "\"")
				}
			}
		}
	}
	return os.Getenv("USER")
}

func readCredential() (map[string]json.RawMessage, error) {
	out, err := run("security", "find-generic-password", "-s", keychainService, "-w")
	if err != nil {
		return nil, err
	}
	var top map[string]json.RawMessage
	if err := json.Unmarshal([]byte(out), &top); err != nil {
		return nil, fmt.Errorf("parse keychain credential: %w", err)
	}
	return top, nil
}

func writeCredential(top map[string]json.RawMessage) error {
	blob, err := json.Marshal(top)
	if err != nil {
		return err
	}
	_, err = run("security", "add-generic-password", "-U",
		"-s", keychainService, "-a", keychainAccount(), "-w", string(blob))
	return err
}

func refreshTokens(refreshToken string) (*refreshResponse, error) {
	body, _ := json.Marshal(map[string]string{
		"grant_type":    "refresh_token",
		"refresh_token": refreshToken,
		"client_id":     clientID,
	})
	req, _ := httpNewRequest("POST", tokenURL, body)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json, text/plain, */*")
	req.Header.Set("User-Agent", "axios/1.13.6")
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("refresh failed: HTTP %d: %s", resp.StatusCode, string(raw))
	}
	var out refreshResponse
	if err := json.Unmarshal(raw, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

// accessToken returns a valid access token. When the stored token is expired it
// rotates it and writes the result back, unless refreshIfNeeded is false. A file
// lock serializes concurrent runs, because the refresh token rotates on use.
func accessToken(refreshIfNeeded bool) (string, error) {
	lock, err := os.OpenFile(lockPath, os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		return "", err
	}
	defer lock.Close()
	if err := syscall.Flock(int(lock.Fd()), syscall.LOCK_EX); err != nil {
		return "", err
	}

	top, err := readCredential()
	if err != nil {
		return "", err
	}
	var oauth map[string]json.RawMessage
	if err := json.Unmarshal(top["claudeAiOauth"], &oauth); err != nil {
		return "", fmt.Errorf("parse claudeAiOauth: %w", err)
	}
	var expiresAt int64
	_ = json.Unmarshal(oauth["expiresAt"], &expiresAt)

	if expiresAt-refreshMarginMS <= time.Now().UnixMilli() {
		if !refreshIfNeeded {
			return "", errors.New("claude code token expired; re-run without --no-refresh or open Claude Code once")
		}
		var refreshToken string
		if err := json.Unmarshal(oauth["refreshToken"], &refreshToken); err != nil {
			return "", err
		}
		fresh, err := refreshTokens(refreshToken)
		if err != nil {
			return "", err
		}
		access, _ := json.Marshal(fresh.AccessToken)
		refresh, _ := json.Marshal(fresh.RefreshToken)
		expires, _ := json.Marshal(time.Now().UnixMilli() + fresh.ExpiresIn*1000)
		oauth["accessToken"] = access
		oauth["refreshToken"] = refresh
		oauth["expiresAt"] = expires
		newOauth, _ := json.Marshal(oauth)
		top["claudeAiOauth"] = newOauth
		if err := writeCredential(top); err != nil {
			return "", fmt.Errorf("write keychain: %w", err)
		}
		return fresh.AccessToken, nil
	}

	var access string
	if err := json.Unmarshal(oauth["accessToken"], &access); err != nil {
		return "", err
	}
	return access, nil
}

func buildToolset(tools []string) []mcpToolset {
	configs := make(map[string]map[string]bool, len(tools))
	for _, name := range tools {
		configs[name] = map[string]bool{"enabled": true}
	}
	return []mcpToolset{{
		Type:          "mcp_toolset",
		ServerName:    connectorName,
		DefaultConfig: map[string]bool{"enabled": false},
		Configs:       configs,
	}}
}

func callAPI(token, model string, tools []string, prompt string, maxTokens int, system string) (*apiResponse, error) {
	reqBody := apiRequest{
		Model:      model,
		MaxTokens:  maxTokens,
		MCPServers: []mcpServer{{Type: "url", URL: connectorURL, Name: connectorName}},
		Tools:      buildToolset(tools),
		Messages:   []chatMessage{{Role: "user", Content: prompt}},
		System:     system,
	}
	body, _ := json.Marshal(reqBody)
	req, _ := httpNewRequest("POST", apiURL, body)
	req.Header.Set("anthropic-version", "2023-06-01")
	req.Header.Set("anthropic-beta", beta)
	req.Header.Set("content-type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, truncate(string(raw), 800))
	}
	var out apiResponse
	if err := json.Unmarshal(raw, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

func render(resp *apiResponse, trace bool) {
	for _, block := range resp.Content {
		switch block.Type {
		case "text":
			if text := strings.TrimSpace(block.Text); text != "" {
				fmt.Println(text)
			}
		case "mcp_tool_use":
			if trace {
				fmt.Fprintf(os.Stderr, "[tool] %s %s\n", block.Name, truncate(string(block.Input), 200))
			}
		case "mcp_tool_result":
			if trace {
				fmt.Fprintf(os.Stderr, "[tool result] error=%v\n", block.IsError)
			}
		}
	}
	if trace {
		fmt.Fprintf(os.Stderr, "[usage] input=%d output=%d\n", resp.Usage.InputTokens, resp.Usage.OutputTokens)
	}
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "..."
}

func main() {
	prompt := flag.String("prompt", "", "natural-language question (or pass it as the last argument)")
	preset := flag.String("preset", "chat", "tool preset: chat, teams, docs, mail, calendar, people, all")
	toolsFlag := flag.String("tools", "", "comma-separated tool names, overrides --preset")
	model := flag.String("model", defaultModel, "model id")
	maxTokens := flag.Int("max-tokens", 1500, "max output tokens")
	trace := flag.Bool("trace", false, "show tool calls and usage on stderr")
	asJSON := flag.Bool("json", false, "print the raw API response")
	noRefresh := flag.Bool("no-refresh", false, "fail instead of rotating an expired token")
	system := flag.String("system", "", "override the default system prompt")
	noSystem := flag.Bool("no-system", false, "send no system prompt")
	flag.Parse()

	question := *prompt
	if question == "" {
		question = strings.Join(flag.Args(), " ")
	}
	if question == "" {
		fmt.Fprintln(os.Stderr, "error: no prompt given")
		os.Exit(2)
	}

	tools, ok := presets[*preset]
	if *toolsFlag != "" {
		tools, ok = strings.Split(*toolsFlag, ","), true
	}
	if !ok {
		fmt.Fprintf(os.Stderr, "error: unknown preset %q\n", *preset)
		os.Exit(2)
	}

	sysPrompt := defaultSystem
	if *noSystem {
		sysPrompt = ""
	} else if *system != "" {
		sysPrompt = *system
	}

	token, err := accessToken(!*noRefresh)
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
	resp, err := callAPI(token, *model, tools, question, *maxTokens, sysPrompt)
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
	if *asJSON {
		blob, _ := json.MarshalIndent(resp, "", " ")
		fmt.Println(string(blob))
		return
	}
	render(resp, *trace)
}
