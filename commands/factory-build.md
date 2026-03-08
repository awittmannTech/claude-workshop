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

## Start Build

### Step 1: Launch Devcontainer
Automatically build and start the devcontainer so everything runs in an isolated environment:

```bash
# Check Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "ERROR: Docker is not running. Please start Docker Desktop first."
  echo "On Windows: Open Docker Desktop from the Start menu"
  echo "On Mac: Open Docker Desktop from Applications"
  echo "Then run /factory:build again."
  exit 1
fi

# Build and start devcontainer services
echo "Building devcontainer (this may take a few minutes on first run)..."
docker compose -f .devcontainer/docker-compose.yml build

echo "Starting services (app + PostgreSQL)..."
docker compose -f .devcontainer/docker-compose.yml up -d

# Wait for PostgreSQL to be healthy
echo "Waiting for PostgreSQL to be ready..."
RETRIES=30
until docker compose -f .devcontainer/docker-compose.yml exec -T db pg_isready -U factory -d factorydb > /dev/null 2>&1; do
  RETRIES=$((RETRIES-1))
  if [ $RETRIES -le 0 ]; then
    echo "ERROR: PostgreSQL failed to start. Check logs:"
    echo "  docker compose -f .devcontainer/docker-compose.yml logs db"
    exit 1
  fi
  sleep 2
done
echo "PostgreSQL is ready!"

# Install dependencies inside the container
echo "Installing dependencies..."
docker compose -f .devcontainer/docker-compose.yml exec -T app pnpm install

# Generate Prisma client
echo "Setting up database..."
docker compose -f .devcontainer/docker-compose.yml exec -T app npx prisma generate 2>/dev/null || true
```

If `.devcontainer/` does not exist, warn and build in host environment instead:
```bash
if [ ! -d .devcontainer ]; then
  echo "WARNING: No .devcontainer/ found. Building in host environment."
  echo "For isolated builds, run /factory:new first to generate devcontainer config."
fi
```

### Step 2: Update State
Update `.factory/STATE.md`:
- Set `Mode: building`
- Set `Current Phase: 1`
- Set `Current Action: planning`
- Set `Last Activity: {timestamp} — build started`

### Step 3: Initialize Git
```bash
git init 2>/dev/null || true
git add -A
git commit -m "chore: factory build initialized" 2>/dev/null || true
```

### Step 4: Start Ralph Loop
All build commands run inside the container via `docker compose exec`:

```bash
# The factory-orchestrator agent runs commands inside the container:
# docker compose -f .devcontainer/docker-compose.yml exec -T app <command>
#
# Examples:
#   exec app npx vitest --run          (unit tests)
#   exec app npx playwright test       (E2E tests)
#   exec app npm run build             (build check)
#   exec app npx tsc --noEmit          (type check)
#   exec app npx eslint .              (lint)
```

Start Ralph Loop:
```
/ralph-loop:ralph-loop
```

With prompt from `templates/ralph-prompt.md` and parameters:
- `--completion-promise "FACTORY COMPLETE"`
- `--max-iterations 50`

### Step 5: Tell the User
```markdown
## Factory Build Started

**Environment**: Devcontainer (Docker)
**Database**: PostgreSQL @ db:5432/factorydb
**Mode**: Autonomous (Ralph Loop)
**Phases**: {N} phases from roadmap
**Max Iterations**: 50

The factory is now building your product inside a Docker container.
Each iteration:
1. Reads current state
2. Executes the next action (plan → build → test → review)
3. Runs all commands inside the container
4. Updates state and commits progress

**You can walk away.** The factory will:
- Iterate until all phases are complete
- Pause if it gets stuck (same state for 3 iterations)
- Pause if it needs something only you can provide

**Monitor progress:**
- `/factory:status` — check progress anytime
- `/factory:pause` — stop the build
- `docker compose -f .devcontainer/docker-compose.yml logs -f app` — watch container logs

**When the build completes:**
- Stop container: `docker compose -f .devcontainer/docker-compose.yml down`
- Or keep it running and develop inside it
```
