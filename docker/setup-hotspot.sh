#!/usr/bin/env bash
# Configure the Raspberry Pi's onboard WiFi as an access point so a laptop can connect directly to the vehicle in the field with no router.
# Temporary until better comms figured out
# Usage:  sudo ./setup-hotspot.sh [SSID] [PASSWORD]

set -euo pipefail

SSID="${1:-corvus}"
PASS="${2:-trickfire}"
IFACE="${IFACE:-wlan0}"

if [[ ${#PASS} -lt 8 ]]; then
    echo "Password must be at least 8 characters." >&2
    exit 1
fi

nmcli connection delete corvus-ap 2>/dev/null || true

nmcli connection add type wifi ifname "$IFACE" con-name corvus-ap ssid "$SSID"
nmcli connection modify corvus-ap \
    802-11-wireless.mode ap \
    802-11-wireless.band bg \
    ipv4.method shared \
    wifi-sec.key-mgmt wpa-psk \
    wifi-sec.psk "$PASS" \
    connection.autoconnect yes \
    connection.autoconnect-priority 100

nmcli connection up corvus-ap

cat <<EOF

Hotspot '$SSID' is up and will auto-start on boot.
The Pi is 10.42.0.1; clients get 10.42.0.x.

To get internet on the Pi temporarily:
  sudo nmcli connection down corvus-ap
  sudo nmcli device wifi connect <home-ssid> password <pw>
  sudo nmcli connection up corvus-ap
EOF
