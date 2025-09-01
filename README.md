# n8n Development Template

A n8n development template designed for GitHub Codespaces.

## Overview

This template provides a complete n8n automation platform setup

## Quick Start

### 1. Choose Your Setup

**Use as template** - Creates an independent repository with no connection to upstream updates
**Fork** - Maintains connection to this template, allowing you to pull future improvements

### 2. Set Up Secrets (Required)

Before creating your Codespace, add these secrets in GitHub:

**Repository → Settings → Security → Secrets and variables → Codespaces → New repository secret**

| Secret Name | Purpose | Example Generation |
|-------------|---------|-------------------|
| `DB_PASSWORD` | PostgreSQL database password | `openssl rand -base64 32` |
| `N8N_ENCRYPTION_KEY` | n8n data encryption key | `openssl rand -base64 32` |

### 3. Open in Codespaces

1. From your repository, click "Code" → "Codespaces" → "Create codespace"
2. Wait for container to build

### 4. Start n8n

```sh
./start-n8n
```

Access n8n at the URL shown in the terminal output.

- **Stop n8n**: `Ctrl+C` in terminal
- **Reset data**: Remove `n8n_data/` directory (⚠️ deletes all workflows)

> **Note**: If you skip setting up secrets, you'll be prompted with generated values on first attach.

## Template Updates

This repository includes an automated template sync workflow that helps you stay updated with improvements from the upstream template.

### Automatic Updates

- **Weekly checks**: Every Monday, GitHub Actions automatically checks for template updates
- **Pull Requests**: When updates are available, a PR is created for you to review
- **Conflict handling**: If merge conflicts occur, an issue is created with resolution steps

### Manual Updates

To manually check for template updates:

1. **GitHub Web**: Go to Actions → "Template Sync" → "Run workflow"
2. **GitHub CLI**: `gh workflow run template-sync.yml`

> **Note**: Template updates only affect configuration and setup files, never your n8n workflows or data.

## Data Persistence

- **n8n workflows**: Stored in `n8n_data/` directory (persists across container rebuilds)
