FROM node:18-alpine

# Install common dev tools
RUN apk add --no-cache \
    git \
    openssh \
    curl \
    bash \
    ca-certificates \
    tzdata \
    shadow \
    sudo \
    openssl \
    git-lfs \
    postgresql \
    postgresql-contrib

RUN npm install -g pnpm n8n

# Give the existing 'node' user passwordless sudo
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER node