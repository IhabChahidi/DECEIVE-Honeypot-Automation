#!/bin/bash
################################################################################
# configure_splunk_alerts.sh
# Configures Splunk to trigger alerts based on DECEIVE honeypot logs.
################################################################################

set -e  # Exit immediately if a command fails.

echo "==========================================="
echo "🚀 Configuring Splunk Alert for DECEIVE Honeypot"
echo "==========================================="

SPLUNK_CMD="/opt/splunk/bin/splunk"
SPLUNK_USER="admin"
SPLUNK_PASS="changeme"
ALERT_NAME="DECEIVE_Honeypot_Suspicious_Activity"
ALERT_THRESHOLD=10  # Trigger alert if more than 10 logs appear in 5 minutes
ALERT_TIMEFRAME="5m"
ALERT_LOG="$HOME/DECEIVE/splunk_alert_config.log"

# Ensure log file exists
touch "$ALERT_LOG"

# Check if Splunk is running
if ! pgrep -x "splunkd" > /dev/null; then
    echo "❌ Error: Splunk is not running! Starting Splunk..."
    sudo $SPLUNK_CMD start
    sleep 5
fi

echo "🔔 Creating alert '$ALERT_NAME' for DECEIVE logs..."
sudo $SPLUNK_CMD add saved-search "$ALERT_NAME" \
  -search "index=main sourcetype=deceive_logs | stats count by _time, ATTACKER_IP" \
  -description "Triggers when DECEIVE logs exceed $ALERT_THRESHOLD in $ALERT_TIMEFRAME" \
  -alert_type "number of events" \
  -alert_comparator "greater than" \
  -alert_threshold $ALERT_THRESHOLD \
  -alert_condition "per_result" \
  -alert_expires "24h" \
  -alert_actions "email" \
  -dispatch.earliest_time "-$ALERT_TIMEFRAME" \
  -dispatch.latest_time "now" \
  -auth "$SPLUNK_USER:$SPLUNK_PASS" | tee -a "$ALERT_LOG"

echo "✅ Splunk alert '$ALERT_NAME' successfully configured."
echo "🔔 Alert will trigger when more than $ALERT_THRESHOLD attacks occur in $ALERT_TIMEFRAME."

# Take a screenshot (if gnome-screenshot or scrot is installed)
SCREENSHOT_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOT_DIR"
SCREENSHOT_FILE="$SCREENSHOT_DIR/splunk_alerts_$(date +%Y-%m-%d_%H-%M-%S).png"

if command -v gnome-screenshot &> /dev/null; then
    gnome-screenshot -f "$SCREENSHOT_FILE"
elif command -v scrot &> /dev/null; then
    scrot "$SCREENSHOT_FILE"
else
    echo "⚠️ Screenshot tool not found! Install 'gnome-screenshot' or 'scrot'."
fi

echo "📸 Screenshot saved: $SCREENSHOT_FILE"
echo "==========================================="
echo "🎯 Next Steps:"
echo "📜 Check alert log file: cat $ALERT_LOG"
echo "📊 View alerts in Splunk UI: http://localhost:8000"
echo "📑 Test alert by simulating attacks: ./simulate_attack.sh"
