#!/bin/bash
# OpenClaw Utils Installer
# https://github.com/minkhant1996/openclaw-utlis

set -e

REPO_URL="https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"
BIN_DIR="$HOME/bin"

echo "========================================"
echo "  OpenClaw Utils Installer"
echo "========================================"
echo ""

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$SKILLS_DIR"

# ============================================
# Install openclaw-convert-pdf
# ============================================
echo "[1/3] Installing openclaw-convert-pdf..."

SKILL_DIR="$SKILLS_DIR/openclaw-convert-pdf"
mkdir -p "$SKILL_DIR"

# Download files
curl -s "$REPO_URL/skills/openclaw-convert-pdf/src/convert-pdf.mjs" -o "$SKILL_DIR/convert-pdf.mjs"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/SKILL.md" -o "$SKILL_DIR/SKILL.md"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/package.json" -o "$SKILL_DIR/package.json"

echo "[2/3] Installing npm dependencies..."
cd "$SKILL_DIR"
npm install --silent 2>/dev/null || npm install

# Create wrapper script
echo "[3/3] Creating wrapper script..."
cat > "$BIN_DIR/convert-pdf" << 'WRAPPER'
#!/bin/bash
cd ~/.openclaw/workspace/skills/openclaw-convert-pdf
node convert-pdf.mjs "$@"
WRAPPER
chmod +x "$BIN_DIR/convert-pdf"

# ============================================
# Setup PATH
# ============================================
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "Adding $BIN_DIR to PATH..."

    # Add to bashrc if not already there
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    fi

    # Add to zshrc if it exists
    if [ -f ~/.zshrc ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    fi

    export PATH="$BIN_DIR:$PATH"
fi

echo ""
echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Installed skills:"
echo "  - convert-pdf (markdown/HTML/text to PDF)"
echo ""
echo "Usage:"
echo "  convert-pdf convert --input document.md"
echo "  convert-pdf convert --text '# Hello' --format markdown"
echo ""
echo "Run 'convert-pdf help' for more options."
echo ""
echo "NOTE: Restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
