# OpenClaw Utils

A collection of utility skills for OpenClaw.

## Skills

| Skill | Description | Command |
|-------|-------------|---------|
| [openclaw-convert-pdf](skills/openclaw-convert-pdf/) | Convert markdown, HTML, or text to downloadable PDF | `convert-pdf` |

## Quick Install

```bash
bash <(curl -s https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main/install.sh)
```

## Manual Installation

### openclaw-convert-pdf

```bash
# Create skill directory
mkdir -p ~/.openclaw/workspace/skills/openclaw-convert-pdf

# Download files
curl -s https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main/skills/openclaw-convert-pdf/src/convert-pdf.mjs \
  -o ~/.openclaw/workspace/skills/openclaw-convert-pdf/convert-pdf.mjs

curl -s https://raw.githubusercontent.com/minkhant1996/openclaw-utlis/main/skills/openclaw-convert-pdf/SKILL.md \
  -o ~/.openclaw/workspace/skills/openclaw-convert-pdf/SKILL.md

# Install dependencies
cd ~/.openclaw/workspace/skills/openclaw-convert-pdf
npm init -y
npm install puppeteer marked

# Create wrapper script
mkdir -p ~/bin
cat > ~/bin/convert-pdf << 'EOF'
#!/bin/bash
cd ~/.openclaw/workspace/skills/openclaw-convert-pdf
node convert-pdf.mjs "$@"
EOF
chmod +x ~/bin/convert-pdf

# Add to PATH (add to ~/.bashrc for persistence)
export PATH="$HOME/bin:$PATH"
```

## Requirements

- Node.js 20+
- Google Chrome (for PDF generation)
- OpenClaw

## Usage

### Convert Markdown to PDF
```bash
convert-pdf convert --input document.md
convert-pdf convert --input README.md --output docs.pdf --title "Documentation"
```

### Convert Text Directly
```bash
convert-pdf convert --text "# Hello\nThis is **bold**" --format markdown
```

### Options
- `--input, -i` - Input file path
- `--text, -t` - Direct text content
- `--format, -f` - Input format: markdown, html, text (auto-detected)
- `--output, -o` - Output filename
- `--title` - Document title
- `--paper` - Paper size: A4, Letter (default: A4)
- `--margin` - Margin size (default: 20mm)

## OpenClaw Agent Configuration

To ensure the OpenClaw agent uses `convert-pdf` instead of other tools (like pandoc or markdown-pdf), configure the following:

### 1. Register the Skill

Create `~/.openclaw/skills/openclaw-convert-pdf/SKILL.md`:

```yaml
---
name: openclaw-convert-pdf
description: "Convert markdown, HTML, or text to downloadable PDF"
metadata:
  {
    "openclaw":
      {
        "emoji": "📄",
        "requires": { "bins": ["convert-pdf"] }
      }
  }
---

# PDF Converter Skill

Use `convert-pdf` CLI command. NEVER use pandoc or markdown-pdf.

## Commands
- `convert-pdf convert --input file.md` - Convert file to PDF
- `convert-pdf convert --text "# Title" --format markdown` - Convert text directly

## Options
- `--input, -i` - Input file path
- `--text, -t` - Direct text content
- `--format, -f` - Format: markdown, html, text
- `--output, -o` - Output filename
- `--title` - Document title
```

### 2. Update TOOLS.md (Optional)

Add to `~/.openclaw/workspace/TOOLS.md`:

```markdown
## PDF Conversion

**ALWAYS use `convert-pdf` for PDF generation. NEVER use pandoc or markdown-pdf.**

### Commands
- `convert-pdf convert --input document.md` - Convert markdown file
- `convert-pdf convert --text "# Hello" --format markdown` - Convert text directly
- `convert-pdf convert --input file.html --output result.pdf` - Convert HTML
```

### 3. Restart OpenClaw

After making configuration changes:
```bash
pkill -f openclaw
openclaw
```

## Nginx Setup (for Download URLs)

If you want PDFs to be downloadable via URL:

```bash
# Create downloads directory
sudo mkdir -p /var/www/openclaw-downloads
sudo chown $USER:$USER /var/www/openclaw-downloads

# Add to Nginx config
sudo nano /etc/nginx/sites-available/openclaw
```

Add this location block:
```nginx
location /downloads/ {
    alias /var/www/openclaw-downloads/;
    autoindex off;
    add_header Content-Disposition "attachment";
}
```

Then reload Nginx:
```bash
sudo nginx -t && sudo systemctl reload nginx
```

## License

MIT License - Min Khant Soe
