# Xiaomi Camera Management

SSH = ssh root@oh-mi-cam.local
PRUDYNT = /etc/prudynt.cfg
MOTION_CONF = /etc/webui/motion.conf

.PHONY: help status ssh restart snap clip logs deploy \
        motion-on motion-off photo-on photo-off video-on video-off \
        sensitivity-1 sensitivity-2 sensitivity-3 sensitivity-4 sensitivity-5 \
        cooldown-15 cooldown-30 cooldown-60

## help    : Print commands help.
help : Makefile
	@sed -n 's/^## *//p' $< | tr -s '\t' ' ' | column -t -s ':'

## status  : Show camera settings.
status:
	@$(SSH) "echo '=== Motion ==='; \
		grep -A10 '^motion :' /etc/prudynt.cfg | grep -E 'enabled =|sensitivity|cooldown_time'; \
		echo ''; echo '=== Memory ==='; \
		free -m | head -2"

## ssh     : SSH into camera.
ssh:
	$(SSH)

## restart : Restart streaming.
restart:
	$(SSH) "/etc/init.d/S95prudynt restart"

## snap    : Send photo.
snap:
	$(SSH) "send2telegram -i"

## clip    : Send 10s video.
clip:
	$(SSH) "send2telegram-video -t 10"

## motion-on  : Enable motion detection.
motion-on:
	$(SSH) "sed -i 's/enabled = false;/enabled = true;/' $(PRUDYNT); \
		/etc/init.d/S95prudynt restart"

## motion-off : Disable motion detection.
motion-off:
	$(SSH) "sed -i 's/enabled = true;/enabled = false;/' $(PRUDYNT); \
		/etc/init.d/S95prudynt restart"

## photo-on   : Enable photo on motion.
photo-on:
	$(SSH) "sed -i 's/motion_send2telegram=\"false\"/motion_send2telegram=\"true\"/' $(MOTION_CONF)"

## photo-off  : Disable photo on motion.
photo-off:
	$(SSH) "sed -i 's/motion_send2telegram=\"true\"/motion_send2telegram=\"false\"/' $(MOTION_CONF)"

## video-on   : Enable video on motion.
video-on:
	$(SSH) "sed -i 's/motion_send2telegram_video=\"false\"/motion_send2telegram_video=\"true\"/' $(MOTION_CONF)"

## video-off  : Disable video on motion.
video-off:
	$(SSH) "sed -i 's/motion_send2telegram_video=\"true\"/motion_send2telegram_video=\"false\"/' $(MOTION_CONF)"

## sensitivity-1 : Set sensitivity to 1 (lowest).
sensitivity-1:
	$(SSH) "sed -i 's/sensitivity = [0-9];/sensitivity = 1;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## sensitivity-2 : Set sensitivity to 2.
sensitivity-2:
	$(SSH) "sed -i 's/sensitivity = [0-9];/sensitivity = 2;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## sensitivity-3 : Set sensitivity to 3.
sensitivity-3:
	$(SSH) "sed -i 's/sensitivity = [0-9];/sensitivity = 3;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## sensitivity-4 : Set sensitivity to 4.
sensitivity-4:
	$(SSH) "sed -i 's/sensitivity = [0-9];/sensitivity = 4;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## sensitivity-5 : Set sensitivity to 5 (highest).
sensitivity-5:
	$(SSH) "sed -i 's/sensitivity = [0-9];/sensitivity = 5;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## cooldown-15 : Set cooldown to 15s.
cooldown-15:
	$(SSH) "sed -i 's/cooldown_time = [0-9]*;/cooldown_time = 15;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## cooldown-30 : Set cooldown to 30s.
cooldown-30:
	$(SSH) "sed -i 's/cooldown_time = [0-9]*;/cooldown_time = 30;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## cooldown-60 : Set cooldown to 60s.
cooldown-60:
	$(SSH) "sed -i 's/cooldown_time = [0-9]*;/cooldown_time = 60;/' $(PRUDYNT); /etc/init.d/S95prudynt restart"

## logs    : Show last clip log.
logs:
	$(SSH) "cat /tmp/clip.log"

## deploy  : Deploy scripts to camera.
deploy:
	scp -O scripts/motion root@oh-mi-cam.local:/sbin/
	scp -O scripts/clip2telegram root@oh-mi-cam.local:/sbin/
	scp -O scripts/send2telegram-video root@oh-mi-cam.local:/sbin/
