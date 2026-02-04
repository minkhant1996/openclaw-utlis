---
name: openclaw-transcribe
description: "Transcribe audio and video files to text, SRT subtitles, or VTT using OpenAI."
metadata:
  {
    "openclaw":
      {
        "emoji": "🎙️",
        "requires": { "bins": ["transcribe"] }
      }
  }
---

# Audio/Video Transcription

Transcribe audio and video files using OpenAI's gpt-4o-mini-transcribe model.

## Commands

### Transcribe Files

```bash
# Basic transcription (auto-saved to ~/.openclaw/transcripts/)
transcribe video.mp4
transcribe audio.mp3

# Generate SRT subtitles
transcribe video.mp4 --format srt

# Generate VTT subtitles (for web)
transcribe video.mp4 --format vtt

# Get JSON with timestamps
transcribe audio.m4a --format json

# Specify language (for better accuracy)
transcribe thai-video.mp4 --language th
transcribe japanese-audio.mp3 -l ja

# Re-transcribe (skip duplicate detection)
transcribe video.mp4 --force
```

### List Completed Transcriptions

```bash
transcribe list
```

### Options

- `--input, -i` - Input audio/video file
- `--format, -f` - Output format: text, srt, vtt, json
- `--language, -l` - Language code (auto-detected if not set)
- `--output, -o` - Custom output path (default: ~/.openclaw/transcripts/)
- `--model` - OpenAI model (default: gpt-4o-mini-transcribe)
- `--force` - Re-transcribe even if already completed

### View Format Details

```bash
transcribe formats
```

## Output Formats

| Format | Description | Best For |
|--------|-------------|----------|
| `text` | Plain text transcript | Reading, editing |
| `srt` | SubRip subtitles with timestamps | YouTube, video players |
| `vtt` | WebVTT subtitles | HTML5 video, web |
| `json` | Detailed JSON with word timestamps | Programming, analysis |

## Supported Files

**Video:** mp4, mkv, avi, mov, webm, flv, wmv, m4v
**Audio:** mp3, wav, m4a, ogg, flac, aac, wma, opus

## Pricing

- **gpt-4o-mini-transcribe**: $0.003/minute
- 1 hour video = ~$0.18

## Examples

```bash
# Transcribe YouTube download
transcribe ~/youtube-downloads/@Channel/video.mp4

# Create subtitles for video
transcribe presentation.mp4 -f srt -o presentation.srt

# Transcribe podcast with JSON output
transcribe podcast.mp3 --format json --output episode.json

# Thai language video
transcribe meeting.mp4 --language th -o meeting.txt
```

## Requirements

- OpenAI API key
- ffmpeg (for video files)

## Setup

```bash
# Set API key
export OPENAI_API_KEY=your-key

# Or save to file
echo "your-key" > ~/.openclaw/credentials/openai-key.txt

# Install ffmpeg (if not installed)
sudo apt install ffmpeg
```
