# Claude Code Plugin Official Specification

> Last updated: 2026-03-27
> Source: https://docs.anthropic.com/en/docs/claude-code/plugins, skills, agents, hooks

This document is the official spec reference the plugin-doctor skill uses as its validation baseline. It is auto-refreshed in Stage 0 (Self-Update).

---

## 1. Marketplace (marketplace.json)

### Location
`.claude-plugin/marketplace.json`

### Required fields
- `name` (string, kebab-case): marketplace identifier
- `owner` (object): `{ name: string (required), email?: string }`

### Optional fields
- `metadata.description`, `metadata.version`, `metadata.pluginRoot`

### Plugin entry (plugins[])
| Field | Required | Type | Description |
|------|------|------|------|
| `name` | ✅ | string (kebab-case) | plugin identifier |
| `source` | ✅ | string\|object | source path/URL |
| `description` | | string | description |
| `version` | | string (SemVer) | version |
| `author` | | object | `{ name, email? }` |
| `category` | | string | category |
| `keywords` | | array | search tags |
| `homepage` | | string | docs URL |
| `repository` | | string | source URL |
| `license` | | string | SPDX identifier |

### Source forms
- Relative path: `"./plugins/my-plugin"` (must start with `./`)
- GitHub: `{ source: "github", repo: "owner/repo", ref?, sha? }`
- Git URL: `{ source: "url", url: "...", ref?, sha? }`
- Git subdirectory: `{ source: "git-subdir", url: "...", path: "...", ref?, sha? }`
- npm: `{ source: "npm", package: "...", version?, registry? }`

---

## 2. Plugin (plugin.json)

### Location
`.claude-plugin/plugin.json` (optional — plugin works without it)

### Required fields (when the manifest exists)
- `name` (string, kebab-case): unique identifier

### Optional fields
| Field | Type | Description |
|------|------|------|
| `version` | string (SemVer) | version (plugin.json wins on conflict with marketplace) |
| `description` | string | description |
| `author` | object | `{ name, email?, url? }` |
| `homepage` | string | docs URL |
| `repository` | string | source URL |
| `license` | string | SPDX identifier |
| `keywords` | array | search tags |
| `commands` | string\|array | custom command path (default: `./commands/`) |
| `agents` | string\|array | custom agent path (default: `./agents/`) |
| `skills` | string\|array | custom skill path (default: `./skills/`) |
| `hooks` | string\|array\|object | hook config |
| `mcpServers` | string\|array\|object | MCP server config |
| `lspServers` | string\|array\|object | LSP server config |
| `outputStyles` | string\|array | output style path |
| `userConfig` | object | user config schema |

### Directory structure (default)
```
plugin-root/
├── .claude-plugin/plugin.json
├── commands/          (deprecated, skills/ recommended)
├── agents/
├── skills/
├── output-styles/
├── hooks/
│   ├── hooks.json
│   └── scripts/
├── .mcp.json
├── .lsp.json
└── settings.json
```

### Environment variables
- `${CLAUDE_PLUGIN_ROOT}`: absolute path of the installed plugin
- `${CLAUDE_PLUGIN_DATA}`: plugin persistent data directory

---

## 3. Skills (SKILL.md)

### Structure
```
skills/{skill-name}/
├── SKILL.md         (required)
├── references/      (optional)
└── scripts/         (optional)
```

### Full frontmatter fields
| Field | Type | Required | Default | Description |
|------|------|------|--------|------|
| `name` | string | no | directory name | identifier (kebab-case, max 64 chars) |
| `description` | string | recommended | first paragraph | skill description + trigger keywords |
| `argument-hint` | string | no | N/A | autocomplete hint |
| `allowed-tools` | string\|list | no | inherit | allowed tools (YAML list recommended) |
| `disallowed-tools` | string\|list | no | none | denied tools |
| `disable-model-invocation` | boolean | no | false | block automatic invocation by Claude |
| `user-invocable` | boolean | no | true | show in `/` menu |
| `model` | string | no | inherit | sonnet, haiku, opus, or full ID |
| `effort` | string | no | inherit | low, medium, high, max |
| `context` | string | no | inline | `fork` = subagent context |
| `agent` | string | no | general-purpose | agent type when context: fork |
| `paths` | string | no | N/A | glob pattern (comma-separated) |
| `shell` | string | no | bash | bash or powershell |
| `hooks` | object | no | N/A | skill-scoped hooks |
| `version` | string | no | N/A | documentation version |

