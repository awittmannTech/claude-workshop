# Product Specification: Clarity Todo

## 1. Product Overview

### Vision
A fast, beautiful, web-first personal task manager that gives users everything they need for free -- the Things 3 experience, accessible on every platform.

### Problem Statement
Users of task management apps face a painful set of trade-offs:

1. **Subscription fatigue**: Todoist charges $4-5/mo and paywalls basic features like reminders. Over 60% of consumers are cutting subscriptions (Source: Hulry subscription fatigue analysis).
2. **Feature bloat**: TickTick, Notion, and others overwhelm users with features. A viral Hacker News post ("I tried every todo app and ended up with a .txt file") captured this frustration.
3. **Essential features paywalled**: Reminders, calendar views, and custom filters are locked behind $3-8/mo paywalls across Todoist, TickTick, and Any.do.
4. **Platform lock-in**: Things 3 is Apple-only ($80 total). MS To Do is tied to Microsoft. Google Tasks is tied to Google.
5. **Overdue task guilt**: Todoist's overdue items clutter the Today view, creating anxiety instead of helping users reschedule.

### Solution
Clarity Todo is a web-first personal task manager that combines Things 3's design taste and opinionated simplicity with a generous free tier, cross-platform access, and graceful overdue handling. It competes on design and speed, not feature count.

### Target Market
Individual professionals and small households who have tried major todo apps and found them either too complex (Todoist, TickTick, Notion) or too basic (Google Tasks, MS To Do). People who value design and speed but refuse to pay $5/month for a reminder feature.

- **TAM**: $1.43 billion (to-do list app market, 2025)
- **Growth**: 10.39% CAGR through 2035
- **Primary geo**: North America (34-42% market share)

### Anti-Positioning (What This Is NOT)
- NOT a project management tool (no Gantt charts, sprint boards, or resource allocation)
- NOT an enterprise collaboration platform (no admin dashboards or compliance features)
- NOT a Notion competitor (no databases, wikis, or knowledge management)
- NOT trying to replace your calendar app (complements it, does not replace it)

---

## 2. User Personas

### Persona 1: Alex -- The Frustrated Todoist User
- **Demographics**: 28-40, knowledge worker (developer, designer, writer), uses multiple devices
- **Goal**: Manage personal and work tasks without cognitive overload
- **Pain Points**: Paying $5/mo for reminders feels exploitative; Today view cluttered with overdue items; too many features they never use
- **Needs**: Clean UI, reminders included free, quick capture, keyboard shortcuts, cross-platform sync
- **Current Tools**: Todoist Free (frustrated by limits) or Todoist Pro (frustrated by cost)
- **Trigger to Switch**: Next Todoist price increase, or discovering a beautiful free alternative

### Persona 2: Maya -- The Things 3 Admirer on Windows
- **Demographics**: 25-35, creative professional or student, uses Windows/Android but admires Apple design
- **Goal**: A beautifully designed, opinionated task manager that works on any device
- **Pain Points**: Things 3 is Apple-only; Google Tasks is too basic; TickTick is too cluttered
- **Needs**: Beautiful design, fast performance, works in browser on any OS, simple project organization
- **Current Tools**: Google Tasks or MS To Do (settled, not satisfied)
- **Trigger to Switch**: Discovering a Things 3-quality experience in a web app

### Persona 3: Jordan -- The Simplicity Seeker
- **Demographics**: 22-45, anyone who has tried multiple todo apps and given up
- **Goal**: A task manager that reduces friction rather than adding it
- **Pain Points**: Tried Notion (too complex), TickTick (too many features), ended up with notes app or text file
- **Needs**: Zero learning curve, fast capture, no distracting features, progressive disclosure
- **Current Tools**: Apple Notes, plain text files, sticky notes
- **Trigger to Switch**: Finding an app that is genuinely as simple as a text file but with dates and reminders

---

## 3. Feature Specification

### Phase 1: Foundation (MVP Launch)

#### Feature 1: Authentication and User Management
- **User Story**: As a new user, I want to sign up quickly so that I can start managing tasks immediately.
- **Acceptance Criteria**:
  - Given a visitor on the landing page, when they click "Get Started," then they see a signup form with email/password fields and an OAuth option for Google.
  - Given a visitor filling out the signup form, when they submit a valid email and password (minimum 8 characters, at least one letter and one number), then an account is created, they are logged in, and redirected to the main app view within 2 seconds.
  - Given a visitor filling out the signup form, when they submit an email that is already registered, then they see an inline error message "An account with this email already exists" and a link to login.
  - Given a visitor choosing Google OAuth, when they complete the Google consent flow, then an account is created (or matched to existing), they are logged in, and redirected to the main app view.
  - Given a logged-in user, when they click their avatar/menu and select "Log out," then their session is destroyed and they are redirected to the landing page.
  - Given a user who has forgotten their password, when they click "Forgot password" and enter their registered email, then they receive a password reset email within 60 seconds with a link valid for 1 hour.
  - Given a user clicking a valid password reset link, when they enter a new password meeting requirements, then their password is updated and they are redirected to login.
- **Data Requirements**: User entity (id, email, name, passwordHash, avatarUrl, createdAt, updatedAt)
- **Edge Cases**:
  - Expired reset token: show "This link has expired. Please request a new one."
  - OAuth account tries email login without password set: prompt to set password or use OAuth
  - Concurrent sessions: allow multiple active sessions (no forced single-session)
- **Competitive Reference**: Todoist offers Google, Facebook, Apple OAuth. We start with Google OAuth only (simplest, broadest reach) and email/password.

