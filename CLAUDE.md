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

## POSIX Compliance
- Use `sh` unless explicitly required otherwise
- Use `sh` syntax highlighting in documentation
- Write new scripts with `#!/bin/sh` shebang

## Script Development Patterns
- Always make paths configurable via environment variables (use `${TMPDIR:-/tmp}` not `/tmp`)
- Separate concerns into individual scripts rather than monolithic solutions
- Include logging setup in all major scripts: `LOG_FILE="${LOGS_DIR:-logs}/script-name.log"`
- Remember to `chmod +x` new scripts after creation
- Create root-level symlinks for user-facing scripts

## Security and Safety
- Use application native APIs/CLIs instead of direct database access when available
- Validate required environment variables at script start and fail with clear messages

## User Experience
- Exit quietly when no action is needed (don't spam logs with "nothing to do" messages)
- Make retention policies and similar values configurable via .env files
- Comments and output should describe functionality, not document code changes

## Core Principles
  - No fluff or filler text - Get to the point immediately
  - No invented data - Only use actual information provided or discovered
  - Match the document's purpose - High-level docs stay high-level, technical docs stay technical
  - Stop when done - Don't elaborate unless asked

## Writing Style
  - No sales language - Avoid marketing speak, benefits lists, or persuasive tone
  - Appropriate detail level - Design docs get specifics, summaries get essentials only
  - No repetition - Don't restate the same information in different formats
    
## Session Management
When the user says "end session", create or update logs/SESSION_LOG.md.log with:
- Major changes made during the session
- Issues resolved and solutions implemented  
- Current state of the project
- Files modified/created
- Next steps or recommendations
- Clear context for resuming work
- Use markdown formatting within the .md.log file
- Overwrite the file completely instead of showing diffs
- 💚
