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
    sudo

RUN npm install -g pnpm

# Give the existing 'node' user passwordless sudo
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER node