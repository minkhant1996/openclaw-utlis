#!/bin/bash
# OpenClaw Utils Installer
# https://github.com/minkhant1996/openclaw-utlis

set -e

REPO_URL="https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main"
GOOGLE_REPO_URL="https://raw.githubusercontent.com/minkhant1996/openclaw-google-skills/main"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"
GOOGLE_SKILLS_DIR="$HOME/.openclaw/google-skills"
CREDENTIALS_DIR="$HOME/.openclaw/credentials"
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
mkdir -p "$GOOGLE_SKILLS_DIR"
mkdir -p "$CREDENTIALS_DIR"

# ============================================
# Install openclaw-convert-pdf
# ============================================
echo "[1/12] Installing openclaw-convert-pdf..."

SKILL_DIR="$SKILLS_DIR/openclaw-convert-pdf"
mkdir -p "$SKILL_DIR"

curl -s "$REPO_URL/skills/openclaw-convert-pdf/src/convert-pdf.mjs" -o "$SKILL_DIR/convert-pdf.mjs"
curl -s "$REPO_URL/skills/openclaw-convert-pdf/SKILL.md" -o "$SKILL_DIR/SKILL.md" 2>/dev/null || true
curl -s "$REPO_URL/skills/openclaw-convert-pdf/package.json" -o "$SKILL_DIR/package.json"

echo "[2/12] Installing npm dependencies for convert-pdf..."
cd "$SKILL_DIR"
npm install --silent 2>/dev/null || npm install

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
echo "[3/12] Installing openclaw-youtube..."

YT_SKILL_DIR="$SKILLS_DIR/openclaw-youtube"
mkdir -p "$YT_SKILL_DIR"
mkdir -p "$YT_DOWNLOAD_DIR"

curl -s "$REPO_URL/skills/openclaw-youtube/yt-channel-downloader" -o "$YT_SKILL_DIR/yt-channel-downloader"
curl -s "$REPO_URL/skills/openclaw-youtube/yt-channel-clear" -o "$YT_SKILL_DIR/yt-channel-clear"
curl -s "$REPO_URL/skills/openclaw-youtube/README.md" -o "$YT_SKILL_DIR/README.md" 2>/dev/null || true
chmod +x "$YT_SKILL_DIR/yt-channel-downloader"
chmod +x "$YT_SKILL_DIR/yt-channel-clear"

ln -sf "$YT_SKILL_DIR/yt-channel-downloader" "$BIN_DIR/yt-channel-downloader"
ln -sf "$YT_SKILL_DIR/yt-channel-clear" "$BIN_DIR/yt-channel-clear"

# ============================================
# Install openclaw-x
# ============================================
echo "[4/12] Installing openclaw-x..."

X_SKILL_DIR="$SKILLS_DIR/openclaw-x"
mkdir -p "$X_SKILL_DIR"
mkdir -p "$X_DOWNLOAD_DIR"

curl -s "$REPO_URL/skills/openclaw-x/x-channel-downloader" -o "$X_SKILL_DIR/x-channel-downloader"
curl -s "$REPO_URL/skills/openclaw-x/x-channel-clear" -o "$X_SKILL_DIR/x-channel-clear"
curl -s "$REPO_URL/skills/openclaw-x/README.md" -o "$X_SKILL_DIR/README.md" 2>/dev/null || true
chmod +x "$X_SKILL_DIR/x-channel-downloader"
chmod +x "$X_SKILL_DIR/x-channel-clear"

ln -sf "$X_SKILL_DIR/x-channel-downloader" "$BIN_DIR/x-channel-downloader"
ln -sf "$X_SKILL_DIR/x-channel-clear" "$BIN_DIR/x-channel-clear"

# ============================================
# Install openclaw-content-agent
# ============================================
echo "[5/12] Installing openclaw-content-agent..."

CONTENT_REPO_URL="https://raw.githubusercontent.com/BrookAI-BrookerGroupPCL/openclaw-content-agent/main"
CONTENT_SKILL_DIR="$SKILLS_DIR/openclaw-content-agent"
mkdir -p "$CONTENT_SKILL_DIR/src"

curl -s "$CONTENT_REPO_URL/src/content-creator.mjs" -o "$CONTENT_SKILL_DIR/src/content-creator.mjs"
curl -s "$CONTENT_REPO_URL/package.json" -o "$CONTENT_SKILL_DIR/package.json"
curl -s "$CONTENT_REPO_URL/SKILL.md" -o "$CONTENT_SKILL_DIR/SKILL.md" 2>/dev/null || true
curl -s "$CONTENT_REPO_URL/README.md" -o "$CONTENT_SKILL_DIR/README.md" 2>/dev/null || true

cd "$CONTENT_SKILL_DIR"
npm install --silent 2>/dev/null || npm install

cat > "$BIN_DIR/content-creator" << 'WRAPPER'
#!/bin/bash
cd ~/.openclaw/workspace/skills/openclaw-content-agent
node src/content-creator.mjs "$@"
WRAPPER
chmod +x "$BIN_DIR/content-creator"

# ============================================
# Install openclaw-google-skills
# ============================================
echo "[6/12] Installing openclaw-transcribe..."

TRANSCRIBE_DIR="$SKILLS_DIR/openclaw-transcribe"
mkdir -p "$TRANSCRIBE_DIR/src"
mkdir -p "$HOME/.openclaw/transcripts"

curl -s "$REPO_URL/skills/openclaw-transcribe/src/transcribe.mjs" -o "$TRANSCRIBE_DIR/src/transcribe.mjs"
curl -s "$REPO_URL/skills/openclaw-transcribe/package.json" -o "$TRANSCRIBE_DIR/package.json"
curl -s "$REPO_URL/skills/openclaw-transcribe/SKILL.md" -o "$TRANSCRIBE_DIR/SKILL.md" 2>/dev/null || true

cd "$TRANSCRIBE_DIR"
npm install --silent 2>/dev/null || npm install

cat > "$BIN_DIR/transcribe" << 'WRAPPER'
#!/bin/bash
CWD=$(pwd)
cd ~/.openclaw/workspace/skills/openclaw-transcribe
ARGS=()
for arg in "$@"; do
  if [[ "$arg" != --* ]] && [[ "$arg" != -* ]] && [[ -e "$CWD/$arg" ]]; then
    ARGS+=("$CWD/$arg")
  else
    ARGS+=("$arg")
  fi
done
node src/transcribe.mjs "${ARGS[@]}"
WRAPPER
chmod +x "$BIN_DIR/transcribe"

# ============================================
# Install openclaw-google-skills
# ============================================
echo "[7/12] Installing openclaw-google-skills..."

# Download Google skill files
for skill in gmail gslides gsheet gdocs gcal gdrive; do
    curl -s "$GOOGLE_REPO_URL/src/${skill}.mjs" -o "$GOOGLE_SKILLS_DIR/${skill}.mjs" 2>/dev/null || true
done

# Create package.json if not exists
if [ ! -f "$GOOGLE_SKILLS_DIR/package.json" ]; then
    cat > "$GOOGLE_SKILLS_DIR/package.json" << 'PKGJSON'
{
  "name": "openclaw-google-skills",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "googleapis": "^140.0.0"
  }
}
PKGJSON
fi

# Install npm dependencies
cd "$GOOGLE_SKILLS_DIR"
npm install --silent 2>/dev/null || npm install

# Create wrapper scripts for each Google tool
for skill in gmail gslides gsheet gdocs gcal gdrive; do
    cat > "$BIN_DIR/$skill" << WRAPPER
#!/bin/bash
cd ~/.openclaw/google-skills
node ${skill}.mjs "\$@"
WRAPPER
    chmod +x "$BIN_DIR/$skill"
done

# ============================================
# Install yt-dlp dependency
# ============================================
echo "[8/12] Checking yt-dlp..."

if command -v yt-dlp &> /dev/null; then
    echo "  yt-dlp already installed"
elif command -v pipx &> /dev/null; then
    pipx install yt-dlp 2>/dev/null || true
elif command -v pip3 &> /dev/null; then
    pip3 install --user yt-dlp 2>/dev/null || pip3 install --user --break-system-packages yt-dlp 2>/dev/null || true
fi

# ============================================
# Install gallery-dl dependency
# ============================================
echo "[9/12] Checking gallery-dl..."

if command -v gallery-dl &> /dev/null; then
    echo "  gallery-dl already installed"
elif command -v pipx &> /dev/null; then
    pipx install gallery-dl 2>/dev/null || true
elif command -v pip3 &> /dev/null; then
    pip3 install --user gallery-dl 2>/dev/null || pip3 install --user --break-system-packages gallery-dl 2>/dev/null || true
fi

