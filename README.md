# n8n Development Template

A n8n development template designed for GitHub Codespaces with PostgreSQL backend.

## Overview

This template provides a complete n8n automation platform setup with:
- **n8n** - Workflow automation platform
- **PostgreSQL** - Secure database backend
- **Alpine Linux** - Lightweight container base
- **GitHub Codespaces** - Cloud development environment

## Quick Start

### 1. Create Codespace

1. Click "Use this template" or fork this repository
2. Open in GitHub Codespaces
3. Wait for the development container to build

### 2. Initial Setup

Run the setup script to configure environment:

```sh
./setup.sh
```

This script will:
- Generate secure database credentials
- Configure Codespace URLs automatically
- Create `.env` file from template

### 3. Start Services

Launch n8n and PostgreSQL:

```sh
docker-compose up -d
```

### 4. Access n8n

Open your n8n instance at the automatically configured Codespace URL (shown in terminal output).

## Development Workflow

1. **Start services**: `docker-compose up -d`
2. **View logs**: `docker-compose logs -f`
3. **Stop services**: `docker-compose down`
4. **Reset data**: `docker-compose down -v` (⚠️ deletes all data)

## Data Persistence

- **PostgreSQL data**: Stored in Docker volume `postgres_data`
- **n8n workflows**: Stored in Docker volume `n8n_data`
