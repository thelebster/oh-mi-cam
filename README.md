# oh-mi-cam

Personal experiments with open source firmware on Xiaomi Mi Camera 2K (MJSXJ03HL).

![Thingino firmware login banner](assets/images/ssh-terminal-dark.png)

## Hardware

- **Model:** Xiaomi Mi Camera 2K Magnetic Mount (MJSXJ03HL)
- **SoC:** Ingenic T31N
- **Memory:** 32MB RAM, 16MB Flash
- **Sensor:** jxq03p (2304x1296, 3MP)

## Firmware

Running [Thingino](https://github.com/themactep/thingino-firmware) open source firmware. See [camera details](https://github.com/themactep/thingino-firmware/wiki/Camera:-Xiaomi-MJSXJ03HL) and [flashing guide](https://github.com/Andrik45719/MJSXJ03HL).

## Access

| Method | Address |
|--------|---------|
| SSH | `ssh -i ~/.ssh/xiaomi root@oh-mi-cam.local` |
| Web UI | http://oh-mi-cam.local/ |
| RTSP | `rtsp://thingino:thingino@oh-mi-cam.local/ch0` |

See [SSH Access Keys](https://github.com/themactep/thingino-firmware/wiki/SSH-Access-Keys) setup.

> If the `.local` hostname doesn't resolve, use the camera's IP address instead.

## WiFi Setup

**Via SSH** (if you have access):

```sh
# Get current values
fw_printenv wlanssid
fw_printenv wlanpass

# Set new values
fw_setenv wlanssid YourNetworkName
fw_setenv wlanpass YourPassword
reboot
```

**Via SD card** (no network access needed):

Copy `scripts/sdcard/run.sh` and `scripts/sdcard/uenv.txt` to SD card root (FAT32/exFAT).

Edit `uenv.txt` with your settings:

```
wlanssid=YourNetworkName
wlanpass=YourPassword
```

Or enable/disable AP mode:

```
wlanap_enabled=true
```

Insert and power on. The `run.sh` script loads env vars on every boot via the camera's automount feature.

See [Wi-Fi Access](https://github.com/themactep/thingino-firmware/wiki/Configuration:-Wi%E2%80%90Fi-Access) for details.

## Telegram Bot

| Command | Description |
|---------|-------------|
| `/snap` | Take and send a photo |
| `/clip` | Record and send 10s video |
| `/motion_on` | Enable motion detection |
| `/motion_off` | Disable motion detection |
| `/restart` | Restart streaming service |
| `/info` | System information |
| `/diag` | Diagnostic info |

### Enable Telegram

Get your bot token from [@BotFather](https://t.me/BotFather). For chat ID, send a message to your bot then run `make tg-get-chat-id` (or check `https://api.telegram.org/bot<TOKEN>/getUpdates`).

**Web UI:**

1. Services → Send to Telegram — set **Bot Token** and **Chat ID**, click Save
2. Services → Telegram Bot — enable it, click Save

**SSH:**

Edit `/etc/webui/telegram.conf`:

```sh
telegram_enabled="true"
telegram_token="YOUR_BOT_TOKEN"
telegram_channel="YOUR_CHAT_ID"
```

Edit `/etc/webui/telegrambot.conf`:

```sh
telegrambot_enabled="true"
telegrambot_token="YOUR_BOT_TOKEN"
```

Restart the bot:

```sh
/etc/init.d/S93telegrambot restart
```

## Features

| Feature | Status |
|---------|--------|
| RTSP streaming | ✅ |
| Telegram commands | ✅ |
| Motion → text | ✅ (instant alert) |
| Motion → video | ✅ (10s clip, 2304x1296) |
| Motion → photo | ❌ Disabled |
| Continuous recording | ❌ Disabled |
| SD card boot scripts | ✅ (WiFi/AP config via uenv.txt) |

## What It Looks Like

**Web UI** — camera preview at `http://oh-mi-cam.local`

![Web UI camera preview](assets/images/webui-preview.png)

**Telegram** — motion alert with video clip

![Telegram motion notification](assets/images/telegram-motion.png)

![Sample motion clip](assets/images/motion-clip.gif)

## Configuration Files

| File | Purpose |
|------|---------|
| `/etc/prudynt.cfg` | Main config (motion detection, streaming) |
| `/etc/webui/telegram.conf` | Telegram send settings |
| `/etc/webui/telegrambot.conf` | Bot commands |
| `/etc/webui/motion.conf` | Motion notification options |
| `/etc/webui/record.conf` | Recording settings (disabled) |

**Motion Guard settings** (`/etc/prudynt.cfg`):
- `enabled = true`
- `sensitivity = 5`
- `cooldown_time = 30`

**Stream settings** (`/etc/prudynt.cfg`):
- `bitrate = 1500` (optimized for smaller files)
- `gop = 50` (fewer keyframes)

**Motion Notifications settings** (`/etc/webui/motion.conf`):
- `motion_send2telegram="false"`
- `motion_send2telegram_video="true"`
- `motion_send2telegram_text="true"`
- `motion_video_duration="10"`

## Custom Scripts

| Script | Purpose |
|--------|---------|
| [`/sbin/send2telegram-video`](scripts/send2telegram-video) | Record and send video to Telegram |
| [`/sbin/send2telegram-text`](scripts/send2telegram-text) | Send text-only notification to Telegram |
| [`/sbin/clip2telegram`](scripts/clip2telegram) | Wrapper for /clip command |
| [`/sbin/motion`](scripts/motion) | Modified to send video on motion |
| [`/sbin/motion-on`](scripts/motion-on) | Enable motion detection |
| [`/sbin/motion-off`](scripts/motion-off) | Disable motion detection |
| [`/sbin/restart-prudynt`](scripts/restart-prudynt) | Restart streaming service |
| [`scripts/sdcard/run.sh`](scripts/sdcard/run.sh) | Load env vars from SD card on boot |
| [`scripts/sdcard/uenv.txt`](scripts/sdcard/uenv.txt) | Template for WiFi/AP settings |

## Makefile

Quick commands (run `make help` for full list):

```sh
make status    # Show camera settings
make ssh       # SSH into camera
make snap      # Send photo
make clip      # Send 10s video
make logs      # Show last clip log

make deploy          # Deploy scripts to camera
make config-deploy   # Deploy config files (substitutes env vars)
make config-backup   # Backup config files from camera
make config-dry-run  # Preview config substitution

make motion-on/off   # Toggle motion detection
make photo-on/off    # Toggle photo on motion
make video-on/off    # Toggle video on motion
make text-on/off     # Toggle text alert on motion

make sensitivity-1/2/3/4/5   # Set sensitivity (1=lowest)
make cooldown-15/30/60       # Set cooldown in seconds

make tg-get-chat-id  # Get Telegram chat ID (send message to bot first)
```

## SSH Commands

```sh
# Connect
ssh -i ~/.ssh/xiaomi root@oh-mi-cam.local

# Restart streaming
/etc/init.d/S95prudynt restart

# Send photo/video
send2telegram -i
send2telegram-video -t 10

# Check motion sensitivity
grep sensitivity /etc/prudynt.cfg | sed 's/[^0-9]//g'

# Change motion sensitivity (1-5)
sed -i 's/sensitivity = 1;/sensitivity = 5;/' /etc/prudynt.cfg
/etc/init.d/S95prudynt restart

# Check memory/logs
free -m
logread | tail -30
```

## Known Issues

- Web UI preview may not load - power cycle or restart prudynt via SSH
- Motion Guard toggle in Web UI doesn't save - edit `/etc/prudynt.cfg` via SSH
- Limited RAM (32MB) - keep continuous recording disabled

## Tips

### SSH Config

Simplify SSH by adding to `~/.ssh/config`:

```
Host oh-mi-cam.local
    IdentityFile ~/.ssh/xiaomi
```

Then just: `ssh root@oh-mi-cam.local`

### Deploy Scripts

Use `-O` flag (camera lacks SFTP server):

```sh
# Backup original first
ssh root@oh-mi-cam.local cp /sbin/motion /sbin/motion.orig

# Deploy scripts to camera
scp -O scripts/motion root@oh-mi-cam.local:/sbin/
scp -O scripts/clip2telegram root@oh-mi-cam.local:/sbin/
scp -O scripts/send2telegram-video root@oh-mi-cam.local:/sbin/
scp -O scripts/send2telegram-text root@oh-mi-cam.local:/sbin/
scp -O scripts/motion-on root@oh-mi-cam.local:/sbin/
scp -O scripts/motion-off root@oh-mi-cam.local:/sbin/
scp -O scripts/restart-prudynt root@oh-mi-cam.local:/sbin/
```

### Deploy Config

Config files use `${VAR}` placeholders for sensitive values. Create `.env` from the example:

```sh
cp .env.example .env
# Edit .env with your Telegram credentials
```

Then deploy with automatic substitution:

```sh
make config-deploy   # Deploy with env var substitution
make config-dry-run  # Preview substitution without deploying
make config-backup   # Backup current configs from camera
```

**Manual deploy** (without substitution):

```sh
scp -O config/telegram.conf root@oh-mi-cam.local:/etc/webui/
scp -O config/telegrambot.conf root@oh-mi-cam.local:/etc/webui/
ssh root@oh-mi-cam.local /etc/init.d/S93telegrambot restart
```

### Check Logs

```sh
ssh root@oh-mi-cam.local cat /tmp/clip.log
```
