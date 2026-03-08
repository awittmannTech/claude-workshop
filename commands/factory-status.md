---
name: factory:status
description: Check the current status of the factory build process.
user_invocable: true
---

# /factory:status — Check Build Status

Display the current state of the Software Factory build process.

## Implementation

1. **Read State**:
```bash
cat .factory/STATE.md
```

2. **Read Latest Iteration Log** (if building):
```bash
# Find most recent log
LATEST_LOG=$(ls -t .factory/logs/iteration-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
  cat "$LATEST_LOG"
fi
```

3. **Read Latest QA Report** (if exists):
```bash
LATEST_QA=$(ls -t .factory/quality/qa-report-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_QA" ]; then
  cat "$LATEST_QA"
fi
```

4. **Display Status**:

```markdown
## Factory Status

**Product**: {name}
**Mode**: {mode}
**Phase**: {current} of {total}
**Action**: {current action}
**Iteration**: {N} of {max}
**Last Activity**: {timestamp} — {description}

### Phase Progress
| # | Phase | Status | Tests | QA | Review |
|---|-------|--------|-------|-----|--------|
{phase progress table from STATE.md}

### Current Phase Details
{What's happening right now}

### Test Results (Latest)
- Unit: {pass}/{total}
- E2E: {pass}/{total}

### Blockers
{Any blockers or "None"}

### Recent Activity
{Last 5 entries from iteration logs}
```

If mode is `paused`:
```markdown
### Paused — Action Required
**Reason**: {blocker description}
**To resume**: Fix the issue, then run `/factory:resume`
```

If mode is `complete`:
```markdown
### Build Complete
All {N} phases built, tested, and reviewed.
Run `npm run dev` to see your product.
```
