# Factory Roadmap: Clarity Todo

## Phases
| # | Phase | Features | Est. Tasks | Dependencies |
|---|-------|----------|-----------|--------------|
| 1 | Foundation | Auth, DB Schema, Layout, Navigation | 5-7 | None |
| 2 | Core Task Management | Task CRUD, Due Dates, Priorities, Subtasks, NLP Parsing | 8-10 | Phase 1 |
| 3 | Organization & Views | Projects, Smart Views (Today/Upcoming/Someday), Overdue Handling | 6-8 | Phase 2 |
| 4 | Advanced Features | Recurring Tasks, Reminders, Keyboard Shortcuts | 5-7 | Phase 3 |
| 5 | Polish & Deploy | Dark Mode/Theming, Responsive Design, Performance, Deployment | 5-7 | Phase 4 |

## Phase Details

### Phase 1: Foundation
**Goal**: User can sign up (email/password + Google OAuth), log in, and see the main app layout with sidebar navigation.
**Features**:
- NextAuth authentication with email/password and Google OAuth
- Prisma schema with all 9 entities (User, Project, Task, Subtask, Tag, TaskTag, Reminder, Session, Account)
- Database migrations and seed data
- App layout with sidebar navigation (Projects list, Smart View links)
- Landing page / marketing page
- API health endpoint
**Prerequisites**: None

### Phase 2: Core Task Management
**Goal**: User can create, read, update, delete, and complete tasks with due dates, priority levels, subtasks, and natural language date input.
**Features**:
- Task CRUD API endpoints (create, read, update, delete, complete)
- Task list UI with inline creation
- Due date and time picker
- Natural language date parsing ("tomorrow", "next friday", "in 3 days")
- Priority levels (P1-P4) with visual indicators
- Subtasks/checklists within tasks
- Task detail panel/modal
- Optimistic UI updates
**Prerequisites**: Phase 1 complete

### Phase 3: Organization & Views
**Goal**: User can organize tasks into projects and use Smart Views (Today, Upcoming, Someday) to focus on what matters. Overdue tasks are handled gracefully without guilt.
**Features**:
- Project CRUD (create, rename, reorder, delete with task handling)
- Project-scoped task views
- 20-project free tier limit enforcement
- Smart View: Today (due today + manually added)
- Smart View: Upcoming (next 7 days, grouped by date)
- Smart View: Someday (no due date)
- Graceful overdue handling (separate "Overdue" section with easy reschedule)
- Task filtering and sorting within views
**Prerequisites**: Phase 2 complete

### Phase 4: Advanced Features
**Goal**: User can set up recurring tasks, receive reminders, and navigate the app efficiently with keyboard shortcuts.
**Features**:
- Recurring task rules (daily, weekly, monthly, custom)
- Recurring task completion spawns next occurrence
- Reminder creation (time-based)
- Reminder delivery (in-app notifications + email via Resend)
- Free tier reminder access (key differentiator)
- Keyboard shortcuts (n=new task, j/k=navigate, e=edit, d=done, esc=close)
- Keyboard shortcut help overlay (?)
**Prerequisites**: Phase 3 complete

### Phase 5: Polish & Deploy
**Goal**: App is production-ready with dark mode, responsive design, performance optimization, and deployment.
**Features**:
- Dark mode toggle with system preference detection
- Theme persistence (localStorage + user preference)
- Responsive design for tablet and mobile breakpoints
- Touch-friendly interactions for mobile
- Performance optimization (lazy loading, query optimization, caching)
- SEO and meta tags for landing page
- Error boundaries and error pages (404, 500)
- Production deployment configuration
- Health monitoring and logging
**Prerequisites**: Phase 4 complete
