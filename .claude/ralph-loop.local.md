---
active: true
iteration: 1
session_id: 
max_iterations: 50
completion_promise: "FACTORY COMPLETE"
started_at: "2026-03-08T09:31:25Z"
---

Software Factory orchestrator. Read .factory/STATE.md, .factory/ROADMAP.md, .factory/SPEC.md and execute the next action. Run all build and test commands inside the devcontainer via docker compose exec. Spawn architect, fullstack-dev, test-writer, code-reviewer agents as needed per phase. Update STATE.md each iteration. Write logs to .factory/logs/. See templates/ralph-prompt.md for full instructions.
