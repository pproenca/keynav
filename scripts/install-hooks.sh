#!/bin/bash
set -e

HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "Installing git hooks..."

# Pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
exec ./scripts/pre-commit.sh
EOF
chmod +x "$HOOKS_DIR/pre-commit"

# Pre-push hook
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash
exec ./scripts/pre-push.sh
EOF
chmod +x "$HOOKS_DIR/pre-push"

echo "✓ Hooks installed"
