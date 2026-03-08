---
name: factory:build
description: Start the autonomous Ralph Loop build process. Requires locked spec and roadmap.
user_invocable: true
---

# /factory:build — Start Autonomous Build

Start the Ralph Loop to autonomously build the SaaS product.

## Pre-Flight Checks

Before starting, validate:

1. **Spec exists and is locked**:
```bash
if [ ! -f .factory/SPEC.md ]; then
  echo "ERROR: No product spec found. Run /factory:new first."
  exit 1
fi
grep -q "Spec Locked:" .factory/STATE.md || {
  echo "ERROR: Spec not locked. Complete /factory:new first."
  exit 1
}
```

2. **Roadmap exists and is locked**:
```bash
if [ ! -f .factory/ROADMAP.md ]; then
  echo "ERROR: No roadmap found. Run /factory:new first."
  exit 1
fi
grep -q "Roadmap Locked:" .factory/STATE.md || {
  echo "ERROR: Roadmap not locked. Complete /factory:new first."
  exit 1
}
```

3. **Prerequisites met** (if any):
```bash
if [ -f .factory/PREREQUISITES.md ]; then
  echo "Checking prerequisites..."
  # Verify env vars are set, API keys present
fi
```

4. **Devcontainer available**:
```bash
if [ -d .devcontainer ]; then
  echo "Devcontainer config found."
else
  echo "WARNING: No devcontainer. Building in host environment."
fi
```

## Start Build

1. Update `.factory/STATE.md`:
   - Set `Mode: building`
   - Set `Current Phase: 1`
   - Set `Current Action: planning`
   - Set `Last Activity: {timestamp} — build started`

2. Initialize git if not already:
```bash
git init 2>/dev/null || true
git add -A
git commit -m "chore: factory build initialized" 2>/dev/null || true
```

3. Start Ralph Loop:
```
/ralph-loop:ralph-loop
```

With prompt from `templates/ralph-prompt.md` and parameters:
- `--completion-promise "FACTORY COMPLETE"`
- `--max-iterations 50`

4. Tell the user:
```markdown
## Factory Build Started

**Mode**: Autonomous (Ralph Loop)
**Phases**: {N} phases from roadmap
**Max Iterations**: 50
**Completion Signal**: `<promise>FACTORY COMPLETE</promise>`

The factory is now building your product. Each iteration:
1. Reads current state
2. Executes the next action (plan → build → test → review)
3. Updates state and commits progress

**You can walk away.** The factory will:
- Iterate until all phases are complete
- Pause if it gets stuck (same state for 3 iterations)
- Pause if it needs something only you can provide

**Monitor progress:**
- `/factory:status` — see current phase and test results
- `/factory:pause` — stop the build
- Watch `.factory/STATE.md` for live state
- Watch `.factory/logs/` for iteration details
```
