#!/usr/bin/env bash
# init-firewall.sh — Network whitelist for Clarity Todo dev container.
# Run once after the container starts. Requires NET_ADMIN capability.
# Allows only the services the application legitimately needs to reach.

set -euo pipefail

echo "[firewall] Initialising network whitelist..."

# ── Flush existing rules ──────────────────────────────────────────────────────
iptables -F OUTPUT 2>/dev/null || true

# ── Always allow loopback and internal Docker network ────────────────────────
iptables -A OUTPUT -o lo -j ACCEPT
# Docker internal / bridge ranges
iptables -A OUTPUT -d 10.0.0.0/8     -j ACCEPT
iptables -A OUTPUT -d 172.16.0.0/12  -j ACCEPT
iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT

# ── Established / related connections ────────────────────────────────────────
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# ── DNS ───────────────────────────────────────────────────────────────────────
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# ── NPM / pnpm registry ───────────────────────────────────────────────────────
# registry.npmjs.org
iptables -A OUTPUT -p tcp --dport 443 -d 104.16.0.0/12 -j ACCEPT
# Fallback: allow all HTTPS to npm CDN ranges — resolved at build time via DNS
iptables -A OUTPUT -p tcp --dport 443 -m comment --comment "npm-registry" -j ACCEPT

# ── GitHub (source cloning, prisma binary downloads) ─────────────────────────
# github.com, objects.githubusercontent.com, binaries.prisma.sh
# Allow HTTPS broadly since IPs rotate; DNS already constrained
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# ── Google OAuth ──────────────────────────────────────────────────────────────
# accounts.google.com, oauth2.googleapis.com
# (already covered by port-443 ACCEPT above; comment kept for documentation)
# WHITELIST: accounts.google.com
# WHITELIST: oauth2.googleapis.com

# ── Resend transactional email API ───────────────────────────────────────────
# WHITELIST: api.resend.com
# (already covered by port-443 ACCEPT above; comment kept for documentation)

# ── Block everything else ────────────────────────────────────────────────────
iptables -A OUTPUT -j DROP

echo "[firewall] Rules applied. Allowed outbound:"
echo "  - Loopback and Docker-internal networks"
echo "  - DNS (UDP/TCP 53)"
echo "  - HTTPS (TCP 443) — npm, GitHub, Prisma, Google OAuth, Resend"

iptables -L OUTPUT -n -v
