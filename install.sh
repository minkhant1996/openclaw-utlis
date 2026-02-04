#!/bin/bash
# OpenClaw Utils Installer
# https://github.com/minkhant1996/openclaw-utlis

set -e

REPO_URL="https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"
BIN_DIR="$HOME/bin"
YT_DOWNLOAD_DIR="$HOME/youtube-downloads"
X_DOWNLOAD_DIR="$HOME/x-downloads"

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
echo "[1/7] Installing openclaw-convert-pdf..."

SKILL_DIR="$SKILLS_DIR/openclaw-convert-pdf"
mkdir -p "$SKILL_DIR"

# Download files
curl -s "$REPO_URL/skills/openclaw-convert-pdf/src/convert-pdf.mjs" -o "$SKILL_DIR/convert-pdf.mjs"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/SKILL.md" -o "$SKILL_DIR/SKILL.md"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/package.json" -o "$SKILL_DIR/package.json"

echo "[2/7] Installing npm dependencies for convert-pdf..."
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
echo "[3/7] Installing openclaw-youtube..."

YT_SKILL_DIR="$SKILLS_DIR/openclaw-youtube"
mkdir -p "$YT_SKILL_DIR"
mkdir -p "$YT_DOWNLOAD_DIR"

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
# Install openclaw-x
# ============================================
echo "[4/7] Installing openclaw-x..."

X_SKILL_DIR="$SKILLS_DIR/openclaw-x"
mkdir -p "$X_SKILL_DIR"
mkdir -p "$X_DOWNLOAD_DIR"

# Download files
curl -s "$REPO_URL/skills/openclaw-x/x-channel-downloader" -o "$X_SKILL_DIR/x-channel-downloader"
curl -s "$REPO_URL/skills/openclaw-x/x-channel-clear" -o "$X_SKILL_DIR/x-channel-clear"
curl -s "$REPO_URL/skills/openclaw-x/README.md" -o "$X_SKILL_DIR/README.md"
chmod +x "$X_SKILL_DIR/x-channel-downloader"
chmod +x "$X_SKILL_DIR/x-channel-clear"

# Create symlinks in bin
ln -sf "$X_SKILL_DIR/x-channel-downloader" "$BIN_DIR/x-channel-downloader"
ln -sf "$X_SKILL_DIR/x-channel-clear" "$BIN_DIR/x-channel-clear"

# ============================================
# Install yt-dlp dependency
# ============================================
echo "[5/7] Checking yt-dlp dependency..."

if command -v yt-dlp &> /dev/null; then
    echo "  yt-dlp already installed: $(yt-dlp --version)"
elif command -v pipx &> /dev/null; then
    echo "  Installing yt-dlp via pipx..."
    pipx install yt-dlp
elif command -v pip3 &> /dev/null; then
    echo "  Installing yt-dlp via pip3..."
    pip3 install --user yt-dlp 2>/dev/null || pip3 install --user --break-system-packages yt-dlp
else
    echo "  WARNING: Could not install yt-dlp. Install manually:"
    echo "    pipx install yt-dlp"
fi

# ============================================
# Install gallery-dl dependency
# ============================================
echo "[6/7] Checking gallery-dl dependency..."

if command -v gallery-dl &> /dev/null; then
    echo "  gallery-dl already installed: $(gallery-dl --version 2>/dev/null | head -1)"
elif command -v pipx &> /dev/null; then
    echo "  Installing gallery-dl via pipx..."
    pipx install gallery-dl
elif command -v pip3 &> /dev/null; then
    echo "  Installing gallery-dl via pip3..."
    pip3 install --user gallery-dl 2>/dev/null || pip3 install --user --break-system-packages gallery-dl
else
    echo "  WARNING: Could not install gallery-dl. Install manually:"
    echo "    pipx install gallery-dl"
fi

# ============================================
# Setup PATH
# ============================================
echo "[7/7] Setting up PATH..."

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    fi
    if [ -f ~/.zshrc ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    fi
    export PATH="$BIN_DIR:$PATH"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
fi

# Ensure pipx path
command -v pipx &> /dev/null && pipx ensurepath 2>/dev/null || true

echo ""
echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Installed tools:"
echo ""
echo "  convert-pdf           - Markdown/HTML/text to PDF"
echo "    convert-pdf convert --input doc.md"
echo ""
echo "  yt-channel-downloader - Download YouTube videos/MP3"
echo "    yt-channel-downloader 'https://youtube.com/@Channel' 7"
echo "    yt-channel-downloader 'https://youtube.com/@Channel' 30 --mp3"
echo ""
echo "  yt-channel-clear      - Clean up YouTube downloads"
echo "    yt-channel-clear @Channel --confirm"
echo ""
echo "  x-channel-downloader  - Download X (Twitter) posts"
echo "    x-channel-downloader @username 7"
echo "    x-channel-downloader @username 30 --video"
echo ""
echo "  x-channel-clear       - Clean up X downloads"
echo "    x-channel-clear @username --confirm"
echo ""
echo "Download locations:"
echo "  YouTube: $YT_DOWNLOAD_DIR"
echo "  X:       $X_DOWNLOAD_DIR"
echo ""
echo "NOTE: Restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
