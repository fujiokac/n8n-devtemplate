# syntax=docker/dockerfile:1

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

# Optional: create a non-root user like Codespaces' default
RUN adduser -D -u 1000 vscode \
 && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode

# Keep your working directory
WORKDIR /workspaces/${localWorkspaceFolderBasename}