FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    postgresql-client \
    iptables \
    ipset \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g prisma

RUN npx playwright install --with-deps chromium

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /workspace

CMD ["sleep", "infinity"]
