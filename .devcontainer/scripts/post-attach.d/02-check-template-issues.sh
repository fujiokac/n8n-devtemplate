#!/bin/sh

# Check for open template sync issues and display memo

echo "Checking for template sync issues..."

# Check if gh CLI is available and authenticated
if ! command -v gh >/dev/null 2>&1; then
    echo "ℹ️  GitHub CLI not available - skipping template issue check"
    exit 0
fi

# Check authentication
if ! gh auth status >/dev/null 2>&1; then
    echo "ℹ️  GitHub CLI not authenticated - skipping template issue check"
    exit 0
fi

# Look for open template sync issues by title pattern
ISSUES=$(gh issue list --state open --search "Template Sync" --json number,title,url 2>/dev/null)

if [ "$?" -ne 0 ]; then
    echo "ℹ️  Could not check for template sync issues"
    exit 0
fi

# Parse and display issues
ISSUE_COUNT=$(echo "$ISSUES" | jq length 2>/dev/null || echo "0")

if [ "$ISSUE_COUNT" -gt 0 ]; then
    echo ""
    echo "📋 TEMPLATE SYNC MEMO:"
    echo "======================================="
    echo "⚠️  You have $ISSUE_COUNT open template sync issue(s)"
    echo ""
    
    # Display each issue
    echo "$ISSUES" | jq -r '.[] | "• #\(.number): \(.title)\n  \(.url)"' 2>/dev/null || {
        echo "• Check your repository's Issues tab for template sync issues"
    }
    
    echo ""
    echo "These may need manual resolution:"
    echo "1. Review the merge conflicts"
    echo "2. Follow the resolution steps in the issue"
    echo "3. Close the issue when resolved"
    echo "======================================="
    echo ""
elif [ "$ISSUE_COUNT" -eq 0 ]; then
    echo "✅ No pending template sync issues"
fi