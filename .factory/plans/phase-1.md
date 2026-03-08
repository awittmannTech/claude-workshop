# Phase 1 Plan: Foundation

## Goal
A visitor can land on the marketing page, sign up with email/password or Google OAuth, log in, and arrive at a fully-structured app shell with sidebar navigation showing Smart View links and a Projects list. The database schema for the entire product is in place from day one so that future phases never need a destructive migration.

## Features (from Spec)
1. **Authentication** — Email/password signup + login, Google OAuth via NextAuth.js v5, logout. (Spec §3 Feature 1)
2. **Complete Prisma schema** — All 9 entities: User, Project, Task, Subtask, Tag, TaskTag, Reminder, Session, Account. All indexes. (Spec §4)
3. **Database migration + seed** — Automated migration; seed creates a demo user with an Inbox project.
4. **App layout with sidebar** — Protected shell with sidebar showing Smart Views (Today, Upcoming, Someday) and Projects list placeholder. (Spec §3 Feature 3, Feature 7, Feature 11)
5. **Landing / marketing page** — Public route at `/` with hero section and "Get Started" CTA. (Spec §6 Flow 1)
6. **API health endpoint** — `GET /api/health` returning DB status and uptime. (Spec §5 Health)

---

## Task Breakdown

### Wave 1 — Project Bootstrap (no dependencies)

| # | Task | Description | Files to Create / Modify | Dependencies | Tests Needed |
|---|------|-------------|--------------------------|--------------|--------------|
| 1.1 | Next.js project init | Scaffold a new Next.js 14 App Router project with TypeScript, Tailwind CSS, ESLint. Use `pnpm create next-app`. Configure `tsconfig.json`, `tailwind.config.ts`, `postcss.config.js`. | `/workspace/package.json`, `tsconfig.json`, `tailwind.config.ts`, `postcss.config.js`, `next.config.ts`, `.env.local`, `.gitignore` | none | Build passes: `pnpm build` |
| 1.2 | shadcn/ui initialization | Run `pnpm dlx shadcn@latest init` to set up the component library. Install the core components needed in Phase 1: `button`, `input`, `label`, `separator`, `avatar`, `dropdown-menu`, `toast`, `sonner`. | `components.json`, `src/lib/utils.ts`, `src/app/globals.css`, `src/components/ui/*` | 1.1 | — |
| 1.3 | Environment configuration | Create `.env.local` template and `.env.example` with all variables the app needs. Document each variable. | `.env.example`, `.env.local` (git-ignored) | 1.1 | — |

---

### Wave 2 — Database Schema (depends on Wave 1)

| # | Task | Description | Files to Create / Modify | Dependencies | Tests Needed |
|---|------|-------------|--------------------------|--------------|--------------|
| 2.1 | Prisma schema — all 9 entities | Write the complete `schema.prisma` defining User, Project, Task, Subtask, Tag, TaskTag, Reminder, Session, Account. Add all composite indexes from Spec §4. Use `uuid` as default for all `id` fields. Set `provider = "postgresql"`. | `prisma/schema.prisma` | 1.1 | Schema validates: `prisma validate` |
| 2.2 | Initial migration | Run `prisma migrate dev --name init` inside Docker to generate and apply the SQL migration. Commit the generated migration file. | `prisma/migrations/YYYYMMDD_init/migration.sql` | 2.1 | Migration applies cleanly to fresh DB |
| 2.3 | Seed script | Write `prisma/seed.ts` that creates: one demo user (`demo@clarity.app`, bcrypt hash of "password123"), one Inbox project (`isDefault: true`) owned by that user. Wire `"prisma": { "seed": "tsx prisma/seed.ts" }` in `package.json`. | `prisma/seed.ts`, `package.json` | 2.2 | `prisma db seed` runs without error; demo user row exists |

---

### Wave 3 — Authentication Backend (depends on Wave 2)

