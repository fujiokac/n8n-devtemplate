# n8n Development Template

A n8n development template designed for GitHub Codespaces.

## Overview

This template provides a complete n8n automation platform setup

## Quick Start

### 1. Create Repository

Use this template when creating a new repository (or click **"Use this template"** button above.) Template updates will automatically generate pull requests.

### 2. Set Up Secrets

You'll be guided through secret setup during Codespace creation.

| Secret Name |  | Purpose |
|-------------|--|---------|
| `N8N_ENCRYPTION_KEY` | Required | n8n data encryption key |
| `DB_PASSWORD` | Optional | PostgreSQL database password (only if using PostgreSQL) |

### 3. Open in Codespaces

1. From your repository, click "Code" → "Codespaces" → "Create codespace"
2. Wait for container to build

## Template Updates

This repository includes an automated template sync workflow that helps you stay updated with improvements from the upstream template.

### Automatic Updates

- **Weekly checks**: Every Monday, GitHub Actions automatically checks for template updates
- **Pull Requests**: When updates are available, a PR is created for you to review
- **Conflict handling**: If merge conflicts occur, an issue is created with resolution steps

### Manual Updates

To manually trigger template updates, go to **Actions** → **"Template Sync"** → **"Run workflow"**

> **Note**: Template updates only affect configuration and setup files, never your n8n workflows or data.

## Starting n8n

```sh
./start-n8n
```

Access n8n at the URL shown in the terminal output.

- **Stop n8n**: `Ctrl+C` in terminal or `./stop-n8n`
- **Reset data**: Remove `n8n_data/` directory (⚠️ deletes all workflows)

### n8n Backups and Restoration

For backup and restore operations, see: `./n8n-backup help`

## Git-crypt Key Management

Review key management instructions: `./git-crypt-utility help`
