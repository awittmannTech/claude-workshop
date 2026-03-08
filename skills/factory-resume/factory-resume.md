---
name: factory:resume
description: Resume a paused factory build process. Shows blockers and lets user fix them before restarting.
user_invocable: true
---

# /factory:resume — Resume Build

Resume a paused factory build after resolving blockers.

## Implementation

1. **Read State**:
```bash
cat .factory/STATE.md
```

Verify `Mode: paused`. If not paused:
```markdown
Factory is not paused. Current mode: {mode}
```

2. **Show Blockers**:
```markdown
## Blockers to Resolve

{List from STATE.md Blockers section}

**Have you resolved these issues?**
```

3. **Wait for User Confirmation**:
Use `AskUserQuestion` to confirm blockers are resolved.

4. **Clear Blockers and Resume**:
   - Clear Blockers section in STATE.md
   - Set `Mode: building`
   - Reset `Stuck Counter: 0`
   - Set `Last Activity: {timestamp} — resumed by user`

5. **Restart Ralph Loop**:
```
/ralph-loop:ralph-loop
```

With the same prompt from `templates/ralph-prompt.md`:
- `--completion-promise "FACTORY COMPLETE"`
- `--max-iterations {remaining iterations}`

6. **Confirm**:
```markdown
## Factory Resumed

**Phase**: {current phase} of {total}
**Resuming at**: {current action}
**Remaining iterations**: {max - current}

The factory is building again. Same monitoring commands apply:
- `/factory:status` — check progress
- `/factory:pause` — pause again if needed
```