| # | Task | Description | Files to Create / Modify | Dependencies | Tests Needed |
|---|------|-------------|--------------------------|--------------|--------------|
| 3.1 | Prisma client singleton | Create a module-level Prisma client with the hot-reload guard pattern for Next.js dev mode. | `src/lib/prisma.ts` | 2.1 | — |
| 3.2 | NextAuth.js v5 configuration | Install `next-auth@beta` and `@auth/prisma-adapter`. Create `auth.ts` at the project root with: `Credentials` provider (email + bcrypt), `Google` provider, `PrismaAdapter`, JWT strategy, session/user callbacks that expose `id` and `email` on the session object. | `auth.ts`, `src/app/api/auth/[...nextauth]/route.ts` | 3.1 | — |
| 3.3 | Password hashing utility | Install `bcryptjs` + `@types/bcryptjs`. Create a `hashPassword` / `verifyPassword` helper. | `src/lib/password.ts` | 1.1 | Unit test: hash then verify returns true; wrong password returns false |
| 3.4 | Email/password signup API route | `POST /api/auth/signup` — validate email format and password requirements (min 8 chars, at least 1 letter + 1 number), check for duplicate email, hash password, create User row, create default Inbox Project row, return 201. Use Zod for input validation. | `src/app/api/auth/signup/route.ts`, `src/lib/validations/auth.ts` | 3.1, 3.3 | Unit: duplicate email returns 409; weak password returns 422; valid signup returns 201 |
| 3.5 | Auth middleware (route protection) | Create `middleware.ts` at the project root using NextAuth's `auth` export. Protect all routes under `/app/*` and `/api/*` (except auth routes and health). Unauthenticated requests redirect to `/login`. | `middleware.ts` | 3.2 | — |
| 3.6 | Health check API route | `GET /api/health` — attempt a `prisma.$queryRaw\`SELECT 1\`` to verify DB connectivity. Return `{ status: "ok", db: "connected", uptime: <seconds> }` or `{ status: "error", db: "disconnected" }` with 503. No auth required. | `src/app/api/health/route.ts` | 3.1 | Integration: GET /api/health returns 200 with expected shape |

---

### Wave 4 — Authentication UI (depends on Wave 3)

| # | Task | Description | Files to Create / Modify | Dependencies | Tests Needed |
|---|------|-------------|--------------------------|--------------|--------------|
| 4.1 | Auth layout | Create a centered card layout for all auth pages (`/login`, `/signup`). Server component. Includes logo/wordmark. | `src/app/(auth)/layout.tsx` | 1.2 | — |
| 4.2 | Signup page + form | `/signup` page with email, password, confirm-password fields. Client component form using controlled inputs. On submit: POST to `/api/auth/signup`, then call NextAuth `signIn("credentials", ...)`. Show inline errors from API response. "Already have an account? Log in" link. "Continue with Google" button. | `src/app/(auth)/signup/page.tsx`, `src/components/features/auth/SignupForm.tsx` | 4.1, 3.2, 3.4 | E2E: fill form with valid data, submit, land on /app |
| 4.3 | Login page + form | `/login` page with email + password fields. Client component. Calls NextAuth `signIn("credentials", ...)`. Shows error for invalid credentials. "Forgot password?" link (placeholder for Phase 4). "Continue with Google" button. Redirect to `/app` on success. | `src/app/(auth)/login/page.tsx`, `src/components/features/auth/LoginForm.tsx` | 4.1, 3.2 | E2E: valid credentials redirect to /app; invalid credentials show error |
| 4.4 | Google OAuth button | Reusable `GoogleOAuthButton` client component that calls `signIn("google")`. Used by both Signup and Login forms. | `src/components/features/auth/GoogleOAuthButton.tsx` | 3.2 | — |
| 4.5 | Session provider wrapper | Client component that wraps the app in NextAuth's `SessionProvider`. Add to the root layout. | `src/app/layout.tsx`, `src/components/providers/SessionProvider.tsx` | 3.2 | — |

---

### Wave 5 — App Shell & Navigation (depends on Wave 4)

