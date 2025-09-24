FROM n8nio/base:22

# Install additional dev tools not in n8n base
RUN apk add --no-cache \
    curl \
    bash \
    shadow \
    sudo \
    git-lfs \
    git-crypt \
    postgresql \
    postgresql-contrib \
    ripgrep \
    github-cli

# Install global n8n and pnpm
RUN npm install -g pnpm n8n

# Configure pnpm store directory
RUN mkdir -p ~/.pnpm-store && pnpm config set store-dir ~/.pnpm-store --global

# Set up workspace permissions
RUN mkdir -p /workspaces && chown node:node /workspaces

# Give the existing 'node' user passwordless sudo (more secure approach)
RUN echo "node ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/node

USER node