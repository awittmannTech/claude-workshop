---
name: factory:new
description: Start a new Software Factory project. Guides through market research, spec writing, roadmap planning, and devcontainer setup.
user_invocable: true
---

# /factory:new — New Software Factory Project

You are starting the Software Factory interactive phase. Guide the user through research, specification, roadmap planning, and environment setup.

## Usage
```
/factory:new "product management SaaS"
/factory:new   (prompts for product idea)
```

## Interactive Flow

### Step 1: Capture Product Idea
If no argument provided, ask:
> What product do you want to build? Describe the idea in 1-2 sentences.

Extract: product name, category, target audience (if mentioned).

### Step 2: Initialize Factory State
Create the `.factory/` directory structure in the current project directory:

```bash
mkdir -p .factory/research .factory/quality .factory/logs .factory/plans
```

Copy the state template:
- Read `templates/factory-state.md` from the plugin directory
- Write it to `.factory/STATE.md` with the product name filled in
- Copy `config.json` to `.factory/config.json`

### Step 3: Market Research
Tell the user:
> Starting market research for "{product idea}". This will analyze competitors, pricing, features, and user sentiment.

Spawn the **market-researcher** agent with the product idea.

After research completes, present findings to the user:
```markdown
## Research Complete

### Market Size
{from research}

### Top Competitors Found
1. {competitor 1} — {pricing} — {key strength}
2. {competitor 2} — {pricing} — {key strength}
3. {competitor 3} — {pricing} — {key strength}

### Key User Pain Points
- {complaint 1} (from {source})
- {complaint 2} (from {source})

### Feature Gaps (Opportunities)
- {gap 1}
- {gap 2}

### Recommended Positioning
{positioning recommendation}

**Does this look right? Any areas you want me to dig deeper into?**
```

If user has feedback, refine research. Otherwise proceed.

### Step 4: Spec Writing
Tell the user:
> Generating product specification from research findings...

Spawn the **spec-writer** agent.

After spec is written, present a summary:
```markdown
## Product Spec Draft

### Vision
{from spec}

### MVP Features ({count})
1. {feature 1}
2. {feature 2}
3. {feature 3}
...

### Data Model
{entity count} entities: {list}

### Pricing Strategy
{from spec}

**Review the full spec at `.factory/SPEC.md`. Want to modify anything?**
```

If user has changes, update the spec. When approved:
- Add `Spec Locked: {date}` to STATE.md
- Tell user: "Spec locked."

### Step 5: Roadmap Planning
Tell the user:
> Planning implementation roadmap from specification...

Create `.factory/ROADMAP.md` with phases derived from the spec:

```markdown
# Factory Roadmap: {Product Name}

## Phases
| # | Phase | Features | Est. Tasks | Dependencies |
|---|-------|----------|-----------|--------------|
| 1 | Foundation | Auth, DB, Layout | 4-6 | None |
| 2 | Core Features | {main features} | 8-12 | Phase 1 |
| 3 | Secondary Features | {secondary} | 5-8 | Phase 2 |
| 4 | Polish & Deploy | Testing, UX, Deploy | 3-5 | Phase 3 |

## Phase Details

### Phase 1: Foundation
**Goal**: User can sign up, log in, and see the dashboard layout.
**Features**: Authentication, database schema, navigation layout
**Prerequisites**: None

### Phase 2: Core Features
**Goal**: {what the user can do after this phase}
**Features**: {list}
**Prerequisites**: Phase 1 complete

### Phase 3: Secondary Features
...

### Phase 4: Polish & Deploy
...
```

Present to user:
```markdown
## Implementation Roadmap

{phase count} phases, estimated {task count} tasks total.

| Phase | Goal | Features |
|-------|------|----------|
| 1 | {goal} | {features} |
| 2 | {goal} | {features} |
...

**Approve this roadmap? You can adjust phases, reorder features, or change scope.**
```

When approved:
- Add `Roadmap Locked: {date}` to STATE.md
- Update STATE.md with phase count

### Step 6: Identify Prerequisites
Read `.factory/SPEC.md` section 10 (Prerequisites).

If prerequisites exist, present them:
```markdown
## Prerequisites Needed

Before autonomous building can start, you'll need:
- [ ] {API key / service account / env var}
- [ ] {Another prerequisite}

Please provide these or add them to `.env.local`.
```

Write to `.factory/PREREQUISITES.md`.

### Step 7: Devcontainer Setup
Tell the user:
> Generating devcontainer configuration...

Spawn **devcontainer-builder** agent.

After completion:
```markdown
## Devcontainer Ready

Generated `.devcontainer/` with:
- Node.js 20 + Prisma + Playwright + PostgreSQL
- Database: factory:factory@db:5432/factorydb
- Network whitelist for safe execution

**To start the container:**
1. Open this folder in VS Code
2. Click "Reopen in Container" when prompted
3. Or run: `docker compose -f .devcontainer/docker-compose.yml up -d`
```

### Step 8: Ready
```markdown
## Factory Ready

- [x] Market research complete
- [x] Product spec locked
- [x] Roadmap approved
- [x] Prerequisites identified
- [x] Devcontainer configured

**Run `/factory:build` to start autonomous construction.**
The factory will build your product phase by phase using the Ralph Loop.
You can walk away — it will iterate until complete or pause if it gets stuck.

**Other commands:**
- `/factory:status` — check progress anytime
- `/factory:pause` — pause the build
- `/factory:resume` — resume after fixing blockers
```