| # | Task | Description | Files to Create / Modify | Dependencies | Tests Needed |
|---|------|-------------|--------------------------|--------------|--------------|
| 5.1 | Root layout | Top-level `layout.tsx` with `<html>`, `<body>`, font loading (Inter via `next/font`), Tailwind base, `SessionProvider`, and `Toaster` (Sonner). | `src/app/layout.tsx` | 4.5 | — |
| 5.2 | App shell layout | Protected layout for all `/app/*` routes. Server component that reads the session and renders a two-column structure: `<Sidebar>` on the left (fixed, 240px), `<main>` on the right (flex-1). If not authenticated, redirect to `/login`. | `src/app/(app)/layout.tsx` | 3.5, 5.3 | — |
| 5.3 | Sidebar component | Server component `<Sidebar>`. Sections: (a) Logo/wordmark at top. (b) Smart Views group: "Today", "Upcoming", "Someday" links with icons (use Lucide icons). (c) "Projects" section header with "+ Add" button (placeholder). (d) User avatar + email at bottom with a dropdown for "Log out". Active link highlighted. | `src/components/features/layout/Sidebar.tsx`, `src/components/features/layout/SidebarNavLink.tsx`, `src/components/features/layout/UserMenu.tsx` | 1.2 | — |
| 5.4 | User menu (logout) | `<UserMenu>` client component in the sidebar bottom. Renders Avatar + dropdown. "Log out" item calls NextAuth `signOut()` and redirects to `/`. | `src/components/features/layout/UserMenu.tsx` | 3.2 | E2E: click Log out, redirected to / |
| 5.5 | App inbox page (placeholder) | Default `/app` route that shows "Inbox" heading and an empty-state placeholder: "No tasks yet. Press Q to add your first task." This will be replaced in Phase 2. | `src/app/(app)/page.tsx` | 5.2 | — |
| 5.6 | Smart View placeholder pages | Stub pages for `/app/today`, `/app/upcoming`, `/app/someday` that display the view name and a "Coming soon" placeholder. These are upgraded in Phase 3. | `src/app/(app)/today/page.tsx`, `src/app/(app)/upcoming/page.tsx`, `src/app/(app)/someday/page.tsx` | 5.2 | — |

---

### Wave 6 — Landing Page (depends on Wave 5)

| # | Task | Description | Files to Create / Modify | Dependencies | Tests Needed |
|---|------|-------------|--------------------------|--------------|--------------|
| 6.1 | Landing page | Public page at `/`. Server component. Sections: (a) Nav bar with logo and "Log in" / "Get Started" buttons. (b) Hero: large headline, subheadline, "Get Started free" CTA button linking to `/signup`. (c) Brief value-prop section (3 columns: Free reminders, Beautiful design, No subscription). (d) Simple footer. Fully responsive with Tailwind. | `src/app/page.tsx`, `src/components/features/landing/HeroSection.tsx`, `src/components/features/landing/FeatureGrid.tsx`, `src/components/features/landing/LandingNav.tsx` | 5.1 | E2E: / loads, "Get Started" links to /signup; Playwright screenshot smoke test |

---

## File Manifest

### New files — configuration & tooling
```
/workspace/package.json
/workspace/tsconfig.json
/workspace/next.config.ts
/workspace/tailwind.config.ts
/workspace/postcss.config.js
/workspace/components.json
/workspace/.env.example
/workspace/.gitignore
/workspace/auth.ts
/workspace/middleware.ts
```

### New files — Prisma
```
/workspace/prisma/schema.prisma
/workspace/prisma/seed.ts
/workspace/prisma/migrations/<timestamp>_init/migration.sql
```

