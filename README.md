# Software Factory

A Claude Code plugin that takes a product idea from market research through to working, tested code with minimal human intervention.

## How It Works

```
/factory:new "project management SaaS"
  │
  ├─ Market Research (competitors, pricing, complaints)
  ├─ Product Spec (features, acceptance criteria, data model)
  ├─ Roadmap Planning (phases, dependencies, parallelization)
  └─ Devcontainer Setup (Node.js + Prisma + PostgreSQL + Playwright)
  │
/factory:build
  │
  └─ Ralph Loop (autonomous, iterates until complete)
       │
       Each iteration:
       ├─ Read .factory/STATE.md
       ├─ Plan → Build → Test → Review → Next Phase
       ├─ Atomic commits per task
       ├─ Vitest + Playwright CLI for testing
       └─ <promise>FACTORY COMPLETE</promise> when done
```

## Installation

This is a Claude Code plugin. Install it by adding the plugin path to your Claude Code configuration:

```bash
# From your project directory
claude plugins add /path/to/claude-workshop
```

## Commands

| Command | Description |
|---------|-------------|
| `/factory:new [idea]` | Start new project — interactive research, spec, roadmap |
| `/factory:build` | Start autonomous Ralph Loop build |
| `/factory:status` | Check current build progress |
| `/factory:pause` | Pause the build |
| `/factory:resume` | Resume after fixing blockers |

## Architecture

### Interactive Phase (`/factory:new`)
1. **Market Research** — `market-researcher` agent searches competitors, pricing, user complaints
2. **Spec Writing** — `spec-writer` agent creates product spec with testable acceptance criteria
3. **Roadmap Planning** — Phases with dependencies and wave-based parallelization
4. **Devcontainer Setup** — `devcontainer-builder` creates Docker environment

### Autonomous Phase (`/factory:build`)
The `factory-orchestrator` agent runs inside the Ralph Loop, executing a state machine:

```
planning → executing → testing → reviewing → [next phase or complete]
               ↑          |
               └── fix ───┘ (max 3 cycles)
```

Per phase:
- **Planning**: `architect` designs implementation structure
- **Executing**: `fullstack-dev` implements in parallel waves with atomic commits
- **Testing**: `test-writer` + `qa-validator` run Vitest and Playwright CLI
- **Reviewing**: `code-reviewer` + `code-simplifier` + `quality-gate`

### Agents (14)

| Agent | Purpose | Model |
|-------|---------|-------|
| market-researcher | Competitor/pricing/sentiment research | opus |
| spec-writer | Product specification from research | opus |
| factory-orchestrator | Ralph Loop brain — state machine | opus |
| fullstack-dev | Next.js + Prisma implementation | opus |
| architect | Phase architecture planning | sonnet |
| test-writer | Vitest + Playwright test generation | sonnet |
| qa-validator | Test execution and QA reports | sonnet |
| code-reviewer | Code quality review | sonnet |
| code-simplifier | Formatting, linting, simplification | sonnet |
| quality-gate | Lint, types, build, security gate | sonnet |
| security-auditor | OWASP vulnerability scanning | sonnet |
| devcontainer-builder | Docker environment generation | sonnet |
| github-orchestrator | GitHub repo/issues/PRs management | sonnet |
| devops-agent | Environment setup and verification | sonnet |

## State Management

Factory state lives in `.factory/` inside the target project:

```
.factory/
├── STATE.md          # Current position, phase progress
├── SPEC.md           # Locked product specification
├── ROADMAP.md        # Phase plan
├── PREREQUISITES.md  # Required API keys, env vars
├── config.json       # Factory configuration
├── research/         # Market research outputs
├── plans/            # Per-phase architecture plans
├── quality/          # QA reports, test results
└── logs/             # Per-iteration logs
```

## Default Stack

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript (strict)
- **Database**: PostgreSQL + Prisma ORM
- **Auth**: NextAuth.js v5
- **Styling**: Tailwind CSS + shadcn/ui
- **Testing**: Vitest (unit) + Playwright (E2E)
- **Container**: Docker devcontainer

## Key Design Decisions

### Spec → Test Traceability
Acceptance criteria in the spec become tests. The test manifest tracks which criteria are covered by which tests, ensuring nothing is missed.

### Wave-Based Parallelization
Independent tasks within a phase run in parallel waves. Wave 1 has no dependencies, Wave 2 depends on Wave 1, etc.

### Goal-Backward Verification
After each phase, verify the *goal* was achieved ("Can a user log in?") not just that tasks completed ("Did we create auth files?").

### Stuck Detection
If the state hash doesn't change for 3 iterations, the factory pauses and asks for human help rather than spinning forever.

### Atomic Commits
Every task produces its own git commit: `feat(phase-N): description`. This creates clean git history and makes rollbacks easy.

## Configuration

Edit `config.json` to customize:

```json
{
  "factory": { "maxIterations": 50, "maxFixCyclesPerPhase": 3 },
  "research": { "minCompetitors": 3, "minComplaints": 5 },
  "testing": { "coverageTarget": 80, "flakyTestRetries": 2 },
  "devcontainer": { "stackTemplate": "nextjs-prisma-postgres" }
}
```

## Requirements

- Claude Code with plugin support
- Ralph Loop plugin installed (`ralph-loop:ralph-loop`)
- Docker (for devcontainer)
- Node.js 20+ (if running outside container)
