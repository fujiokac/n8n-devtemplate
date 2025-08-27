# syntax=docker/dockerfile:1

FROM node:18-alpine
RUN apk add --no-cache git openssh curl bash

RUN npm install -g pnpm
# Keep your working directory
WORKDIR /workspaces/${localWorkspaceFolderBasename}