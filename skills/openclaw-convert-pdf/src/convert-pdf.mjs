#!/usr/bin/env node
import puppeteer from "puppeteer";
import { marked } from "marked";
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const DOWNLOADS_DIR = "/var/www/openclaw-downloads";
const BASE_URL = "https://brookai.openclaw.brookreator.ai/downloads";

function parseFlags(args) {
  const result = { _: [] };
  let i = 0;
  while (i < args.length) {
    if (args[i].startsWith("--")) {
      const key = args[i].slice(2);
      const next = args[i + 1];
      if (next && !next.startsWith("--")) {
        result[key] = next;
        i += 2;
      } else {
        result[key] = true;
        i++;
      }
    } else {
      result._.push(args[i]);
      i++;
    }
  }
  return result;
}

function detectFormat(content, filename) {
  if (filename) {
    const ext = path.extname(filename).toLowerCase();
    if (ext === ".md" || ext === ".markdown") return "markdown";
    if (ext === ".html" || ext === ".htm") return "html";
    if (ext === ".txt") return "text";
  }
  
  // Auto-detect from content
  if (content.includes("<!DOCTYPE") || content.includes("<html") || content.includes("<body")) {
    return "html";
  }
  if (content.match(/^#{1,6}\s/m) || content.includes("**") || content.includes("```")) {
    return "markdown";
  }
  return "text";
}

function markdownToHtml(markdown) {
  return marked(markdown);
}

function textToHtml(text) {
  // Escape HTML and preserve formatting
  const escaped = text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\n/g, "<br>");
  return `<pre style="white-space: pre-wrap; font-family: monospace;">${escaped}</pre>`;
}

