# oh-mi-cam

Personal experiments with open source firmware on Xiaomi Mi Camera 2K (MJSXJ03HL).

![Thingino firmware login banner](images/ssh-terminal-dark.png)

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

Create `uenv.txt` on FAT32 SD card:

```
wlanssid=YourNetworkName
wlanpass=YourPassword
```

Insert and power on. See [Wi-Fi Access](https://github.com/themactep/thingino-firmware/wiki/Configuration:-Wi%E2%80%90Fi-Access) for details.

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

Get your bot token from [@BotFather](https://t.me/BotFather). For chat ID, send a message to your bot then check `https://api.telegram.org/bot<TOKEN>/getUpdates`.

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
| Motion → video | ✅ (10s clip, 2304x1296) |
| Motion → photo | ❌ Disabled |
| Continuous recording | ❌ Disabled |

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

**Motion Notifications settings** (`/etc/webui/motion.conf`):
- `motion_send2telegram="false"`
- `motion_send2telegram_video="true"`
- `motion_video_duration="10"`

## Custom Scripts

| Script | Purpose |
|--------|---------|
| [`/sbin/send2telegram-video`](scripts/send2telegram-video) | Record and send video to Telegram |
| [`/sbin/clip2telegram`](scripts/clip2telegram) | Wrapper for /clip command |
| [`/sbin/motion`](scripts/motion) | Modified to send video on motion |
| [`/sbin/motion-on`](scripts/motion-on) | Enable motion detection |
| [`/sbin/motion-off`](scripts/motion-off) | Disable motion detection |
| [`/sbin/restart-prudynt`](scripts/restart-prudynt) | Restart streaming service |

## Makefile

Quick commands (run `make help` for full list):

```sh
make status    # Show camera settings
make ssh       # SSH into camera
make snap      # Send photo
make clip      # Send 10s video
make logs      # Show last clip log
make deploy    # Deploy scripts to camera

make motion-on/off   # Toggle motion detection
make photo-on/off    # Toggle photo on motion
make video-on/off    # Toggle video on motion

make sensitivity-1/2/3/4/5   # Set sensitivity (1=lowest)
make cooldown-15/30/60       # Set cooldown in seconds
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
scp -O scripts/motion-on root@oh-mi-cam.local:/sbin/
scp -O scripts/motion-off root@oh-mi-cam.local:/sbin/
scp -O scripts/restart-prudynt root@oh-mi-cam.local:/sbin/
```

### Check Logs

```sh
ssh root@oh-mi-cam.local cat /tmp/clip.log
```
