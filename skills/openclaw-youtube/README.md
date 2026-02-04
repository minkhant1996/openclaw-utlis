# OpenClaw YouTube Tools

Download and manage YouTube videos from channels with date filtering and tracking.

## Requirements

- `yt-dlp` - Install with `pipx install yt-dlp`
- `ffmpeg` - For MP3 conversion

## Installation

```bash
# Install yt-dlp
pipx install yt-dlp

# Or on Ubuntu with externally-managed Python
sudo apt install pipx ffmpeg
pipx install yt-dlp
pipx ensurepath
```

## Commands

### yt-channel-downloader

Download videos from a YouTube channel with date filtering.

```bash
# Download videos from last 7 days (default)
yt-channel-downloader "https://www.youtube.com/@ChannelName" 7

# Download as MP3 (audio only)
yt-channel-downloader "https://www.youtube.com/@ChannelName" 30 --mp3

# Download since specific date
yt-channel-downloader "https://www.youtube.com/@ChannelName" 2024-01-15
```

**Options:**
| Flag | Description |
|------|-------------|
| `--mp3`, `-a` | Download audio only as MP3 |
| `--video`, `-v` | Download video (default, max 1080p) |
| `7`, `30`, etc. | Number of days back |
| `YYYY-MM-DD` | Since specific date |

### yt-channel-clear

Clean up downloaded videos.

```bash
# List all channels and sizes
yt-channel-clear

# Delete all from a channel
yt-channel-clear @ChannelName --confirm

# Delete files older than 30 days
yt-channel-clear @ChannelName --older 30 --confirm

# Delete only MP3s
yt-channel-clear @ChannelName --mp3 --confirm

# Preview without deleting
yt-channel-clear @ChannelName --dry-run

# Delete everything
yt-channel-clear --all --confirm
```

**Options:**
| Flag | Description |
|------|-------------|
| `--older <days>` | Only delete files older than N days |
| `--mp3` | Only delete MP3 files |
| `--video` | Only delete video files |
| `--all`, `-A` | Delete all downloads |
| `--confirm`, `-y` | Required to actually delete |
| `--dry-run`, `-n` | Preview without deleting |

## Storage

```
~/youtube-downloads/
├── @ChannelName/
│   ├── 20240201 - Video Title [abc123].mp4
│   └── 20240203 - Another Video [xyz789].mp3
├── download-history.csv      # Log of all downloads
└── .download-archive.txt     # Tracks downloaded videos
```

## CSV Log Format

```csv
video_id,title,channel,upload_date,download_date,format,file_path,filesize
abc123,"Video Title","@Channel",20240201,2024-02-01_10:30:00,video,"/path/to/file.mp4",150M
```

## Features

- **Date filtering**: Download only videos from a specific time range
- **Duplicate prevention**: Won't re-download already downloaded videos
- **Format tracking**: Tracks video and MP3 separately (can download same video as both)
- **CSV logging**: Full history of downloads with metadata
- **Safe deletion**: Requires `--confirm` flag, supports `--dry-run`
