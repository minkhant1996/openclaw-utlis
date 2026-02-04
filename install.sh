#!/bin/bash
# OpenClaw Utils Installer
# https://github.com/minkhant1996/openclaw-utlis

set -e

REPO_URL="https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"
BIN_DIR="$HOME/bin"
DOWNLOAD_DIR="$HOME/youtube-downloads"

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
echo "[1/5] Installing openclaw-convert-pdf..."

SKILL_DIR="$SKILLS_DIR/openclaw-convert-pdf"
mkdir -p "$SKILL_DIR"

# Download files
curl -s "$REPO_URL/skills/openclaw-convert-pdf/src/convert-pdf.mjs" -o "$SKILL_DIR/convert-pdf.mjs"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/SKILL.md" -o "$SKILL_DIR/SKILL.md"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/package.json" -o "$SKILL_DIR/package.json"

echo "[2/5] Installing npm dependencies for convert-pdf..."
cd "$SKILL_DIR"
npm install --silent 2>/dev/null || npm install

# Create wrapper script
cat > "$BIN_DIR/convert-pdf" << 'WRAPPER'
#!/bin/bash
CWD=$(pwd)
cd ~/.openclaw/workspace/skills/openclaw-convert-pdf
ARGS=()
for arg in "$@"; do
  if [[ "$arg" != --* ]] && [[ -e "$CWD/$arg" ]]; then
    ARGS+=("$CWD/$arg")
  else
    ARGS+=("$arg")
  fi
done
node convert-pdf.mjs "${ARGS[@]}"
WRAPPER
chmod +x "$BIN_DIR/convert-pdf"

# ============================================
# Install openclaw-youtube
# ============================================
echo "[3/5] Installing openclaw-youtube..."

YT_SKILL_DIR="$SKILLS_DIR/openclaw-youtube"
mkdir -p "$YT_SKILL_DIR"
mkdir -p "$DOWNLOAD_DIR"

# Download files
curl -s "$REPO_URL/skills/openclaw-youtube/yt-channel-downloader" -o "$YT_SKILL_DIR/yt-channel-downloader"
curl -s "$REPO_URL/skills/openclaw-youtube/yt-channel-clear" -o "$YT_SKILL_DIR/yt-channel-clear"
curl -s "$REPO_URL/skills/openclaw-youtube/README.md" -o "$YT_SKILL_DIR/README.md"
chmod +x "$YT_SKILL_DIR/yt-channel-downloader"
chmod +x "$YT_SKILL_DIR/yt-channel-clear"

# Create symlinks in bin
ln -sf "$YT_SKILL_DIR/yt-channel-downloader" "$BIN_DIR/yt-channel-downloader"
ln -sf "$YT_SKILL_DIR/yt-channel-clear" "$BIN_DIR/yt-channel-clear"

# ============================================
# Install yt-dlp dependency
# ============================================
echo "[4/5] Checking yt-dlp dependency..."

if command -v yt-dlp &> /dev/null; then
    echo "  yt-dlp already installed: $(yt-dlp --version)"
elif command -v pipx &> /dev/null; then
    echo "  Installing yt-dlp via pipx..."
    pipx install yt-dlp
    pipx ensurepath
elif command -v pip3 &> /dev/null; then
    echo "  Installing yt-dlp via pip3..."
    pip3 install --user yt-dlp 2>/dev/null || pip3 install --user --break-system-packages yt-dlp
else
    echo "  WARNING: Could not install yt-dlp. Install manually:"
    echo "    pipx install yt-dlp"
    echo "    # or"
    echo "    pip3 install --user yt-dlp"
fi

# ============================================
# Setup PATH
# ============================================
echo "[5/5] Setting up PATH..."

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
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

# Also add .local/bin for pipx
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
fi

echo ""
echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Installed tools:"
echo ""
echo "  convert-pdf          - Markdown/HTML/text to PDF"
echo "    convert-pdf convert --input doc.md"
echo "    convert-pdf convert --text '# Hello' --format markdown"
echo ""
echo "  yt-channel-downloader - Download YouTube videos"
echo "    yt-channel-downloader 'https://youtube.com/@Channel' 7"
echo "    yt-channel-downloader 'https://youtube.com/@Channel' 30 --mp3"
echo ""
echo "  yt-channel-clear     - Clean up downloads"
echo "    yt-channel-clear                    # List channels"
echo "    yt-channel-clear @Channel --confirm # Delete channel"
echo ""
echo "YouTube downloads will be saved to:"
echo "  $DOWNLOAD_DIR"
echo ""
echo "NOTE: Restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
