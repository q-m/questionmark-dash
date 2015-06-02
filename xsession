# X startup script
# Install this as `~/.xinitrc`

HOST=localhost
PORT=3030

# disable screen blanking
xset s noblank
xset s off
xset -dpms

# setup desktop
noclutter &
openbox &

# wait up to 2 minutes for Dashing to get up
nc -z -w 120 "${HOST}" "${PORT}" 1>/dev/null 2>&1

# open webpage in Chromium in kiosk mode
chromium-browser --kiosk --disable-restore-session-state "http://${HOST}:${PORT}/"