#### Feature 2: Task CRUD (Create, Read, Update, Delete)
- **User Story**: As a user, I want to quickly create, view, edit, and delete tasks so that I can capture and manage what I need to do.
- **Acceptance Criteria**:
  - Given a logged-in user on any view, when they press the "Add Task" button or the keyboard shortcut `Q`, then a task creation input appears inline (not a modal) with the cursor focused in the title field.
  - Given a user in the task creation input, when they type a task title and press Enter, then the task is created with default settings (no due date, no priority, assigned to Inbox) and appears in the task list within 300ms.
  - Given a user in the task creation input, when they type a title with a natural language date (e.g., "Buy groceries tomorrow," "Call dentist next Friday," "Submit report Jan 15"), then the date is parsed and shown as a tag on the task, and the task is created with that due date.
  - Given a user viewing a task, when they click on the task title, then the task detail panel opens on the right side (desktop) or as a slide-up sheet (mobile) showing title, description, due date, priority, project, and subtasks.
  - Given a user editing a task, when they modify any field (title, description, due date, priority, project) and click away or press Escape, then changes are auto-saved within 500ms.
  - Given a user viewing a task, when they click the checkbox, then the task is marked complete with a satisfying animation (checkmark + strikethrough), and the task fades from the active list after 1 second.
  - Given a user who completed a task, when they view completed tasks (via filter), then the task appears in the completed list with its completion timestamp.
  - Given a user viewing a task, when they click the delete option (via context menu or detail panel), then a confirmation appears: "Delete this task? This cannot be undone." Upon confirming, the task is permanently deleted.
  - Given a user who just deleted a task, when the deletion occurs, then an undo toast appears for 5 seconds allowing them to restore the task.
- **Data Requirements**: Task entity (id, title, description, dueDate, dueTime, priority, isCompleted, completedAt, position, createdAt, updatedAt, userId, projectId)
- **Edge Cases**:
  - Empty title on submit: do not create the task, keep input focused
  - Very long title (>500 chars): truncate at 500 characters with warning
  - Rapid task creation (10+ tasks in succession): all tasks created correctly with correct ordering
  - Offline: queue creation, sync when connection restored (post-MVP)
- **Competitive Reference**: Todoist's natural language input is best-in-class. We implement basic date parsing (today, tomorrow, next Monday, specific dates) for MVP. Full NLP is post-MVP.

#### Feature 3: Projects (Lists) Organization
- **User Story**: As a user, I want to organize tasks into projects so that I can keep different areas of my life separate.
- **Acceptance Criteria**:
  - Given a logged-in user, when they first sign up, then a default "Inbox" project exists that cannot be deleted or renamed.
  - Given a user in the sidebar, when they click "Add Project," then a form appears with fields for project name (required) and color (optional, defaults to system color).
  - Given a user creating a project, when they submit a name, then the project appears in the sidebar below existing projects within 300ms.
  - Given a user with multiple projects, when they view the sidebar, then projects are listed in user-defined order and each shows an unread/pending task count badge.
  - Given a user viewing a project, when they click it in the sidebar, then the main content area shows only tasks belonging to that project, ordered by the user's chosen sort order.
  - Given a user, when they drag a project in the sidebar, then the project is reordered and the new order persists across sessions.
  - Given a user on the free tier, when they have fewer than 20 projects, then they can create new projects without restriction.
  - Given a user editing a project, when they change the name or color, then the change is reflected everywhere (sidebar, task detail, breadcrumbs) within 500ms.
  - Given a user deleting a project, when they confirm deletion, then all tasks in the project are moved to Inbox (not deleted) and the project is removed.
- **Data Requirements**: Project entity (id, name, color, position, isDefault, createdAt, updatedAt, userId)
- **Edge Cases**:
  - Deleting a project with 100+ tasks: all tasks moved to Inbox, user sees confirmation with task count
  - Duplicate project names: allowed (users may want "Work" in different contexts)
  - Free tier at 20 projects: show message "Upgrade to Premium for unlimited projects"
- **Competitive Reference**: Todoist limits free to 5 projects. TickTick limits to 9 lists. Our 20-project free tier is significantly more generous.

#### Feature 4: Due Dates and Times
- **User Story**: As a user, I want to set due dates and optional times on tasks so that I know when things need to be done.
- **Acceptance Criteria**:
  - Given a user editing a task, when they click the date field, then a date picker appears with calendar UI showing the current month with today highlighted.
  - Given a user in the date picker, when they select a date, then the due date is set and displayed in a human-readable relative format ("Today," "Tomorrow," "Mon, Mar 16," etc.).
  - Given a user with a date selected, when they toggle "Add time," then a time picker appears allowing them to set a specific time (hour:minute, AM/PM).
  - Given a user in the task creation input, when they type natural language dates ("tomorrow," "next friday," "mar 15," "in 3 days"), then the date is automatically parsed and applied.
  - Given a task with a due date of today, when the user views the Today smart view, then the task appears in that view.
  - Given a task whose due date has passed, when the user views the Today view, then the task appears in a clearly separated "Overdue" section at the top, styled distinctly (e.g., red text or badge) but not overwhelming.
  - Given a user clearing a due date, when they click the "X" on the date tag, then the due date is removed and the task no longer appears in date-filtered views.
- **Data Requirements**: Fields on Task entity: dueDate (Date, nullable), dueTime (Time, nullable)
- **Edge Cases**:
  - Past dates: allowed (user may be logging completed work)
  - Time without date: not allowed; time requires a date
  - Timezone: all dates stored in UTC, displayed in user's local timezone
  - Ambiguous NLP ("next week"): defaults to next Monday
