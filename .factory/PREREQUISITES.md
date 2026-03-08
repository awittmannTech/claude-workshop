# Prerequisites

Before autonomous building can start, you'll need:

## Required for Phase 1 (Foundation)
- [ ] **Google OAuth Credentials**: Google Cloud Console project with OAuth 2.0 client ID and secret (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`)
- [ ] **NextAuth Secret**: Random string for JWT signing (`NEXTAUTH_SECRET` — generate via `openssl rand -base64 32`)

## Required for Phase 4 (Reminders)
- [ ] **Resend API Key**: For transactional email — password reset and reminder notifications (`RESEND_API_KEY`)
- [ ] **Resend Verified Domain**: A domain verified in Resend for sending from (e.g., `noreply@clarityapp.com`)

## Environment Variables

Add these to `.env.local`:

```env
DATABASE_URL=postgresql://factory:factory@db:5432/factorydb

NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=<random-32-char-string>

GOOGLE_CLIENT_ID=<from-google-console>
GOOGLE_CLIENT_SECRET=<from-google-console>

RESEND_API_KEY=<from-resend-dashboard>
RESEND_FROM_EMAIL=noreply@clarityapp.com
```

**Note**: `DATABASE_URL` is auto-configured by the devcontainer. Google OAuth and Resend credentials must be provided by you.

## External Domains Whitelisted in Devcontainer Firewall

The `.devcontainer/init-firewall.sh` script restricts outbound network access to only the following services:

| Domain | Purpose |
|---|---|
| `accounts.google.com` | Google OAuth sign-in |
| `oauth2.googleapis.com` | Google OAuth token exchange |
| `api.resend.com` | Transactional email (password reset, reminders) |
| `registry.npmjs.org` | npm / pnpm package installs |
| `github.com` | Source downloads and Prisma binary releases |
| `binaries.prisma.sh` | Prisma query engine binaries |

All other outbound traffic is dropped.
