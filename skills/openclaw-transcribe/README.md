# OpenClaw Transcribe

Audio and video transcription tool for OpenClaw using OpenAI's transcription API.

## Features

- **Video & Audio Support**: MP4, MKV, AVI, MOV, MP3, WAV, M4A, and more
- **Multiple Output Formats**: Plain text, SRT subtitles, VTT subtitles, JSON
- **Auto Language Detection**: Or specify language for better accuracy
- **Cost Efficient**: Uses gpt-4o-mini-transcribe at $0.003/minute

## Installation

```bash
git clone git@github.com:BrookAI-BrookerGroupPCL/openclaw-transcribe.git
cd openclaw-transcribe
npm install
npm link
```

Or install via openclaw-utils installer.

## Requirements

- Node.js 18+
- OpenAI API key
- ffmpeg (for video file support)

```bash
# Install ffmpeg
sudo apt install ffmpeg  # Ubuntu/Debian
brew install ffmpeg      # macOS
```

## Quick Start

```bash
# Set API key
export OPENAI_API_KEY=your-key

# Transcribe video
transcribe video.mp4

# Generate subtitles
transcribe video.mp4 --format srt --output subtitles.srt
```

## Usage

```
transcribe <file> [options]

Options:
  --input, -i       Input file (audio or video)
  --format, -f      Output format: text, srt, vtt, json
  --language, -l    Language code (auto-detected if not set)
  --output, -o      Save transcript to file
  --model           OpenAI model (default: gpt-4o-mini-transcribe)
```

## Output Formats

| Format | Description | Use Case |
|--------|-------------|----------|
| `text` | Plain text | Reading, editing, copy-paste |
| `srt` | SubRip subtitles | YouTube, video players |
| `vtt` | WebVTT subtitles | HTML5 video, web players |
| `json` | Detailed JSON | Programmatic access, analysis |

## Supported Files

**Video**: mp4, mkv, avi, mov, webm, flv, wmv, m4v
**Audio**: mp3, wav, m4a, ogg, flac, aac, wma, opus

## Examples

```bash
# Basic transcription
transcribe interview.mp4

# SRT subtitles for YouTube
transcribe tutorial.mp4 -f srt -o tutorial.srt

# VTT for web video player
transcribe lecture.mp4 -f vtt -o lecture.vtt

# JSON with word-level timestamps
transcribe podcast.mp3 -f json -o episode.json

# Specify language for better accuracy
transcribe thai-meeting.mp4 --language th
transcribe japanese-video.mp4 -l ja -o transcript.txt
```

## Pricing

- **gpt-4o-mini-transcribe**: $0.003/minute
- Example costs:
  - 10 min video: ~$0.03
  - 1 hour video: ~$0.18
  - 1 hour podcast: ~$0.18

## Configuration

Set your OpenAI API key:

```bash
# Environment variable
export OPENAI_API_KEY=your-key

# Or save to file
mkdir -p ~/.openclaw/credentials
echo "your-key" > ~/.openclaw/credentials/openai-key.txt
```

## License

MIT