- **Competitive Reference**: Google Tasks only supports dates, not times. Todoist supports both. We match Todoist's capability here.

#### Feature 5: Priority Levels
- **User Story**: As a user, I want to set priority levels on tasks so that I can focus on what matters most.
- **Acceptance Criteria**:
  - Given a user creating or editing a task, when they click the priority flag icon, then they see 4 options: P1 (Urgent, red), P2 (High, orange), P3 (Medium, blue), P4 (None, gray/default).
  - Given a user selecting a priority, when applied, then the task displays a colored flag indicator matching the priority level.
  - Given a user viewing a project or smart view, when they choose "Sort by priority," then tasks are ordered P1 first, then P2, P3, P4, with consistent ordering within the same priority level (by creation date, newest first).
  - Given a user creating a task without setting priority, then the task defaults to P4 (None).
  - Given a user pressing keyboard shortcuts `1`, `2`, `3`, or `4` while a task is selected, then the priority is set to P1, P2, P3, or P4 respectively.
- **Data Requirements**: priority field on Task entity (integer, 1-4, default 4)
- **Edge Cases**:
  - Bulk priority change: not in MVP (single task only)
- **Competitive Reference**: Todoist uses P1-P4 with colors. MS To Do has no priority system. We match Todoist.

#### Feature 6: Subtasks (Checklists)
- **User Story**: As a user, I want to break tasks into subtasks so that I can track progress on multi-step work.
- **Acceptance Criteria**:
  - Given a user viewing a task's detail panel, when they click "Add subtask," then a text input appears below existing subtasks.
  - Given a user typing a subtask title, when they press Enter, then the subtask is created and a new empty input appears below it for rapid entry.
  - Given a user pressing Enter on an empty subtask input, then the input closes (stop adding subtasks).
  - Given a task with subtasks, when the user views it in the task list, then a progress indicator shows (e.g., "2/5" or a small progress bar).
  - Given a user completing a subtask, when they check its checkbox, then it is marked complete with a strikethrough and the progress indicator updates.
  - Given a user dragging a subtask, when they drop it at a new position, then the subtask order is updated and persisted.
  - Given a user completing all subtasks, then the parent task is NOT auto-completed (user must explicitly complete it).
  - Given a user deleting a subtask, then it is removed immediately without confirmation (subtasks are lightweight).
- **Data Requirements**: Subtask entity (id, title, isCompleted, position, createdAt, taskId)
- **Edge Cases**:
  - Maximum 20 subtasks per task (prevents misuse as a project)
  - Deleting parent task: all subtasks are deleted with it
  - Empty subtask title: not created
- **Competitive Reference**: Todoist supports subtasks as full tasks (nested). Things 3 uses simple checklists. We use the simpler checklist model (like Things 3) for MVP.

#### Feature 7: Smart Views (Today, Upcoming, Someday)
- **User Story**: As a user, I want pre-built views that filter my tasks by time horizon so that I can focus on what matters now.
- **Acceptance Criteria**:
  - Given a logged-in user, when they click "Today" in the sidebar, then they see all tasks due today and overdue tasks in a separate "Overdue" section.
  - Given a logged-in user, when they click "Upcoming" in the sidebar, then they see tasks grouped by date for the next 14 days, with each day as a collapsible section header.
  - Given a logged-in user, when they click "Someday" in the sidebar, then they see all tasks with no due date, organized by project.
  - Given a user viewing Today with overdue tasks, when they see the Overdue section, then each overdue task shows how many days overdue it is (e.g., "2 days overdue") in a muted red style (not alarming).
  - Given a user in the Today view, when they right-click an overdue task, then the context menu includes "Reschedule to today," "Reschedule to tomorrow," "Remove date," and "Pick a date."
  - Given the Today view, when there are no tasks, then a friendly empty state is shown (illustration + "Nothing due today. Enjoy your freedom.").
  - Given the Upcoming view, when a day has no tasks, then that day is not shown (no empty day slots).
- **Data Requirements**: No additional entities. Smart views are computed from Task.dueDate.
- **Edge Cases**:
  - User in different timezone than when task was created: display dates in current timezone
  - 50+ overdue tasks: show count and a "Review all overdue" button that opens a triage mode (can reschedule in bulk -- post-MVP, for now just list them)
  - Tasks with time: sorted by time within the same day
- **Competitive Reference**: Things 3 has Today/Upcoming/Anytime/Someday. Todoist has Today/Upcoming. MS To Do has "My Day." Our model follows Things 3's approach.

#### Feature 8: Recurring Tasks
- **User Story**: As a user, I want to create recurring tasks so that I don't have to re-enter routine items.
- **Acceptance Criteria**:
  - Given a user editing a task's due date, when they click "Repeat," then they see options: Daily, Weekly (choose days), Monthly (choose date), Yearly, and Custom.
  - Given a user setting "Weekly on Monday and Wednesday," when they complete the task, then a new instance of the task is created with the next applicable due date (the next Monday or Wednesday).
  - Given a user with a daily recurring task, when they complete today's instance, then a new task appears with tomorrow's date.
  - Given a user editing a recurring task, when they change the title or description, then the change applies only to this instance (not future instances).
  - Given a user deleting a recurring task, when they confirm, then they see "Delete this instance" or "Delete all future instances."
  - Given a recurring task that the user does not complete by its due date, then the next instance is NOT created until the current one is completed (no stacking of overdue instances).
- **Data Requirements**: Fields on Task entity: recurrenceRule (string, nullable, iCal RRULE format), recurrenceParentId (self-reference, nullable)
- **Edge Cases**:
  - "Monthly on the 31st": on months without 31 days, use last day of month
  - Completing a recurring task from Someday view: not applicable (recurring tasks always have dates)
  - Very frequent recurrence (every hour): not supported in MVP; minimum interval is daily
