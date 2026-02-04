---
name: openclaw-x
description: "Download posts, images, and videos from public X (Twitter) accounts with date filtering."
metadata:
  {
    "openclaw":
      {
        "emoji": "𝕏",
        "requires": { "bins": ["x-channel-downloader", "x-channel-clear"] }
      }
  }
---

# X (Twitter) Channel Downloader

Download posts, images, and videos from public X (Twitter) accounts.

## Commands

### Download Content

```bash
# Download all media from last 7 days
x-channel-downloader @username 7

# Download videos only
x-channel-downloader @username 30 --video

# Download images only
x-channel-downloader @username 7 --image

# Include retweets
x-channel-downloader @username 7 --retweets

# Download since specific date
x-channel-downloader @username 2024-01-15
```

### Options
- `--video`, `-v` - Download videos only
- `--image`, `-i` - Download images only
- `--retweets`, `-r` - Include retweets
- `7`, `30`, etc. - Number of days back
- `YYYY-MM-DD` - Since specific date

### Clean Up Downloads

```bash
x-channel-clear                           # List all accounts
x-channel-clear @username --confirm       # Delete all from account
x-channel-clear @username --older 30 --confirm  # Delete older than 30 days
x-channel-clear @username --video --confirm  # Delete only videos
x-channel-clear @username --dry-run       # Preview without deleting
```

## Storage

- Downloads: `~/x-downloads/@username/`
- Archive: `~/x-downloads/.download-archive.txt`

## Features

- Date filtering (days or specific date)
- Media type filtering (video, image, all)
- Retweets control
- Duplicate prevention
- Safe deletion with --confirm requirement

## Notes

- Only works with PUBLIC accounts
- Uses gallery-dl for downloading