### New files — source
```
/workspace/src/app/layout.tsx                          (root layout)
/workspace/src/app/page.tsx                            (landing page)
/workspace/src/app/globals.css                         (Tailwind base)
/workspace/src/app/api/auth/[...nextauth]/route.ts     (NextAuth handler)
/workspace/src/app/api/auth/signup/route.ts            (signup endpoint)
/workspace/src/app/api/health/route.ts                 (health endpoint)
/workspace/src/app/(auth)/layout.tsx                   (auth pages layout)
/workspace/src/app/(auth)/login/page.tsx
/workspace/src/app/(auth)/signup/page.tsx
/workspace/src/app/(app)/layout.tsx                    (protected app shell)
/workspace/src/app/(app)/page.tsx                      (inbox placeholder)
/workspace/src/app/(app)/today/page.tsx
/workspace/src/app/(app)/upcoming/page.tsx
/workspace/src/app/(app)/someday/page.tsx

/workspace/src/lib/prisma.ts                           (PrismaClient singleton)
/workspace/src/lib/password.ts                         (bcrypt helpers)
/workspace/src/lib/utils.ts                            (cn() from shadcn)
/workspace/src/lib/validations/auth.ts                 (Zod schemas)

/workspace/src/components/providers/SessionProvider.tsx
/workspace/src/components/ui/                          (shadcn generated: button, input, label, separator, avatar, dropdown-menu, sonner)
/workspace/src/components/features/auth/SignupForm.tsx
/workspace/src/components/features/auth/LoginForm.tsx
/workspace/src/components/features/auth/GoogleOAuthButton.tsx
/workspace/src/components/features/layout/Sidebar.tsx
/workspace/src/components/features/layout/SidebarNavLink.tsx
/workspace/src/components/features/layout/UserMenu.tsx
/workspace/src/components/features/landing/HeroSection.tsx
/workspace/src/components/features/landing/FeatureGrid.tsx
/workspace/src/components/features/landing/LandingNav.tsx
```

---

## Database Changes

### New schema (full, applied in migration `init`)

```prisma
// All fields match Spec §4 exactly.

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  name          String?
  passwordHash  String?
  avatarUrl     String?
  theme         String    @default("system")   // "light" | "dark" | "system"
  plan          String    @default("free")     // "free" | "premium"
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  projects  Project[]
  tasks     Task[]
  tags      Tag[]
  reminders Reminder[]
  sessions  Session[]
  accounts  Account[]
}

model Project {
  id        String   @id @default(uuid())
  name      String
  color     String   @default("#6366f1")
  position  Int      @default(0)
  isDefault Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  tasks  Task[]
}

model Task {
  id                String    @id @default(uuid())
  title             String
  description       String?
  dueDate           DateTime?
  dueTime           String?   // stored as "HH:MM"
  priority          Int       @default(4)
  isCompleted       Boolean   @default(false)
  completedAt       DateTime?
  position          Int       @default(0)
  recurrenceRule    String?
  recurrenceParentId String?

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  userId    String
  user      User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  projectId String
  project   Project @relation(fields: [projectId], references: [id])

  subtasks  Subtask[]
  reminders Reminder[]
  tags      TaskTag[]
  parent    Task?     @relation("RecurrenceParent", fields: [recurrenceParentId], references: [id])
  children  Task[]    @relation("RecurrenceParent")

  @@index([userId, isCompleted, dueDate])
  @@index([userId, projectId, isCompleted, position])
}

model Subtask {
  id          String   @id @default(uuid())
  title       String
  isCompleted Boolean  @default(false)
  position    Int      @default(0)
  createdAt   DateTime @default(now())

  taskId String
  task   Task   @relation(fields: [taskId], references: [id], onDelete: Cascade)
}

model Tag {
  id        String    @id @default(uuid())
  name      String
  color     String?
  createdAt DateTime  @default(now())

  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  tasks  TaskTag[]
}

model TaskTag {
  taskId String
  tagId  String

  task Task @relation(fields: [taskId], references: [id], onDelete: Cascade)
  tag  Tag  @relation(fields: [tagId], references: [id], onDelete: Cascade)

  @@id([taskId, tagId])
  @@index([taskId, tagId])
}

model Reminder {
  id            String   @id @default(uuid())
  remindAt      DateTime
  offsetMinutes Int?
  isSent        Boolean  @default(false)
  isDismissed   Boolean  @default(false)
  createdAt     DateTime @default(now())

  taskId String
  task   Task   @relation(fields: [taskId], references: [id], onDelete: Cascade)
  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([isSent, remindAt])
}

model Session {
  id        String   @id @default(uuid())
  expiresAt DateTime
  createdAt DateTime @default(now())

  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  // NextAuth adapter fields
  sessionToken String @unique
}

model Account {
  id                String  @id @default(uuid())
  provider          String
  providerAccountId String
  accessToken       String?
  refreshToken      String?
  expiresAt         Int?
  tokenType         String?
  scope             String?
  idToken           String?

  userId String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
}

model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime

  @@unique([identifier, token])
}
```

