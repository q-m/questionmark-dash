# X startup script
# Install this as `~/.xsession`

HOST=localhost
PORT=3030

# disable screen blanking
xset s noblank
xset s off
xset -dpms

# setup desktop
noclutter &
openbox &

# wait for Dashing to get up
while ! nc -z -w 30 "${HOST}" "${PORT}" 1>/dev/null 2>&1; do
  sleep 1
done

# open webpage in Chromium in kiosk mode
chromium-browser --kiosk --disable-restore-session-state "http://${HOST}:${PORT}/"

