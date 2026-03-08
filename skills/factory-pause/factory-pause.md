---
name: factory:pause
description: Pause the autonomous factory build process.
user_invocable: true
---

# /factory:pause — Pause Build

Pause the Ralph Loop and set the factory to paused mode.

## Implementation

1. **Update State**:
   - Read `.factory/STATE.md`
   - Set `Mode: paused`
   - Set `Last Activity: {timestamp} — paused by user`
   - Add to Blockers: `User-requested pause`

2. **Cancel Ralph Loop**:
```
/ralph-loop:cancel-ralph
```

3. **Confirm**:
```markdown
## Factory Paused

**Phase**: {current phase} of {total}
**Action was**: {what was happening when paused}
**Progress saved**: All state is in `.factory/STATE.md`

To resume: `/factory:resume`
```