### String substitution
- `$ARGUMENTS`: all arguments
- `$ARGUMENTS[N]` or `$N`: Nth argument
- `${CLAUDE_SESSION_ID}`: session ID
- `${CLAUDE_SKILL_DIR}`: SKILL.md directory

### Commands (deprecated)
- The `commands/` directory is legacy. `skills/` is recommended
- On same-name conflict, the skill wins
- Migration: `commands/file.md` → `skills/file/SKILL.md`

---

## 4. Agents (agents/*.md)

### Full frontmatter fields
| Field | Type | Required | Default | Description |
|------|------|------|--------|------|
| `name` | string | ✅ | N/A | unique identifier (kebab-case) |
| `description` | string | ✅ | N/A | agent description + delegation conditions |
| `tools` | string | no | inherit all | allowed tools (comma-separated) |
| `disallowedTools` | string | no | none | denied tools |
| `model` | string | no | inherit | sonnet, haiku, opus, inherit |
| `effort` | string | no | inherit | low, medium, high, max |
| `maxTurns` | number | no | unlimited | max turn count |
| `permissionMode` | string | no | default | default, acceptEdits, dontAsk, bypassPermissions, plan |
| `skills` | string\|array | no | none | preloaded skills |
| `mcpServers` | object\|array | no | inherit | MCP server config |
| `hooks` | object | no | none | lifecycle hooks |
| `memory` | string | no | none | user, project, local |
| `background` | boolean | no | false | background execution |
| `isolation` | string | no | none | worktree (git worktree isolation) |
| `color` | string | no | none | agent color |
| `whenToUse` | string | no | none | usage scenarios + examples |
| `initialPrompt` | string | no | none | auto-submitted first turn |

### Plugin agent restrictions
Agents inside a plugin cannot use these fields (they are ignored):
- `hooks`
- `mcpServers`
- `permissionMode`

---

## 5. Hooks (hooks.json)

### Location
- `hooks/hooks.json` (plugin)
- `hooks` field inside `plugin.json` (inline)
- `hooks` field in SKILL.md/Agent frontmatter

### Official event list (25)
1. SessionStart
2. InstructionsLoaded
3. UserPromptSubmit
4. PreToolUse
5. PermissionRequest
6. PostToolUse
7. PostToolUseFailure
8. Notification
9. SubagentStart
10. SubagentStop
11. TaskCreated
12. TaskCompleted
13. TeammateIdle
14. Stop
15. StopFailure
16. ConfigChange
17. CwdChanged
18. FileChanged
19. WorktreeCreate
20. WorktreeRemove
21. PreCompact
22. PostCompact
23. Elicitation
24. ElicitationResult
25. SessionEnd

### Hook types
| Type | Default timeout | Description |
|------|-------------|------|
| `command` | 600s | run shell script |
| `http` | 30s | POST webhook |
| `prompt` | 30s | LLM evaluation |
| `agent` | 60s | subagent verification |

### Command hook exit codes
- `0`: success, parse JSON from stdout
- `2`: block, use stderr as the error message
- other: non-blocking error

---

## 6. Validation rules

### Kebab-case rule
- lowercase letters, digits, and hyphens only
- regex: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- max 64 chars (skill name)

### SemVer rule
- format: `MAJOR.MINOR.PATCH`
- regex: `^\d+\.\d+\.\d+$`

### Valid built-in tool names
Bash, Read, Write, Edit, Glob, Grep, Agent, WebFetch, WebSearch, NotebookEdit, NotebookRead

### MCP tool name pattern
`mcp__{server}__{tool}` (e.g. `mcp__xcode__BuildProject`)

### Path rules
- relative path required, must start with `./`
- `../` forbidden (path escape)
- absolute paths forbidden
- Windows paths forbidden
