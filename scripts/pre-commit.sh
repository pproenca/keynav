#!/bin/bash
set -e

echo "Running pre-commit checks..."

# Check if tools are available
command -v swiftlint >/dev/null 2>&1 || { echo "SwiftLint not installed. Run: brew install swiftlint"; exit 1; }
command -v swift-format >/dev/null 2>&1 || { echo "swift-format not installed. Run: brew install swift-format"; exit 1; }

# 1. SwiftLint (strict mode)
echo "→ SwiftLint..."
swiftlint lint --strict Sources/

# 2. swift-format lint
echo "→ swift-format..."
swift-format lint --strict --recursive Sources/

# 3. Type check via build
echo "→ Type checking..."
swift build --target KeyNav 2>&1

echo "✓ All pre-commit checks passed"