### Seed data
- User: `{ email: "demo@clarity.app", name: "Demo User", passwordHash: bcrypt("password123"), plan: "free" }`
- Project: `{ name: "Inbox", isDefault: true, color: "#6366f1", position: 0, userId: <demo user id> }`

### Migration command (run inside Docker)
```
docker compose -f .devcontainer/docker-compose.yml exec -T app pnpm prisma migrate dev --name init
docker compose -f .devcontainer/docker-compose.yml exec -T app pnpm prisma db seed
```

---

## Key Implementation Notes

### Package versions to install
```
next@14                        # App Router stable
react@18 react-dom@18
typescript @types/node @types/react @types/react-dom
tailwindcss postcss autoprefixer
next-auth@beta                 # NextAuth v5 (required for App Router)
@auth/prisma-adapter
@prisma/client prisma
bcryptjs @types/bcryptjs
zod
lucide-react
tsx                            # for seed script
```

### NextAuth v5 patterns
- `auth.ts` at the project root (not inside `src/`)
- Route handler: `src/app/api/auth/[...nextauth]/route.ts` exports `{ GET, POST }` from `auth`
- Middleware: `middleware.ts` at project root exports `auth` as default (or wraps it)
- Session access in server components: `import { auth } from "@/auth"` then `const session = await auth()`
- Session access in client components: `useSession()` from `next-auth/react` inside `SessionProvider`

### Auth callback — create Inbox project on first OAuth sign-in
In `auth.ts` `signIn` callback: when a new user is created via OAuth, check if they have any projects; if not, create the default Inbox project. This mirrors what the signup API route does for email/password users.

### Route group conventions
- `(auth)` — public auth pages, centered card layout
- `(app)` — protected pages, sidebar layout
- Root `/` — landing page, no layout wrapper (standalone)

### Middleware protection rules
```
Matcher: ["/app/:path*", "/api/tasks/:path*", "/api/projects/:path*",
          "/api/views/:path*", "/api/user/:path*", "/api/reminders/:path*",
          "/api/tags/:path*"]
Public paths (no auth): "/", "/login", "/signup", "/api/auth/:path*", "/api/health"
```

### Docker execution prefix for all commands
```
docker compose -f .devcontainer/docker-compose.yml exec -T app <command>
```

---

## Verification Criteria (Acceptance)

These checks must all pass before Phase 1 is considered complete:

### User-facing checks
1. Landing page at `http://localhost:3000/` loads with hero section and "Get Started" button.
2. Clicking "Get Started" navigates to `/signup`.
3. Filling the signup form with a new email + valid password and submitting creates an account, logs the user in, and redirects to `/app` showing the sidebar with Today / Upcoming / Someday links.
4. The sidebar shows "Inbox" as the active project (placeholder label — no task list yet).
5. Clicking "Log out" in the user menu destroys the session and redirects to `/`.
6. Logging back in via `/login` with the same credentials succeeds.
7. Attempting to navigate to `/app` without a session redirects to `/login`.
8. Attempting to sign up with the same email twice shows the inline error "An account with this email already exists."

### API / quality gate checks
9. `GET /api/health` returns `{ "status": "ok", "db": "connected" }` with HTTP 200.
10. `POST /api/auth/signup` with a weak password (e.g., `"abc"`) returns HTTP 422.
11. `pnpm build` completes without TypeScript errors or warnings.
12. `pnpm lint` passes with zero errors.
13. `pnpm typecheck` (`tsc --noEmit`) passes with zero errors.

### Database checks
14. `prisma migrate status` shows migration `init` as applied.
15. Demo user `demo@clarity.app` exists in the `User` table.
16. Demo user has one row in `Project` with `isDefault = true` and `name = "Inbox"`.

### Smoke test endpoints (from config.json qualityGate)
- `GET /` — 200
- `GET /login` — 200
- `GET /api/health` — 200
