#!/bin/bash
################################################################################
# run_deceive.sh
# Starts the DECEIVE honeypot and verifies log activity.
################################################################################

set -e  # Exit immediately if a command fails.

echo "==========================================="
echo "🚀 Starting DECEIVE Honeypot"
echo "==========================================="

DECEIVE_DIR="$HOME/DECEIVE"
LOG_FILE="$DECEIVE_DIR/deceive.log"

# Check if DECEIVE is installed
if [ ! -d "$DECEIVE_DIR" ]; then
    echo "❌ Error: DECEIVE is not installed! Run './install_deceive_splunk.sh' first."
    exit 1
fi

# Activate Python virtual environment
source "$DECEIVE_DIR/venv/bin/activate"

# Ensure log file exists
touch "$LOG_FILE"

# Start DECEIVE honeypot in the background
echo "🐍 Running DECEIVE honeypot..."
nohup python3 "$DECEIVE_DIR/deceive.py" --config config.yaml > "$LOG_FILE" 2>&1 &

# Give it time to start and generate logs
sleep 5

# Verify that logs are being generated
if [[ -s "$LOG_FILE" ]]; then
    echo "✅ DECEIVE is running successfully!"
    tail -n 10 "$LOG_FILE"
else
    echo "⚠️ Warning: No logs detected. Check '$LOG_FILE' for errors."
fi

# Take a screenshot (if gnome-screenshot or scrot is installed)
SCREENSHOT_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOT_DIR"
SCREENSHOT_FILE="$SCREENSHOT_DIR/deceive_running_$(date +%Y-%m-%d_%H-%M-%S).png"

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
echo "🚀 Simulate attacks: ./simulate_attack.sh"
echo "🔍 Check logs: tail -n 20 $LOG_FILE"
echo "📊 Monitor Splunk logs: ./monitor_splunk.sh"
