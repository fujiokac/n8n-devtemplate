# Claude Code Preferences

## POSIX Compliance
- Use `sh` unless explicitly required otherwise
- Use `sh` syntax highlighting in documentation
- Write new scripts with `#!/bin/sh` shebang

## Session Management
When the user says "end session", create or update logs/SESSION_LOG.md.log with:
- Major changes made during the session
- Issues resolved and solutions implemented  
- Current state of the project
- Files modified/created
- Next steps or recommendations
- Clear context for resuming work
- Use markdown formatting within the .md.log file