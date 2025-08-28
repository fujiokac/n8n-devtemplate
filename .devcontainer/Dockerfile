FROM n8nio/base:22

# Install additional dev tools not in n8n base
RUN apk add --no-cache \
    curl \
    bash \
    shadow \
    sudo \
    git-lfs \
    postgresql \
    postgresql-contrib \
    ripgrep

# Install global n8n and pnpm
RUN npm install -g pnpm n8n

# Give the existing 'node' user passwordless sudo
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER node