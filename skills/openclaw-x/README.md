# OpenClaw X (Twitter) Tools

Download posts, images, and videos from public X (Twitter) accounts.

## Requirements

- `gallery-dl` - Install with `pipx install gallery-dl`
- `yt-dlp` - For video downloads (optional, gallery-dl handles most)

## Installation

```bash
# Install gallery-dl
pipx install gallery-dl

# Or with pip
pip install gallery-dl
```

## Commands

### x-channel-downloader

Download posts from a public X account.

```bash
# Download all media from last 7 days
x-channel-downloader @username 7

# Download videos only, last 30 days
x-channel-downloader @username 30 --video

# Download images only since specific date
x-channel-downloader @username 2024-01-15 --image

# Include retweets
x-channel-downloader @username 7 --retweets

# From URL
x-channel-downloader https://x.com/username 7
```

**Options:**
| Flag | Description |
|------|-------------|
| `--video`, `-v` | Download videos only |
| `--image`, `-i` | Download images only |
| `--text`, `-t` | Save text posts as JSON |
| `--retweets`, `-r` | Include retweets |
| `7`, `30`, etc. | Number of days back |
| `YYYY-MM-DD` | Since specific date |

### x-channel-clear

Clean up downloaded X content.

```bash
# List all accounts and sizes
x-channel-clear

# Delete all from an account
x-channel-clear @username --confirm

# Delete files older than 30 days
x-channel-clear @username --older 30 --confirm

# Delete only videos
x-channel-clear @username --video --confirm

# Preview without deleting
x-channel-clear @username --dry-run

# Delete everything
x-channel-clear --all --confirm
```

**Options:**
| Flag | Description |
|------|-------------|
| `--older <days>` | Only delete files older than N days |
| `--video`, `-v` | Only delete video files |
| `--image`, `-i` | Only delete image files |
| `--all`, `-A` | Delete all downloads |
| `--confirm`, `-y` | Required to actually delete |
| `--dry-run`, `-n` | Preview without deleting |

## Storage

```
~/x-downloads/
├── @username/
│   ├── 20240201_1234567890_1.jpg
│   ├── 20240201_1234567890_1.jpg.json  # Metadata
│   └── 20240203_9876543210_1.mp4
├── @another_user/
│   └── ...
├── download-history.csv
└── .download-archive.txt
```

## Features

- **Date filtering**: Download only posts from a specific time range
- **Media type filtering**: Videos only, images only, or all
- **Duplicate prevention**: Won't re-download already downloaded posts
- **Metadata saving**: JSON files with tweet text, date, engagement stats
- **Retweets control**: Include or exclude retweets
- **Safe deletion**: Requires `--confirm` flag

## Notes

- Only works with **public** accounts
- Rate limits may apply for large downloads
- Some videos may require yt-dlp fallback
- Twitter/X may block excessive requests
