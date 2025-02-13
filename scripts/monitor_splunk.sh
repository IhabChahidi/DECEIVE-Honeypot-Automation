#!/bin/bash


set -e  # Exit immediately if a command fails.

echo "==========================================="
echo "Checking Splunk Logs for DECEIVE Honeypot"
echo "==========================================="

SPLUNK_CMD="/opt/splunk/bin/splunk"
SEARCH_QUERY='search index=main sourcetype=deceive_logs | head 10'
MONITOR_LOG="$HOME/DECEIVE/splunk_monitor.log"

# Ensure log file exists
touch "$MONITOR_LOG"

# Check if Splunk is running
if ! pgrep -x "splunkd" > /dev/null; then
    echo "Error: Splunk is not running! Starting Splunk..."
    sudo $SPLUNK_CMD start
    sleep 5
fi

echo "Running Splunk query to check logs..."
sudo $SPLUNK_CMD search "$SEARCH_QUERY" -auth admin:changeme | tee -a "$MONITOR_LOG"

if grep -q "deceive_logs" "$MONITOR_LOG"; then
    echo "DECEIVE logs are being ingested into Splunk."
else
    echo "Warning: No DECEIVE logs found in Splunk. Ensure the honeypot is running."
fi

# Take a screenshot (if gnome-screenshot or scrot is installed)
SCREENSHOT_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOT_DIR"
SCREENSHOT_FILE="$SCREENSHOT_DIR/splunk_monitor_$(date +%Y-%m-%d_%H-%M-%S).png"

if command -v gnome-screenshot &> /dev/null; then
    gnome-screenshot -f "$SCREENSHOT_FILE"
elif command -v scrot &> /dev/null; then
    scrot "$SCREENSHOT_FILE"
else
    echo "Screenshot tool not found! Install 'gnome-screenshot' or 'scrot'."
fi

echo "Screenshot saved: $SCREENSHOT_FILE"
echo "==========================================="
echo "Next Steps:"
echo "Check Splunk log file: cat $MONITOR_LOG"
echo "📊 View logs in Splunk UI: http://localhost:8000"
echo "📑 Run AI log analysis: python3 log_analyzer_ai.py ~/DECEIVE/deceive.log 3"