- **Competitive Reference**: Todoist gates reminders behind Pro but includes recurring tasks free. TickTick includes recurring free. We include recurring free.

#### Feature 9: Reminders (FREE)
- **User Story**: As a user, I want to set reminders for tasks so that I get notified before deadlines.
- **Acceptance Criteria**:
  - Given a user editing a task with a due date and time, when they click "Add reminder," then they see options: "At time of due date," "5 minutes before," "15 minutes before," "30 minutes before," "1 hour before," "1 day before," and "Custom."
  - Given a user with a reminder set, when the reminder time arrives, then a browser notification is sent (if permissions granted) and an in-app notification badge appears.
  - Given a user who has not granted notification permissions, when they set their first reminder, then a prompt explains why notifications are useful and asks for permission.
  - Given a user dismissing a browser notification, then the in-app notification is marked as read.
  - Given a user on the free tier, when they add a reminder, then it works without restriction (reminders are free, not paywalled).
  - Given a user per task, when they add reminders, then they can set up to 2 reminders per task on free tier.
- **Data Requirements**: Reminder entity (id, remindAt, isSent, isDismissed, taskId, userId)
- **Edge Cases**:
  - Browser tab is closed at reminder time: notification not delivered (we do not have push notification infrastructure for MVP; in-app badge shows on next visit)
  - Task completed before reminder fires: reminder is cancelled
  - Task date changed: reminders based on relative offsets recalculate; absolute-time reminders stay unchanged
- **Competitive Reference**: Todoist paywalls reminders behind Pro ($4/mo). This is our single most important free-tier differentiator.

#### Feature 10: Dark Mode and Theming
- **User Story**: As a user, I want to switch between light and dark mode so that the app is comfortable to use at any time of day.
- **Acceptance Criteria**:
  - Given a user opening the app for the first time, when their OS is set to dark mode, then the app defaults to dark mode.
  - Given a user in settings, when they select a theme (Light, Dark, System), then the app immediately switches and the preference persists across sessions.
  - Given a user in dark mode, when they view any page, then all text meets WCAG 2.1 AA contrast ratios (minimum 4.5:1 for body text, 3:1 for large text).
  - Given any theme, when the user views the app, then all interactive elements (buttons, links, inputs) are clearly distinguishable from non-interactive elements.
- **Data Requirements**: theme preference stored in User entity (string: "light" | "dark" | "system")
- **Edge Cases**:
  - System theme changes while app is open: if set to "System," app follows the change in real time
  - Custom theme colors: not in MVP (Phase 2 premium feature)
- **Competitive Reference**: TickTick and Any.do gate themes behind premium. We include light/dark/system free.

#### Feature 11: Responsive Web App
- **User Story**: As a user, I want to use the app on my phone, tablet, or desktop browser so that I can manage tasks from any device.
- **Acceptance Criteria**:
  - Given a user on a desktop browser (viewport >= 1024px), when they view the app, then a sidebar navigation is visible on the left with the main content area on the right and a task detail panel on the far right.
  - Given a user on a tablet (viewport 768-1023px), when they view the app, then the sidebar is collapsible (hamburger menu) and the detail panel overlays the content area.
  - Given a user on a mobile device (viewport < 768px), when they view the app, then navigation is via a bottom tab bar, the task list is full-width, and the detail panel is a full-screen slide-up sheet.
  - Given a user on any device, when they interact with the app, then all touch targets are at least 44x44 CSS pixels.
  - Given a user on a mobile device, when they pull down on the task list, then a pull-to-refresh animation triggers and the list reloads.
  - Given a user on any viewport, when they resize the browser, then the layout adapts fluidly without horizontal scrolling or overlapping elements.
- **Data Requirements**: None (responsive is a UI concern).
- **Edge Cases**:
  - Very small viewport (<320px): not officially supported, but no broken layout
  - Landscape mobile: task list fills available space, no fixed sidebar
  - Slow connection (3G): initial page load under 3 seconds; skeleton screens shown while data loads
- **Competitive Reference**: Things 3 has no web app at all. This is a core differentiator.

#### Feature 12: Keyboard Shortcuts
- **User Story**: As a power user, I want keyboard shortcuts so that I can manage tasks without touching the mouse.
- **Acceptance Criteria**:
  - Given a logged-in user on desktop, when they press `Q`, then the quick-add task input opens.
  - Given a user viewing a task list, when they press `J`/`K` (or arrow keys), then the selection moves down/up the list.
  - Given a task selected, when the user presses `Enter`, then the task detail panel opens.
  - Given a task selected, when the user presses `E`, then the task title becomes editable inline.
  - Given a task selected, when the user presses `Space`, then the task is toggled complete/incomplete.
  - Given a task selected, when the user presses `#`, then a project picker appears.
  - Given a task selected, when the user presses `D`, then the date picker opens.
  - Given a user pressing `?`, then a keyboard shortcut overlay/cheat sheet is shown.
  - Given a user in a text input field, when they press any shortcut key, then the shortcut does NOT fire (typing takes precedence).
- **Data Requirements**: None.
- **Edge Cases**:
  - Conflict with browser shortcuts: avoid Ctrl+key combos that conflict with browser defaults
  - Screen reader active: shortcuts should not interfere with screen reader navigation
- **Competitive Reference**: Todoist and Things 3 both have excellent keyboard shortcuts. This is table stakes for power users.

### Phase 2: Post-MVP (1-2 Months After Launch)

