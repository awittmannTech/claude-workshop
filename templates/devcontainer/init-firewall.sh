#!/bin/bash
# Network whitelist for safe factory execution
# Only allows connections to essential services

set -e

echo "Configuring network whitelist..."

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow npm registry
iptables -A OUTPUT -d registry.npmjs.org -j ACCEPT

# Allow GitHub
iptables -A OUTPUT -d github.com -j ACCEPT
iptables -A OUTPUT -d api.github.com -j ACCEPT

# Allow Anthropic API
iptables -A OUTPUT -d api.anthropic.com -j ACCEPT

# Allow Prisma binaries
iptables -A OUTPUT -d binaries.prisma.sh -j ACCEPT

# Allow Playwright browser downloads
iptables -A OUTPUT -d playwright.azureedge.net -j ACCEPT

# Allow PostgreSQL (internal network)
iptables -A OUTPUT -d db -p tcp --dport 5432 -j ACCEPT

# Default deny all other outbound
iptables -A OUTPUT -j DROP

echo "Network whitelist configured. Only essential services are accessible."
