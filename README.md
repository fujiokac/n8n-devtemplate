# n8n Development Template

A n8n development template designed for GitHub Codespaces.

## Overview

This template provides a complete n8n automation platform setup

## Quick Start

### 1. Choose Your Setup

**Use as template** - Creates an independent repository with no connection to upstream updates
**Fork** - Maintains connection to this template, allowing you to pull future improvements

### 2. Open in Codespaces

1. From your repository, click "Code" → "Codespaces" → "Create codespace"
2. Wait for container to build

### 3. Start n8n

```sh
n8n start
```

Access n8n at the URL shown in the terminal output.

- **Stop n8n**: `Ctrl+C` in terminal
- **Reset data**: Remove `n8n_data/` directory (⚠️ deletes all workflows)

## Data Persistence

- **n8n workflows**: Stored in `n8n_data/` directory (persists across container rebuilds)