#### Feature 13: Calendar View (FREE)
- **User Story**: As a user, I want a calendar view of my tasks so that I can see my schedule at a glance.
- **Acceptance Criteria**:
  - Given a user clicking "Calendar" in the sidebar, when the view loads, then a week view is shown by default with tasks placed on their due dates.
  - Given a user in calendar view, when they drag a task from one day to another, then the task's due date is updated.
  - Given a user in calendar view, when they click on an empty time slot, then the quick-add input opens pre-filled with that date.
  - Given a user on the free tier, when they access calendar view, then it works without restriction (calendar is free, not paywalled).
- **Data Requirements**: No additional entities. Calendar is a view layer over existing Task data.
- **Competitive Reference**: Todoist paywalls calendar view. TickTick's calendar is its strongest feature. Ours is free.

#### Feature 14: Tags/Labels
- **User Story**: As a user, I want to tag tasks so that I can categorize and filter across projects.
- **Acceptance Criteria**:
  - Given a user editing a task, when they type `@` followed by a label name, then matching existing labels are suggested, or a new label can be created.
  - Given a user with tagged tasks, when they click a tag in the sidebar, then all tasks with that tag are shown regardless of project.
  - Given a user on the free tier, when they create tags, then they can have up to 10 tags.
- **Data Requirements**: Tag entity (id, name, color, userId). TaskTag join table (taskId, tagId).
- **Competitive Reference**: Todoist includes labels free. We match this.

#### Feature 15: Data Export
- **User Story**: As a user, I want to export my data so that I am never locked in.
- **Acceptance Criteria**:
  - Given a user in Settings, when they click "Export Data," then they can choose JSON or CSV format.
  - Given a user initiating an export, when the export completes, then a downloadable file is generated containing all tasks, projects, tags, and subtasks.
  - Given the exported JSON, when opened in a text editor, then the schema is documented and human-readable.
- **Data Requirements**: None (export is a read operation on existing data).
- **Competitive Reference**: No major competitor makes export easy. This builds trust and addresses data ownership concerns.

---

## 4. Data Model

### Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| User | Registered user account | id (UUID), email (unique), name, passwordHash (nullable for OAuth), avatarUrl, theme ("light"/"dark"/"system"), plan ("free"/"premium"), createdAt, updatedAt |
| Project | A list/folder for organizing tasks | id (UUID), name, color (hex string), position (int), isDefault (boolean), userId (FK), createdAt, updatedAt |
| Task | A single to-do item | id (UUID), title, description (text, nullable), dueDate (date, nullable), dueTime (time, nullable), priority (int, 1-4, default 4), isCompleted (boolean), completedAt (datetime, nullable), position (int), recurrenceRule (string, nullable), recurrenceParentId (UUID, nullable, self-ref), userId (FK), projectId (FK), createdAt, updatedAt |
| Subtask | A checklist item within a task | id (UUID), title, isCompleted (boolean), position (int), taskId (FK), createdAt |
| Tag | A label for cross-project categorization | id (UUID), name, color (hex string, nullable), userId (FK), createdAt |
| TaskTag | Join table for many-to-many Task-Tag | taskId (FK), tagId (FK) |
| Reminder | A scheduled notification for a task | id (UUID), remindAt (datetime), offsetMinutes (int, nullable), isSent (boolean), isDismissed (boolean), taskId (FK), userId (FK), createdAt |
| Session | Authentication session | id (UUID), userId (FK), expiresAt (datetime), createdAt |
| Account | OAuth provider account (NextAuth) | id (UUID), userId (FK), provider, providerAccountId, accessToken, refreshToken, expiresAt |

### Relationships

```
User 1 --- * Project      (user has many projects)
User 1 --- * Task          (user has many tasks)
User 1 --- * Tag           (user has many tags)
User 1 --- * Reminder      (user has many reminders)
User 1 --- * Session       (user has many sessions)
User 1 --- * Account       (user has many OAuth accounts)

Project 1 --- * Task       (project has many tasks)

Task 1 --- * Subtask       (task has many subtasks)
Task 1 --- * Reminder      (task has many reminders)
Task * --- * Tag            (many-to-many via TaskTag)
Task 1 --- ? Task           (recurrenceParentId self-reference)
```

### Key Queries (Indexed)

1. **Tasks by user + project**: `WHERE userId = ? AND projectId = ? AND isCompleted = false ORDER BY position` (primary task list view)
2. **Today view**: `WHERE userId = ? AND isCompleted = false AND dueDate <= CURRENT_DATE ORDER BY dueDate ASC, priority ASC`
3. **Upcoming view**: `WHERE userId = ? AND isCompleted = false AND dueDate BETWEEN CURRENT_DATE AND CURRENT_DATE + 14 ORDER BY dueDate ASC`
4. **Someday view**: `WHERE userId = ? AND isCompleted = false AND dueDate IS NULL ORDER BY projectId, position`
5. **Pending reminders**: `WHERE isSent = false AND remindAt <= NOW()` (background job query)
6. **Tasks by tag**: `JOIN TaskTag ON ... WHERE tagId = ? AND isCompleted = false`

### Database Indexes

- `Task(userId, isCompleted, dueDate)` -- composite index for smart views
- `Task(userId, projectId, isCompleted, position)` -- composite index for project views
- `Reminder(isSent, remindAt)` -- for reminder processing job
- `User(email)` -- unique index for auth lookup
- `TaskTag(taskId, tagId)` -- composite unique index

---

## 5. API Design

All endpoints are under `/api` and return JSON. Authentication is required unless noted. Errors follow the format `{ "error": { "code": string, "message": string } }`.

