# syntax=docker/dockerfile:1

# Base variant arg – swap between "debian" and "alpine"
ARG BASE_VARIANT=debian
FROM mcr.microsoft.com/devcontainers/javascript-node:18-${BASE_VARIANT}

# Set workspace dir
WORKDIR /workspaces/${localWorkspaceFolderBasename}