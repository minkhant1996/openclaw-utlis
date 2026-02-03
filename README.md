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

## License

MIT License - Min Khant Soe, SoeMindAI, Inc.
