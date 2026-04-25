# DISPATCH.md -- shortless-ios

> Swift iOS app: Safari content blocker + Screen Time integration.
> Read CLAUDE.md first.

## Pre-Approved Tasks (No Confirmation Needed)

| Task Keyword | Description | Success Criteria | Delegate To |
|---|---|---|---|
| `audit` | Review codebase for bugs, Swift best practices, security issues | Report written to `ai/dispatch-audit.md` | `gemini-2.5-pro` |
| `explore` | Map architecture, dependencies, target structure, and patterns | Notes written to `ai/dispatch-explore.md` | `gemini-2.5-pro` |
| `docs-gen` | Improve code comments and documentation | Docs updated, no functional changes | `mistral-large-latest` |

## Requires Confirmation (Never Auto-Execute)

- `deploy` -- no App Store submissions or builds
- `delete` -- no file deletion
- `install` -- no dependency changes
- `entitlements` -- no provisioning or entitlement modifications
- `privacy` -- no changes to privacy-sensitive code (Screen Time, VPN)
- `refactor` -- structural changes require human review

## Path Firewall

Autonomous work may only read/write files under:
```
c:\Users\perry\DevProjects\shortless-ios\**
```

## Opportunistic Lane (Budget Dispatcher)

**Eligible for autonomous execution:** `audit`, `explore`, `docs-gen`

**Note:** `tests-gen` is excluded because the dispatcher's test verification uses `npm test`, which does not apply to Swift/XCTest projects.

**Branch naming:** `auto/shortless-ios-<task>-<YYYYMMDD-HHMMSS>`

**Commit prefix:** `[opportunistic][dispatch.mjs][<model>]`
