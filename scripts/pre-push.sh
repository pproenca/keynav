#!/bin/bash
set -e

echo "Running pre-push checks..."

# Run tests before pushing
echo "→ Running tests..."
swift test

echo "✓ All tests passed"
