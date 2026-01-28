# oh-mi-cam

Personal experiments with open source firmware on Xiaomi Mi Camera 2K (MJSXJ03HL).

![Thingino firmware login banner](images/ssh-terminal.png)

## Hardware

- **Model:** Xiaomi Mi Camera 2K Magnetic Mount (MJSXJ03HL)
- **SoC:** Ingenic T31N
- **Memory:** 32MB RAM, 16MB Flash
- **Sensor:** jxq03p (2304x1296, 3MP)

## Firmware

Running [Thingino](https://github.com/themactep/thingino-firmware) open source firmware. See [flashing guide](https://github.com/Andrik45719/MJSXJ03HL) for this model.

## Access

| Method | Address |
|--------|---------|
| SSH | `ssh -i ~/.ssh/xiaomi root@oh-mi-cam.local` |
| Web UI | http://oh-mi-cam.local/ |
| RTSP | `rtsp://thingino:thingino@oh-mi-cam.local/ch0` |

See [SSH Access Keys](https://github.com/themactep/thingino-firmware/wiki/SSH-Access-Keys) setup.

> If the `.local` hostname doesn't resolve, use the camera's IP address instead.

## Telegram Bot

| Command | Description |
|---------|-------------|
| `/snap` | Take and send a photo |
| `/clip` | Record and send 10s video |
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
| Motion → video | ✅ (10s clip, 640x360) |
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
