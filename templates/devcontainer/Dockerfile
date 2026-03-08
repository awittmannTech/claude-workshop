FROM node:20-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install global tools
RUN npm install -g prisma

# Install Playwright browsers (chromium only for speed)
RUN npx playwright install --with-deps chromium

# Enable pnpm via corepack
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /workspace

# Keep container running
CMD ["sleep", "infinity"]
