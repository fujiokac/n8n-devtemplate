# Claude Code Preferences

## Git Guidelines
- NEVER include Claude authorship attribution in ANY context (commits, PRs, code comments, etc.)
- NEVER add "Generated with Claude Code" or similar attribution
- NEVER add "Co-Authored-By: Claude" or any variation
- Keep descriptions concise and focused
- Focus on what changed and why, not implementation details
- Don't mention specific files in commit messages (git tracks that automatically)
- Use git stashing when doing branch operations to prevent conflicts
- When user says "boop", interpret this as "push changes"
- Before committing files in git-crypt encrypted directories (secrets/**, etc.):
  - Run `git-crypt status` on the files to verify they will be encrypted
  - If files show "not encrypted" or "WARNING: staged/committed version is NOT ENCRYPTED!", confirm with the user
  - NEVER commit files to encrypted directories without verifying encryption status first

## POSIX Compliance
- Use `sh` unless explicitly required otherwise
- Use `sh` syntax highlighting in documentation
- Write new scripts with `#!/bin/sh` shebang

## Script Development Patterns
- Always make paths configurable via environment variables (these should be pre-defined, not hardcoded)
- Include logging setup in all major scripts: `LOG_FILE="${LOGS_DIR:-logs}/script-name.log"`
- Remember to `chmod +x` new scripts after creation
- Create root-level symlinks for user-facing scripts
- Validate required environment variables at script start and fail with clear messages

## Security and Safety
- Use application native APIs/CLIs instead of direct database access when available

## Data Safety
- ALWAYS ask for explicit confirmation before deleting, reverting, or removing any files or data
- NEVER suggest deletion as a solution without first considering data preservation
- NEVER be casual or "glib" about operations that could result in data loss
- Before ANY operation that could delete data (git restore, git reset, rm, history rewrites, etc.):
  - Explain exactly what will be deleted
  - Confirm backups exist or offer to create them
  - Wait for explicit user confirmation
- Treat backups, credentials, and user data with extreme caution
- When uncertain whether an operation might cause data loss, ask first

## User Experience
- Exit quietly when no action is needed (don't spam logs with "nothing to do" messages)
- Make retention policies and similar values configurable via .env files
- Comments and output should describe functionality, not document code changes
- When unsure how to implement something, ask for clarification instead of repeating the same solution
- Ensure internal consistency - don't agree with corrections if they contradict your prior analysis. Re-evaluate and provide consistent reasoning.
- Address contradictions and errors immediately when identified - don't ignore or defer resolution.
- Prioritize proper solutions over workarounds. For anything under direct control, make fundamental changes as necessary. For external application issues, research and apply documented best practices and recommended solutions. Only consider workarounds after proper solutions have been exhausted.
- Run commands separately rather than chaining with && for readability and easier error identification
- Explain actions before running commands that are not user-friendly or immediately readable
- When encountering errors or warnings, STOP and investigate the root cause before proceeding. Never claim "everything
  is fine" or attempt to continue when issues are unresolved. Acknowledge problems directly and fix them properly.

## Core Principles
  - No fluff or filler text - Get to the point immediately
  - No invented data - Only use actual information provided or discovered
  - Match the document's purpose - High-level docs stay high-level, technical docs stay technical
  - Stop when done - Don't elaborate unless asked
  - Separate concerns - Keep all documents, scripts, and code well-organized by concern rather than monolithic

## Writing Style
  - No sales language - Avoid marketing speak, benefits lists, or persuasive tone
  - Appropriate detail level - Design docs get specifics, summaries get essentials only
  - No repetition - Don't restate the same information in different formats
    
## Session Management
When the user says "end session", create or update logs/SESSION_LOG.md.log with:
- Major changes made during the session
- Current state of the project
- Next steps
- Clear context for resuming work
- Use markdown formatting within the .md.log file
- Overwrite the file completely instead of showing diffs
- 💚
