#!/usr/bin/env node
import OpenAI from "openai";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { execSync } from "child_process";

// Directories
const TRANSCRIPTS_DIR = path.join(process.env.HOME, ".openclaw/transcripts");
const ARCHIVE_FILE = path.join(TRANSCRIPTS_DIR, ".transcribe-archive.json");

// Ensure directories exist
if (!fs.existsSync(TRANSCRIPTS_DIR)) {
  fs.mkdirSync(TRANSCRIPTS_DIR, { recursive: true });
}

// Get file hash for duplicate detection
function getFileHash(filePath) {
  const fileBuffer = fs.readFileSync(filePath);
  return crypto.createHash("md5").update(fileBuffer).digest("hex");
}

// Load archive of completed transcriptions
function loadArchive() {
  if (fs.existsSync(ARCHIVE_FILE)) {
    try {
      return JSON.parse(fs.readFileSync(ARCHIVE_FILE, "utf-8"));
    } catch {
      return {};
    }
  }
  return {};
}

// Save archive
function saveArchive(archive) {
  fs.writeFileSync(ARCHIVE_FILE, JSON.stringify(archive, null, 2));
}

// Check if file was already transcribed
function getExistingTranscript(filePath, format) {
  const archive = loadArchive();
  const hash = getFileHash(filePath);
  const key = `${hash}-${format}`;

  if (archive[key] && fs.existsSync(archive[key].transcriptPath)) {
    return archive[key];
  }
  return null;
}

// Record completed transcription
function recordTranscription(filePath, format, transcriptPath, duration) {
  const archive = loadArchive();
  const hash = getFileHash(filePath);
  const key = `${hash}-${format}`;

  archive[key] = {
    originalFile: filePath,
    originalName: path.basename(filePath),
    transcriptPath: transcriptPath,
    format: format,
    duration: duration,
    transcribedAt: new Date().toISOString()
  };

  saveArchive(archive);
}

// Generate transcript filename
function getTranscriptPath(originalPath, format) {
  const baseName = path.basename(originalPath, path.extname(originalPath));
  const ext = format === "json" ? "json" : format === "srt" ? "srt" : format === "vtt" ? "vtt" : "txt";
  return path.join(TRANSCRIPTS_DIR, `${baseName}.${ext}`);
}

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
    } else if (args[i].startsWith("-") && args[i].length === 2) {
      const key = args[i].slice(1);
      const next = args[i + 1];
      if (next && !next.startsWith("-")) {
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

function getClient() {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    const configPath = path.join(process.env.HOME, ".openclaw/credentials/openai-key.txt");
    if (fs.existsSync(configPath)) {
      const key = fs.readFileSync(configPath, "utf-8").trim();
      return new OpenAI({ apiKey: key });
    }
    console.error("Error: OPENAI_API_KEY not set");
    console.error("Set it via: export OPENAI_API_KEY=your-key");
    console.error("Or save to: ~/.openclaw/credentials/openai-key.txt");
    process.exit(1);
  }
  return new OpenAI({ apiKey });
}

function formatDuration(seconds) {
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}m ${secs}s`;
}

function getMediaDuration(filePath) {
  try {
    const result = execSync(
      `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${filePath}"`,
      { encoding: "utf-8" }
    );
    return parseFloat(result.trim());
  } catch {
    return null;
  }
}

function extractAudio(videoPath, tempDir) {
  const audioPath = path.join(tempDir, "audio.mp3");
  console.log("Extracting audio from video...");
  try {
    execSync(
      `ffmpeg -i "${videoPath}" -vn -acodec libmp3lame -q:a 4 -y "${audioPath}" 2>/dev/null`,
      { encoding: "utf-8" }
    );
    return audioPath;
  } catch (error) {
    console.error("Error extracting audio. Make sure ffmpeg is installed.");
    process.exit(1);
  }
}

function isVideoFile(filePath) {
  const videoExts = [".mp4", ".mkv", ".avi", ".mov", ".webm", ".flv", ".wmv", ".m4v"];
  const ext = path.extname(filePath).toLowerCase();
  return videoExts.includes(ext);
}

function isAudioFile(filePath) {
  const audioExts = [".mp3", ".wav", ".m4a", ".ogg", ".flac", ".aac", ".wma", ".opus"];
  const ext = path.extname(filePath).toLowerCase();
  return audioExts.includes(ext);
}

const commands = {
  async transcribe(args) {
    const flags = parseFlags(args);
    const inputFile = flags.input || flags.i || flags._[0];
    const outputFormat = flags.format || flags.f || "text";
    const language = flags.language || flags.l || null;
    const outputFile = flags.output || flags.o || null;
    const model = flags.model || "gpt-4o-mini-transcribe";
    const forceRetranscribe = flags.force || false;

    if (!inputFile) {
      console.log("Usage: transcribe <file> [options]");
      console.log("");
      console.log("Options:");
      console.log("  --input, -i      Input audio/video file (required)");
      console.log("  --format, -f     Output format: text, srt, vtt, json (default: text)");
      console.log("  --language, -l   Language code (e.g., en, th, ja) - auto-detected if not set");
      console.log("  --output, -o     Save output to file");
      console.log("  --model          Model: gpt-4o-mini-transcribe (default), whisper-1");
      console.log("  --force          Re-transcribe even if already completed");
      console.log("");
      console.log("Supported formats:");
      console.log("  Video: mp4, mkv, avi, mov, webm, flv, wmv, m4v");
      console.log("  Audio: mp3, wav, m4a, ogg, flac, aac, wma, opus");
      console.log("");
      console.log("Examples:");
      console.log("  transcribe video.mp4");
      console.log("  transcribe audio.mp3 --format srt --output subtitles.srt");
      console.log("  transcribe meeting.m4a -f json -o transcript.json");
      console.log("  transcribe thai-video.mp4 --language th");
      console.log("  transcribe video.mp4 --force    # Re-transcribe");
      return;
    }

    // Resolve file path
    const resolvedPath = path.isAbsolute(inputFile) ? inputFile : path.resolve(process.cwd(), inputFile);

    if (!fs.existsSync(resolvedPath)) {
      console.error(`Error: File not found: ${resolvedPath}`);
      process.exit(1);
    }

    // Get file info
    const fileName = path.basename(resolvedPath);
    const fileSize = fs.statSync(resolvedPath).size;
    const fileSizeMB = (fileSize / (1024 * 1024)).toFixed(2);

    // Check if already transcribed
    if (!forceRetranscribe) {
      const existing = getExistingTranscript(resolvedPath, outputFormat);
      if (existing) {
        console.log("─".repeat(50));
        console.log("Already Transcribed");
        console.log("─".repeat(50));
        console.log(`File: ${fileName}`);
        console.log(`Status: ✓ Completed`);
        console.log(`Transcript: ${existing.transcriptPath}`);
        console.log(`Format: ${existing.format}`);
        console.log(`Transcribed: ${existing.transcribedAt}`);
        console.log("─".repeat(50));
        console.log("");
        console.log("Use --force to re-transcribe");
        return;
      }
    }

    console.log("─".repeat(50));
    console.log("Transcription");
    console.log("─".repeat(50));
    console.log(`File: ${fileName}`);
    console.log(`Size: ${fileSizeMB} MB`);

    let audioPath = resolvedPath;
    let tempDir = null;

    // Extract audio if video file
    if (isVideoFile(resolvedPath)) {
      tempDir = fs.mkdtempSync(path.join(process.env.HOME, ".openclaw/temp-transcribe-"));
      audioPath = extractAudio(resolvedPath, tempDir);
      console.log("Audio extracted successfully");
    } else if (!isAudioFile(resolvedPath)) {
      console.error("Error: Unsupported file format");
      console.error("Supported: mp4, mkv, avi, mov, webm, mp3, wav, m4a, ogg, flac");
      process.exit(1);
    }

    // Get duration
    const duration = getMediaDuration(audioPath);
    if (duration) {
      console.log(`Duration: ${formatDuration(duration)}`);
      const estimatedCost = (duration / 60) * 0.003;
      console.log(`Est. cost: $${estimatedCost.toFixed(4)}`);
    }

    console.log(`Model: ${model}`);
    console.log(`Format: ${outputFormat}`);
    if (language) console.log(`Language: ${language}`);
    console.log("─".repeat(50));
    console.log("");
    console.log("Transcribing...");

    const client = getClient();

    try {
      const transcriptionOptions = {
        file: fs.createReadStream(audioPath),
        model: model,
      };

      // Set response format
      if (outputFormat === "srt") {
        transcriptionOptions.response_format = "srt";
      } else if (outputFormat === "vtt") {
        transcriptionOptions.response_format = "vtt";
      } else if (outputFormat === "json") {
        transcriptionOptions.response_format = "verbose_json";
      } else {
        transcriptionOptions.response_format = "text";
      }

      if (language) {
        transcriptionOptions.language = language;
      }

      const response = await client.audio.transcriptions.create(transcriptionOptions);

      // Clean up temp files
      if (tempDir) {
        fs.rmSync(tempDir, { recursive: true, force: true });
      }

      // Format output
      let output;
      if (outputFormat === "json") {
        output = JSON.stringify(response, null, 2);
      } else if (typeof response === "object" && response.text) {
        output = response.text;
      } else {
        output = response;
      }

      console.log("");
      console.log("─".repeat(50));
      console.log("Transcript:");
      console.log("─".repeat(50));
      console.log(output);
      console.log("─".repeat(50));

      // Determine save path
      let savePath;
      if (outputFile) {
        savePath = path.isAbsolute(outputFile) ? outputFile : path.resolve(process.cwd(), outputFile);
      } else {
        // Auto-save to transcripts directory
        savePath = getTranscriptPath(resolvedPath, outputFormat);
      }

      // Save transcript
      fs.writeFileSync(savePath, output);
      console.log(`Saved to: ${savePath}`);

      // Record in archive
      recordTranscription(resolvedPath, outputFormat, savePath, duration);

      // Show stats
      if (duration) {
        const actualCost = (duration / 60) * 0.003;
        console.log(`Cost: ~$${actualCost.toFixed(4)} (${formatDuration(duration)} @ $0.003/min)`);
      }

    } catch (error) {
      // Clean up temp files on error
      if (tempDir) {
        fs.rmSync(tempDir, { recursive: true, force: true });
      }
      console.error("Error:", error.message);
      process.exit(1);
    }
  },

  async list() {
    const archive = loadArchive();
    const entries = Object.values(archive);

    if (entries.length === 0) {
      console.log("No transcriptions yet.");
      console.log("");
      console.log("Usage: transcribe <video.mp4>");
      return;
    }

    console.log("─".repeat(60));
    console.log("Completed Transcriptions");
    console.log("─".repeat(60));
    console.log(`Storage: ${TRANSCRIPTS_DIR}`);
    console.log("");

    for (const entry of entries) {
      const exists = fs.existsSync(entry.transcriptPath);
      const status = exists ? "✓" : "✗ (missing)";
      console.log(`${status} ${entry.originalName}`);
      console.log(`   Format: ${entry.format}`);
      console.log(`   Path: ${entry.transcriptPath}`);
      console.log(`   Date: ${entry.transcribedAt}`);
      console.log("");
    }

    console.log("─".repeat(60));
    console.log(`Total: ${entries.length} transcription(s)`);
  },

  async formats() {
    console.log(`
Output Formats:

  text    Plain text transcript (default)
          Best for: reading, editing, copy-paste

  srt     SubRip subtitle format with timestamps
          Best for: video subtitles, YouTube

  vtt     WebVTT subtitle format with timestamps
          Best for: HTML5 video, web players

  json    Detailed JSON with word-level timestamps
          Best for: programmatic access, analysis

Usage:
  transcribe video.mp4 --format srt
  transcribe audio.mp3 -f json -o transcript.json
`);
  },

  async help() {
    console.log(`
Transcribe - Audio/Video Transcription Tool

Commands:
  transcribe <file>   Transcribe audio or video file
  list                Show all completed transcriptions
  formats             Show output format details
  help                Show this help

Options for 'transcribe':
  --input, -i       Input file (audio or video)
  --format, -f      Output format: text, srt, vtt, json
  --language, -l    Language code (auto-detected if not set)
  --output, -o      Save transcript to file (default: ~/.openclaw/transcripts/)
  --model           OpenAI model (default: gpt-4o-mini-transcribe)
  --force           Re-transcribe even if already completed

Supported Files:
  Video: mp4, mkv, avi, mov, webm, flv, wmv, m4v
  Audio: mp3, wav, m4a, ogg, flac, aac, wma, opus

Examples:
  transcribe video.mp4
  transcribe podcast.mp3 --format srt
  transcribe meeting.m4a -f json
  transcribe thai-video.mp4 --language th
  transcribe video.mp4 --force              # Re-transcribe
  transcribe list                           # Show completed

Storage:
  Transcripts: ~/.openclaw/transcripts/
  Archive:     ~/.openclaw/transcripts/.transcribe-archive.json

Pricing:
  gpt-4o-mini-transcribe: $0.003/minute

Environment:
  OPENAI_API_KEY    Your OpenAI API key
  Or save to:       ~/.openclaw/credentials/openai-key.txt

Requirements:
  ffmpeg            Required for video file support
`);
  }
};

const [cmd, ...args] = process.argv.slice(2);

if (!cmd || cmd === "help" || cmd === "--help" || cmd === "-h") {
  commands.help();
} else if (commands[cmd]) {
  commands[cmd](args).catch(e => {
    console.error("Error:", e.message);
    process.exit(1);
  });
} else {
  // Default: treat as file path for transcribe command
  commands.transcribe([cmd, ...args]).catch(e => {
    console.error("Error:", e.message);
    process.exit(1);
  });
}