### Authentication

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /api/auth/signup | Create account (email/password) | No |
| POST | /api/auth/login | Login (email/password) | No |
| POST | /api/auth/logout | Destroy session | Required |
| POST | /api/auth/forgot-password | Send reset email | No |
| POST | /api/auth/reset-password | Reset password with token | No |
| GET | /api/auth/session | Get current session/user | Required |
| GET/POST | /api/auth/[...nextauth] | NextAuth.js OAuth routes | No |

### Tasks

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/tasks | List tasks (with query filters: projectId, dueDate, priority, isCompleted, tagId) | Required |
| POST | /api/tasks | Create a task | Required |
| GET | /api/tasks/:id | Get single task with subtasks and reminders | Required |
| PATCH | /api/tasks/:id | Update task fields | Required |
| DELETE | /api/tasks/:id | Delete task (and its subtasks/reminders) | Required |
| POST | /api/tasks/:id/complete | Mark task complete (handles recurrence) | Required |
| POST | /api/tasks/:id/uncomplete | Mark task incomplete | Required |
| PATCH | /api/tasks/reorder | Update position of multiple tasks | Required |

### Smart Views

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/views/today | Tasks due today + overdue | Required |
| GET | /api/views/upcoming | Tasks due in next 14 days, grouped by date | Required |
| GET | /api/views/someday | Tasks with no due date | Required |

### Projects

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/projects | List user's projects with task counts | Required |
| POST | /api/projects | Create project | Required |
| PATCH | /api/projects/:id | Update project name/color | Required |
| DELETE | /api/projects/:id | Delete project (moves tasks to Inbox) | Required |
| PATCH | /api/projects/reorder | Update project positions | Required |

### Subtasks

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /api/tasks/:taskId/subtasks | Create subtask | Required |
| PATCH | /api/tasks/:taskId/subtasks/:id | Update subtask | Required |
| DELETE | /api/tasks/:taskId/subtasks/:id | Delete subtask | Required |
| PATCH | /api/tasks/:taskId/subtasks/reorder | Reorder subtasks | Required |

### Tags (Phase 2)

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/tags | List user's tags | Required |
| POST | /api/tags | Create tag | Required |
| PATCH | /api/tags/:id | Update tag | Required |
| DELETE | /api/tags/:id | Delete tag (remove from tasks) | Required |
| POST | /api/tasks/:taskId/tags | Add tag to task | Required |
| DELETE | /api/tasks/:taskId/tags/:tagId | Remove tag from task | Required |

### Reminders

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /api/tasks/:taskId/reminders | Create reminder | Required |
| DELETE | /api/tasks/:taskId/reminders/:id | Delete reminder | Required |
| GET | /api/reminders/pending | Get pending in-app notifications | Required |
| POST | /api/reminders/:id/dismiss | Dismiss a notification | Required |

### User

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/user/profile | Get current user profile | Required |
| PATCH | /api/user/profile | Update name, avatar, theme | Required |
| POST | /api/user/export | Generate data export (JSON or CSV) | Required |
| DELETE | /api/user/account | Delete account and all data | Required |

### Health

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/health | Health check (DB connection, uptime) | No |

---

## 6. User Flows

### Flow 1: New User Signup
```
[Landing Page] --> [Click "Get Started"]
  --> [Signup Form: email + password OR Google OAuth]
  --> [Account Created] --> [Default Inbox project created]
  --> [Onboarding: "Add your first task" prompt with example]
  --> [Main App View (Inbox selected)]
```

**Error Flow**:
```
[Signup Form] --> [Submit with existing email]
  --> [Inline error: "Account exists. Log in instead?"]
  --> [Click "Log in"] --> [Login Form]
```

### Flow 2: Quick Task Creation
```
[Any View] --> [Press Q or click "+ Add Task"]
  --> [Inline input appears, cursor focused]
  --> [Type: "Buy groceries tomorrow p1"]
  --> [Date parsed as tomorrow, priority set to P1]
  --> [Press Enter]
  --> [Task created in current project, appears in list]
  --> [Input stays open for next task (or Escape to close)]
```

**Error Flow**:
```
[Quick Add] --> [Press Enter with empty title]
  --> [Nothing happens, input stays focused]
  --> [User types title, presses Enter]
  --> [Task created successfully]
```

### Flow 3: Task Completion
```
[Task List] --> [Click checkbox on task]
  --> [Checkmark animation + strikethrough]
  --> [Task fades from list after 1 second]
  --> [If recurring: new instance created with next due date]
  --> [Undo toast appears for 5 seconds]
```

**Undo Flow**:
```
[Task completed] --> [Undo toast visible]
  --> [Click "Undo"] --> [Task restored to incomplete, back in list]
```

### Flow 4: Overdue Task Handling
```
[User opens app with overdue tasks]
  --> [Today View loads]
  --> [Overdue section at top: "3 tasks overdue"]
  --> [Each task shows "2 days overdue" in muted red]
  --> [Right-click overdue task]
  --> [Context menu: "Today" | "Tomorrow" | "Pick date" | "Remove date"]
  --> [Select "Tomorrow"] --> [Task moved to tomorrow, leaves Overdue section]
```

### Flow 5: Project Organization
```
[Sidebar] --> [Click "+ Add Project"]
  --> [Name input + color picker]
  --> [Type "Work" and select blue]
  --> [Press Enter] --> [Project appears in sidebar]
  --> [Click project] --> [Empty project view with "Add a task" prompt]
  --> [Create tasks within project]
```