# ============================================
# Setup PATH
# ============================================
echo "[10/12] Setting up PATH..."

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    fi
    if [ -f ~/.zshrc ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    fi
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
fi

command -v pipx &> /dev/null && pipx ensurepath 2>/dev/null || true

# ============================================
# Setup Config Files
# ============================================
echo "[11/12] Setting up config files..."

WORKSPACE_DIR="$HOME/.openclaw/workspace"
mkdir -p "$WORKSPACE_DIR"

# Create/Update TOOLS.md
TOOLS_FILE="$WORKSPACE_DIR/TOOLS.md"
if [ ! -f "$TOOLS_FILE" ]; then
    cat > "$TOOLS_FILE" << 'TOOLSEOF'
# Tool Usage Guide

## CRITICAL RULES

1. **NEVER use browser** for Google Workspace services
2. **ALWAYS use CLI commands** listed below
3. **NEVER guess** - check command help with `<command> --help`

---

## Google Slides (`gslides`)

```bash
gslides create "Presentation Name"
gslides title-slide <id> --title "Title" --subtitle "Subtitle"
gslides create-slide <id> --title "Title" --body "Line1\nLine2" --bullets
gslides read <id>
```

---

## Google Sheets (`gsheet`)

```bash
gsheet create "Spreadsheet Name"
gsheet read <id> --range "A1:D20"
gsheet write <id> --range "A1" --value "Header"
gsheet add-chart <id> --labels "A2:A10" --values "B2:B10" --type column
```

---

## Google Docs (`gdocs`)

```bash
gdocs create "Document Name"
gdocs read <id>
gdocs append <id> --text "Content"
gdocs heading <id> --text "Section" --level 1
```

---

## Gmail (`gmail`)

**TWO-STEP CONFIRMATION REQUIRED:**

```bash
# Step 1: Preview
gmail send --to "email@example.com" --subject "Subject" --body "Message"

# Step 2: After approval, add --confirm
gmail send --to "email@example.com" --subject "Subject" --body "Message" --confirm
```

---

## Google Calendar (`gcal`)

```bash
gcal list
gcal today
gcal create "Event" --start "tomorrow 2pm" --duration 1h
```

---

## Google Drive (`gdrive`)

```bash
gdrive list
gdrive search "filename"
gdrive upload file.pdf --to <folderId>
gdrive download <fileId> --output local.pdf
```

---

## YouTube Downloader (`yt-channel-downloader`)

```bash
yt-channel-downloader "https://youtube.com/@Channel" 7         # Last 7 days
yt-channel-downloader "https://youtube.com/@Channel" 30 --mp3  # MP3, 30 days
yt-channel-clear @Channel --confirm                            # Delete
```

---

## X (Twitter) Downloader (`x-channel-downloader`)

```bash
x-channel-downloader @username 7            # Last 7 days
x-channel-downloader @username 30 --video   # Videos only
x-channel-clear @username --confirm         # Delete
```

---

## PDF Converter (`convert-pdf`)

```bash
convert-pdf convert --input document.md --output result.pdf
convert-pdf convert --text "# Title\nContent" --format markdown
```

---

## Content Creator (`content-creator`)

```bash
content-creator create "building in public"              # X thread
content-creator create "AI tips" --format linkedin       # LinkedIn post
content-creator create "morning routines" --format script  # Video script
content-creator create "startup lessons" --format carousel # Carousel
```

---

## Transcribe (`transcribe`)

```bash
transcribe video.mp4                     # Transcribe (auto-saves)
transcribe audio.mp3 --format srt        # SRT subtitles
transcribe video.mp4 --format vtt        # VTT subtitles
transcribe meeting.m4a --language th     # Thai language
transcribe list                          # Show completed
transcribe video.mp4 --force             # Re-transcribe
```

TOOLSEOF
    echo "  Created TOOLS.md"
fi

# Create gallery-dl config
GALLERY_CONFIG_DIR="$HOME/.config/gallery-dl"
GALLERY_CONFIG="$GALLERY_CONFIG_DIR/config.json"
mkdir -p "$GALLERY_CONFIG_DIR"

if [ ! -f "$GALLERY_CONFIG" ]; then
    cat > "$GALLERY_CONFIG" << 'GALLERYEOF'
{
    "extractor": {
        "twitter": {
            "cards": true,
            "quoted": true,
            "retweets": false,
            "text-tweets": false,
            "videos": true
        },
        "base-directory": "~/x-downloads/"
    },
    "downloader": {
        "rate": "1M",
        "retries": 3
    }
}
GALLERYEOF
    echo "  Created gallery-dl config"
fi

# Check for Google credentials
GOOGLE_CREDS="$CREDENTIALS_DIR/google-oauth-client.json"
GOOGLE_TOKEN="$CREDENTIALS_DIR/google-token.json"

echo ""
echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Installed tools:"
echo ""
echo "  PDF:        convert-pdf"
echo "  Content:    content-creator"
echo "  Transcribe: transcribe"
echo "  YouTube:    yt-channel-downloader, yt-channel-clear"
echo "  X:          x-channel-downloader, x-channel-clear"
echo "  Google:     gmail, gslides, gsheet, gdocs, gcal, gdrive"
echo ""
echo "Download locations:"
echo "  YouTube: $YT_DOWNLOAD_DIR"
echo "  X:       $X_DOWNLOAD_DIR"
echo ""

# Google credentials check
if [ ! -f "$GOOGLE_CREDS" ]; then
    echo "========================================"
    echo "  Google Setup Required"
    echo "========================================"
    echo ""
    echo "To use Google tools (gmail, gslides, etc.):"
    echo ""
    echo "1. Go to: https://console.cloud.google.com/"
    echo "2. Create OAuth 2.0 credentials (Desktop app)"
    echo "3. Download JSON and save as:"
    echo "   $GOOGLE_CREDS"
    echo ""
    echo "4. Run any Google command to authenticate:"
    echo "   gmail inbox"
    echo ""
else
    echo "Google credentials: OK"
    if [ -f "$GOOGLE_TOKEN" ]; then
        echo "Google token: OK (authenticated)"
    else
        echo "Google token: Run 'gmail inbox' to authenticate"
    fi
fi

echo ""
echo "NOTE: Restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