function wrapInHtmlDocument(content, title = "Document") {
  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${title}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, sans-serif;
      line-height: 1.6;
      max-width: 800px;
      margin: 40px auto;
      padding: 20px;
      color: #333;
    }
    h1, h2, h3, h4, h5, h6 {
      margin-top: 1.5em;
      margin-bottom: 0.5em;
      color: #111;
    }
    h1 { font-size: 2em; border-bottom: 2px solid #eee; padding-bottom: 0.3em; }
    h2 { font-size: 1.5em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
    code {
      background: #f4f4f4;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: Monaco, Menlo, monospace;
      font-size: 0.9em;
    }
    pre {
      background: #f8f8f8;
      padding: 16px;
      border-radius: 6px;
      overflow-x: auto;
      border: 1px solid #e1e1e1;
    }
    pre code {
      background: none;
      padding: 0;
    }
    blockquote {
      border-left: 4px solid #ddd;
      margin: 1em 0;
      padding-left: 1em;
      color: #666;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 1em 0;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 8px 12px;
      text-align: left;
    }
    th {
      background: #f4f4f4;
      font-weight: 600;
    }
    tr:nth-child(even) {
      background: #fafafa;
    }
    ul, ol {
      padding-left: 2em;
    }
    li {
      margin: 0.5em 0;
    }
    a {
      color: #0366d6;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    hr {
      border: none;
      border-top: 1px solid #eee;
      margin: 2em 0;
    }
    img {
      max-width: 100%;
      height: auto;
    }
  </style>
</head>
<body>
${content}
</body>
</html>`;
}

async function convertToPdf(html, outputPath, options = {}) {
  const browser = await puppeteer.launch({
    headless: true,
    executablePath: "/usr/bin/google-chrome",
    args: ["--no-sandbox", "--disable-setuid-sandbox"]
  });

  try {
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: "networkidle0" });
    
    await page.pdf({
      path: outputPath,
      format: options.format || "A4",
      margin: {
        top: options.margin || "20mm",
        right: options.margin || "20mm",
        bottom: options.margin || "20mm",
        left: options.margin || "20mm"
      },
      printBackground: true
    });
  } finally {
    await browser.close();
  }
}

function generateFilename(baseName) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const safeName = (baseName || "document").replace(/[^a-zA-Z0-9-_]/g, "_");
  return `${safeName}_${timestamp}.pdf`;
}

const commands = {
  async convert(args) {
    const flags = parseFlags(args);
    let content = "";
    let inputFilename = "";
    
    // Get input content
    if (flags.input || flags.file || flags.i) {
      const inputPath = flags.input || flags.file || flags.i;
      if (!fs.existsSync(inputPath)) {
        console.error("Error: File not found:", inputPath);
        process.exit(1);
      }
      content = fs.readFileSync(inputPath, "utf-8");
      inputFilename = path.basename(inputPath);
    } else if (flags.text || flags.t) {
      content = flags.text || flags.t;
    } else if (flags._[0]) {
      // Check if first arg is a file
      if (fs.existsSync(flags._[0])) {
        content = fs.readFileSync(flags._[0], "utf-8");
        inputFilename = path.basename(flags._[0]);
      } else {
        content = flags._[0];
      }
    } else {
      // Read from stdin
      content = fs.readFileSync(0, "utf-8");
    }

    if (!content.trim()) {
      console.error("Error: No content provided");
      console.log("Usage: convert-pdf convert --input file.md --output doc.pdf");
      process.exit(1);
    }

    // Detect or use specified format
    const format = flags.format || flags.f || detectFormat(content, inputFilename);
    
    // Convert to HTML
    let htmlContent;
    if (format === "html") {
      htmlContent = content;
      // Wrap if not a full document
      if (!content.includes("<body")) {
        htmlContent = wrapInHtmlDocument(content, flags.title || "Document");
      }
    } else if (format === "markdown") {
      const mdHtml = markdownToHtml(content);
      htmlContent = wrapInHtmlDocument(mdHtml, flags.title || "Document");
    } else {
      const textHtml = textToHtml(content);
      htmlContent = wrapInHtmlDocument(textHtml, flags.title || "Document");
    }

    // Generate output filename
    const baseName = flags.name || path.basename(inputFilename, path.extname(inputFilename)) || "document";
    const outputFilename = flags.output || flags.o || generateFilename(baseName);
    const outputPath = path.join(DOWNLOADS_DIR, outputFilename);

    console.log("Converting to PDF...");
    console.log("  Format: " + format);
    
    await convertToPdf(htmlContent, outputPath, {
      format: flags.paper || "A4",
      margin: flags.margin
    });

    const downloadUrl = `${BASE_URL}/${outputFilename}`;
    
    console.log("\n✅ PDF created successfully!");
    console.log("  File: " + outputFilename);
    console.log("  Download: " + downloadUrl);
    
    return downloadUrl;
  },

  async help() {
    console.log(`
OpenClaw Convert to PDF

Convert markdown, HTML, or plain text to downloadable PDF.

USAGE:
  convert-pdf convert [options]

INPUT (choose one):
  --input, -i <file>     Input file (markdown, HTML, or text)
  --text, -t "content"   Direct text content
  <file>                 File path as first argument
  (stdin)                Pipe content to convert-pdf

OPTIONS:
  --format, -f <type>    Input format: markdown, html, text (auto-detected)
  --output, -o <name>    Output filename (default: auto-generated)
  --title "Title"        Document title
  --paper <size>         Paper size: A4, Letter, Legal (default: A4)
  --margin <size>        Margin size (default: 20mm)

EXAMPLES:
  # Convert markdown file
  convert-pdf convert --input readme.md
  
  # Convert with custom output name
  convert-pdf convert --input doc.md --output my-document.pdf
  
  # Convert text directly
  convert-pdf convert --text "Hello World" --format text
  
  # Convert HTML
  convert-pdf convert --input page.html
  
  # Pipe markdown content
  echo "# Hello\\nThis is **bold**" | convert-pdf convert --format markdown
  
  # Convert with title
  convert-pdf convert --input notes.md --title "Meeting Notes"

OUTPUT:
  Returns a download URL like:
  https://brookai.openclaw.brookreator.ai/downloads/document_2026-02-03.pdf
`);
  }
};

// Aliases
commands.c = commands.convert;
commands.pdf = commands.convert;

const [cmd, ...args] = process.argv.slice(2);

if (!cmd || cmd === "help" || cmd === "--help" || cmd === "-h") {
  commands.help();
} else if (commands[cmd]) {
  commands[cmd](args).catch(e => {
    console.error("Error:", e.message);
    process.exit(1);
  });
} else {
  // Default to convert if no command specified
  commands.convert([cmd, ...args]).catch(e => {
    console.error("Error:", e.message);
    process.exit(1);
  });
}
