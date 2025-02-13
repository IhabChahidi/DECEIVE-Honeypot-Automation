#!/bin/bash

set +e  # Allow the script to continue even if a command fails

echo "==========================================="
echo "Starting Full Honeypot Automation (Resumable)"
echo "==========================================="

LOG_DIR="$HOME/logs"
CHECKPOINT_FILE="$LOG_DIR/checkpoint"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/run_all.log"

# Function to log execution status
log_status() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to take screenshots
take_screenshot() {
    SCREENSHOT_DIR="$HOME/screenshots"
    mkdir -p "$SCREENSHOT_DIR"
    SCREENSHOT_FILE="$SCREENSHOT_DIR/$1_$(date +%Y-%m-%d_%H-%M-%S).png"

    if command -v gnome-screenshot &> /dev/null; then
        gnome-screenshot -f "$SCREENSHOT_FILE"
    elif command -v scrot &> /dev/null; then
        scrot "$SCREENSHOT_FILE"
    else
        log_status "Screenshot tool not found! Install 'gnome-screenshot' or 'scrot'."
        return
    fi
    log_status "Screenshot saved: $SCREENSHOT_FILE"
}

# Read the last completed step from the checkpoint file
LAST_STEP=$(cat "$CHECKPOINT_FILE" 2>/dev/null || echo "0")

# Check if Splunk is installed
SPLUNK_INSTALLED=false
if [ -x "/opt/splunk/bin/splunk" ]; then
    SPLUNK_INSTALLED=true
fi

# Check if Splunk is running
SPLUNK_RUNNING=false
if pgrep -x "splunkd" > /dev/null; then
    SPLUNK_RUNNING=true
fi

# Step 1: Install DECEIVE (Skip Splunk if already installed and running)
if [ "$LAST_STEP" -lt 1 ]; then
    if $SPLUNK_INSTALLED && $SPLUNK_RUNNING; then
        log_status "Splunk is already installed and running. Skipping Splunk installation."
    else
        log_status "Step 1: Installing DECEIVE and dependencies (Skipping Splunk if installed)"
        chmod +x install_deceive_splunk.sh
        ./install_deceive_splunk.sh || log_status "Warning: Installation script encountered an error, but continuing..."
    fi
    take_screenshot "01_installation_complete"
    echo "1" > "$CHECKPOINT_FILE"
fi

# Step 2: Start the Honeypot
if [ "$LAST_STEP" -lt 2 ]; then
    log_status "Step 2: Starting DECEIVE Honeypot"
    chmod +x run_deceive.sh
    ./run_deceive.sh || log_status "Warning: Honeypot failed to start, but continuing..."
    take_screenshot "02_honeypot_running"
    echo "2" > "$CHECKPOINT_FILE"
fi

# Step 3: Simulate Attacks
if [ "$LAST_STEP" -lt 3 ]; then
    log_status "Step 3: Simulating Attacks"
    chmod +x simulate_attack.sh
    ./simulate_attack.sh || log_status "Warning: Attack simulation failed, but continuing..."
    take_screenshot "03_attack_simulation"
    echo "3" > "$CHECKPOINT_FILE"
fi

# Step 4: Monitor Splunk Logs
if [ "$LAST_STEP" -lt 4 ]; then
    log_status "Step 4: Monitoring Splunk Logs"
    chmod +x monitor_splunk.sh
    ./monitor_splunk.sh || log_status "Warning: Splunk monitoring failed, but continuing..."
    take_screenshot "04_splunk_monitoring"
    echo "4" > "$CHECKPOINT_FILE"
fi

# Step 5: Configure Splunk Alerts
if [ "$LAST_STEP" -lt 5 ]; then
    log_status "Step 5: Configuring Splunk Alerts"
    chmod +x configure_splunk_alerts.sh
    ./configure_splunk_alerts.sh || log_status "Warning: Splunk alert configuration failed, but continuing..."
    take_screenshot "05_splunk_alerts_configured"
    echo "5" > "$CHECKPOINT_FILE"
fi

# Step 6: Run AI Log Analysis
if [ "$LAST_STEP" -lt 6 ]; then
    log_status "Step 6: Running AI Log Analysis"

    # Ensure required Python dependencies are installed
    source ~/DECEIVE/venv/bin/activate
    pip install --quiet pandas numpy scikit-learn matplotlib

    chmod +x log_analyzer_ai.py
    python3 log_analyzer_ai.py ~/DECEIVE/deceive.log 3 || log_status "Warning: AI Log Analysis failed, but continuing..."
    take_screenshot "06_ai_log_analysis"
    echo "6" > "$CHECKPOINT_FILE"
fi

# Step 7: Generate PDF Report
if [ "$LAST_STEP" -lt 7 ]; then
    log_status "Step 7: Generating Cybersecurity Report"
    chmod +x generate_report.sh
    ./generate_report.sh || log_status "Warning: Report generation failed, but continuing..."
    take_screenshot "07_report_generated"
    echo "7" > "$CHECKPOINT_FILE"
fi

log_status "==========================================="
log_status "Automation Complete! All tasks executed successfully."
log_status "Visit Splunk UI: http://localhost:8000 (admin:changeme)"
log_status "Check attack logs: cat ~/DECEIVE/attack_simulation.log"
log_status "View AI-generated CSV: cat ai_log_analysis.csv"
log_status "Open report: xdg-open ~/reports/attack_report.pdf"
log_status "Screenshots saved in: $HOME/screenshots/"

echo "Full automation completed! Logs saved in $LOG_FILE."

