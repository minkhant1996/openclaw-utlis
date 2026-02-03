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

# OpenClaw Convert to PDF

Convert markdown, HTML, or plain text to downloadable PDF files.

## Commands

### Convert File
```bash
convert-pdf convert --input document.md
convert-pdf convert --input page.html --output report.pdf
```

### Convert Text Directly
```bash
convert-pdf convert --text "# Hello World\nThis is **bold** text" --format markdown
convert-pdf convert --text "Plain text content" --format text
```

### With Options
```bash
convert-pdf convert --input doc.md --title "My Report" --paper A4
convert-pdf convert --input notes.md --output meeting-notes.pdf --margin 15mm
```

## Supported Formats

| Format | Description |
|--------|-------------|
| `markdown` | Markdown with full styling (headers, lists, code, tables) |
| `html` | HTML content (inline styles supported) |
| `text` | Plain text (preserves formatting) |

Format is auto-detected from file extension or content.

## Output

Returns a download URL:
```
https://brookai.openclaw.brookreator.ai/downloads/document_2026-02-03.pdf
```

## Examples

**Create PDF from markdown:**
```bash
convert-pdf convert --input README.md --title "Documentation"
```

**Quick text to PDF:**
```bash
convert-pdf convert --text "Meeting Notes\n- Item 1\n- Item 2" --format text
```

For full help: `convert-pdf help`