### Flow 6: Setting a Reminder
```
[Task Detail Panel] --> [Click "Add reminder"]
  --> [Options: "At due time" | "15 min before" | "1 hour before" | "1 day before" | "Custom"]
  --> [Select "1 hour before"]
  --> [Reminder badge appears on task]
  --> [At reminder time: browser notification fires + in-app badge]
```

**Permission Flow**:
```
[First reminder set] --> [Browser asks notification permission]
  --> [User denies] --> [Reminder still created, in-app badge only]
  --> [Settings show: "Enable browser notifications for reminders"]
```

### Flow 7: Password Reset
```
[Login Page] --> [Click "Forgot password?"]
  --> [Enter email] --> [Submit]
  --> [Success message: "Check your email"]
  --> [Email arrives with reset link (valid 1 hour)]
  --> [Click link] --> [New password form]
  --> [Enter new password] --> [Submit]
  --> [Success: "Password updated. Log in."]
  --> [Login form]
```

---

## 7. UI/UX Principles

### Design Philosophy
1. **Speed is a feature**: Every interaction should feel instant. Optimistic updates for all mutations. Skeleton loading states, never spinners on primary actions.
2. **Progressive disclosure**: The default view is minimal. Power features (shortcuts, recurring, priorities) are discoverable but not in your face.
3. **Opinionated defaults**: We make decisions so users don't have to. Inbox exists by default. Priorities are 4 levels, not customizable. Views are predefined, not user-built.
4. **Calm over anxious**: Overdue tasks are noted, not screamed. Completion is celebrated with subtle animation, not gamified streaks. Empty states are friendly, not guilt-inducing.
5. **Dense but not cramped**: Show as many tasks as possible on screen. Compact row heights. Minimal padding. But never sacrifice readability.

### Visual Design
- **Typography**: Inter (or system font stack) for UI. 14px base, 13px compact views.
- **Colors**: Neutral gray palette with a single accent color (blue). Priority colors (red, orange, blue, gray). Project colors user-selected.
- **Spacing**: 4px grid system. Consistent spacing tokens.
- **Animation**: Subtle, functional. Checkbox completion (200ms ease-out). Task fade-out on complete (300ms). Panel slide-in (200ms). No decorative animations.
- **Density**: Task rows should be 36-40px height. Sidebar items 32px height. Maximize visible tasks per screen.

### Layout
- **Desktop**: 3-column layout (Sidebar 240px | Task List flex | Detail Panel 360px)
- **Tablet**: 2-column (collapsible sidebar | Task List flex, detail as overlay)
- **Mobile**: Single column with bottom tab bar (Today | Upcoming | Projects | Settings)

### Accessibility
- All interactive elements are keyboard accessible
- ARIA labels on all icon-only buttons
- Focus visible indicators on all focusable elements
- Color is never the only indicator (always paired with icon or text)
- Screen reader tested with VoiceOver and NVDA

---

## 8. Pricing Strategy

### Free Tier
- Unlimited tasks
- Up to 20 projects
- Subtasks (up to 20 per task)
- Due dates with times
- Priority levels
- Recurring tasks
- Reminders (up to 2 per task)
- Smart views (Today, Upcoming, Someday)
- Calendar view (Phase 2)
- Dark mode and system theme
- Data export
- Up to 10 tags (Phase 2)

### Premium Tier -- $3/month (annual, $36/year) or $4/month (monthly)
- Everything in Free, plus:
- Unlimited projects
- Unlimited reminders per task
- Unlimited tags
- Custom filters and saved views
- AI task suggestions and breakdown (future)
- Productivity statistics and analytics (future)
- Custom themes and colors (future)
- Priority email support
- Early access to new features

### Lifetime Deal -- $49 (introductory) / $79 (regular)
- Everything in Premium, forever
- Addresses subscription fatigue directly
- Competes with Things 3's pricing model ($80 across Apple platforms)
- Available during launch period at $49, increases to $79

### Pricing Rationale
- **Free tier is more generous than Todoist** (reminders + calendar + 20 projects vs. 5 projects + no reminders)
- **Premium undercuts Todoist** ($3/mo vs $4/mo annual)
- **Lifetime matches Things 3** ($49-79 vs $80, but cross-platform)
- **Gate AI and analytics, not basics**: Reminders, calendar view, and themes are NOT paywalled (top user complaint about competitors)

---

## 9. Non-Functional Requirements

### Performance
- **Initial page load**: < 2 seconds on 3G connection (Lighthouse performance score > 90)
- **Time to interactive**: < 3 seconds on 3G
- **API response time**: < 200ms p95 for all CRUD operations
- **Task creation latency**: < 300ms perceived (optimistic update)
- **Search/filter**: < 500ms for up to 10,000 tasks
- **Bundle size**: < 150KB gzipped JavaScript (initial load)
- **Database queries**: < 50ms p95 for indexed queries

### Security
- **Authentication**: NextAuth.js with JWT sessions (stateless, horizontally scalable)
- **Password storage**: bcrypt with cost factor 12
- **CSRF protection**: built-in via Next.js server actions and same-site cookies
- **Rate limiting**: 100 requests/minute per IP on auth endpoints, 600 requests/minute on API endpoints
- **Input validation**: Zod schemas on all API inputs (server-side)
- **SQL injection**: prevented via Prisma parameterized queries
- **XSS prevention**: React's built-in escaping + Content-Security-Policy headers
- **HTTPS**: enforced via deployment platform (Vercel)
- **Data isolation**: all queries scoped by userId (row-level security via application layer)

