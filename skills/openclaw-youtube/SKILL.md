---
name: openclaw-youtube
description: "Download YouTube videos and MP3 from channels with date filtering. Track downloads and clean up old files."
metadata:
  {
    "openclaw":
      {
        "emoji": "📺",
        "requires": { "bins": ["yt-channel-downloader", "yt-channel-clear"] }
      }
  }
---

# YouTube Channel Downloader

Download videos or MP3 audio from YouTube channels with date filtering and tracking.

## Commands

### Download Videos/MP3

```bash
# Download videos from last 7 days
yt-channel-downloader "https://www.youtube.com/@ChannelName" 7

# Download as MP3 (audio only)
yt-channel-downloader "https://www.youtube.com/@ChannelName" 30 --mp3

# Download since specific date
yt-channel-downloader "https://www.youtube.com/@ChannelName" 2024-01-15
```

### Options
- `--mp3`, `-a` - Download audio only as MP3
- `--video`, `-v` - Download video (default, max 1080p)
- `7`, `30`, etc. - Number of days back
- `YYYY-MM-DD` - Since specific date

### Clean Up Downloads

```bash
yt-channel-clear                           # List all channels
yt-channel-clear @ChannelName --confirm    # Delete all from channel
yt-channel-clear @ChannelName --older 30 --confirm  # Delete older than 30 days
yt-channel-clear @ChannelName --mp3 --confirm  # Delete only MP3s
yt-channel-clear @ChannelName --dry-run    # Preview without deleting
```

## Storage

- Downloads: `~/youtube-downloads/@ChannelName/`
- Log: `~/youtube-downloads/download-history.csv`
- Archive: `~/youtube-downloads/.download-archive.txt`

## Features

- Date filtering (days or specific date)
- Video or MP3 format
- Duplicate prevention via archive
- CSV logging of all downloads
- Safe deletion with --confirm requirement