### Accessibility (WCAG 2.1 AA)
- All text meets 4.5:1 contrast ratio (body) and 3:1 (large text)
- All functionality accessible via keyboard
- Focus management on view transitions and modal open/close
- ARIA landmarks on all page regions
- Screen reader announcements for dynamic content changes (task created, completed, deleted)
- Reduced motion support via `prefers-reduced-motion` media query
- Touch targets minimum 44x44 CSS pixels on mobile

### Scalability
- **Launch**: support 1,000 users, 100,000 tasks
- **6 months**: support 10,000 users, 1,000,000 tasks
- **1 year**: support 50,000 users, 5,000,000 tasks
- **Architecture**: stateless Next.js on Vercel (auto-scaling), PostgreSQL on managed service (vertically scalable), connection pooling via Prisma Accelerate or PgBouncer

### Reliability
- **Uptime target**: 99.5% (allows ~1.8 days downtime/year)
- **Backup**: daily automated database backups with 30-day retention
- **Data durability**: PostgreSQL WAL + managed service replication
- **Error tracking**: Sentry for client and server errors
- **Monitoring**: Vercel Analytics + custom health check endpoint

### Browser Support
- Chrome/Edge 90+ (last 2 years)
- Firefox 90+ (last 2 years)
- Safari 15+ (last 2 years)
- Mobile Safari (iOS 15+)
- Chrome for Android (last 2 years)

---

## 10. Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Framework | Next.js 14+ (App Router) | Full-stack React with SSR, API routes, server actions |
| Language | TypeScript | Type safety across frontend and backend |
| Database | PostgreSQL | Reliable, scalable, excellent for relational task data |
| ORM | Prisma | Type-safe queries, migrations, schema management |
| Authentication | NextAuth.js (Auth.js) | OAuth + credentials, session management |
| Styling | Tailwind CSS | Utility-first, fast iteration, small bundle |
| Components | shadcn/ui | Accessible, customizable, not a dependency (copied into project) |
| Validation | Zod | Schema validation shared between client and server |
| Date Parsing | chrono-node | Natural language date parsing library |
| Date Display | date-fns | Lightweight date formatting and manipulation |
| Deployment | Vercel | Zero-config Next.js hosting, edge functions, analytics |
| Database Hosting | Vercel Postgres or Neon | Managed PostgreSQL with connection pooling |
| Email | Resend | Transactional email for password reset, reminders |
| Error Tracking | Sentry | Client + server error monitoring |
| Testing | Vitest (unit) + Playwright (e2e) | Fast unit tests + reliable browser testing |

---

## 11. Prerequisites

- [ ] **Vercel Account**: For hosting Next.js app and Vercel Postgres (or Neon)
- [ ] **PostgreSQL Database**: Vercel Postgres, Neon, or Supabase -- connection string needed as `DATABASE_URL`
- [ ] **Google OAuth Credentials**: Google Cloud Console project with OAuth 2.0 client ID and secret (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`)
- [ ] **NextAuth Secret**: Random string for JWT signing (`NEXTAUTH_SECRET` -- generate via `openssl rand -base64 32`)
- [ ] **NextAuth URL**: Deployment URL (`NEXTAUTH_URL`, e.g., `http://localhost:3000` for dev)
- [ ] **Resend API Key**: For transactional email -- password reset and reminder notifications (`RESEND_API_KEY`)
- [ ] **Resend Verified Domain**: A domain verified in Resend for sending from (e.g., `noreply@clarityapp.com`)
- [ ] **Sentry DSN** (optional for MVP): For error tracking (`SENTRY_DSN`)
- [ ] **Node.js 18+**: Runtime requirement
- [ ] **Domain Name** (optional for MVP): Custom domain for production deployment

### Environment Variables Summary

```env
# Database
DATABASE_URL=postgresql://...

# Auth
NEXTAUTH_SECRET=<random-32-char-string>
NEXTAUTH_URL=http://localhost:3000
GOOGLE_CLIENT_ID=<from-google-console>
GOOGLE_CLIENT_SECRET=<from-google-console>

# Email
RESEND_API_KEY=<from-resend-dashboard>
RESEND_FROM_EMAIL=noreply@clarityapp.com

# Error Tracking (optional)
SENTRY_DSN=<from-sentry>

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## 12. Out of Scope (MVP Exclusions)

The following are explicitly NOT part of the MVP and should not be built:

1. **Native mobile apps** (iOS/Android) -- web app with responsive design is the MVP strategy
2. **Offline mode / local-first storage** -- requires service worker complexity; post-MVP
3. **Push notifications** (mobile/desktop) -- browser notifications only for MVP
4. **Collaboration / shared lists** -- personal task management only for launch
5. **Third-party integrations** (Google Calendar sync, Slack, Zapier) -- post-MVP
6. **AI features** (smart suggestions, task breakdown, NLP beyond date parsing) -- premium post-MVP
7. **Pomodoro timer / focus mode** -- post-MVP
8. **Habit tracking** -- post-MVP
9. **Statistics / productivity analytics** -- premium post-MVP
10. **Location-based reminders** -- requires geolocation API; post-MVP
11. **File attachments on tasks** -- post-MVP
12. **Multi-language / i18n** -- English only for MVP
13. **Admin dashboard / team workspaces** -- against anti-positioning
14. **Kanban / board views** -- against simplicity principle
15. **Import from other apps** (Todoist, TickTick) -- post-MVP (export is in scope, import is not)
16. **Custom filters / saved views** -- premium post-MVP
17. **Weekly review / reflection prompts** -- post-MVP
18. **Calendar subscriptions (iCal feed)** -- post-MVP
19. **API for third-party developers** -- post-MVP
20. **SSO / SAML authentication** -- enterprise feature, out of scope entirely
