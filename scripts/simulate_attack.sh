#!/bin/bash
################################################################################
# simulate_attack.sh
# Simulates various attacks on the DECEIVE honeypot.
################################################################################

set +e  # Allow script to continue even if a command fails.

echo "==========================================="
echo "🚀 Simulating Attacks on DECEIVE Honeypot"
echo "==========================================="

# Auto-detect honeypot IP
HONEYPOT_IP=$(hostname -I | awk '{print $1}')
ATTACK_LOG="$HOME/DECEIVE/attack_simulation.log"

# Ensure attack log exists
touch "$ATTACK_LOG"

echo "🎯 Targeting Honeypot IP: $HONEYPOT_IP"
echo "📜 Logging attacks to: $ATTACK_LOG"

# Function to log attack results
log_attack() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$ATTACK_LOG"
}

# Simulate Nmap port scanning
echo "🔍 Running Nmap scan..."
nmap -sS -p 22,80,443,3306 "$HONEYPOT_IP" | tee -a "$ATTACK_LOG"
log_attack "Nmap scan completed."

# ✅ Verify Wordlist Exists Before Running Hydra
WORDLIST=~/SecLists/Passwords/Common-Credentials/10-million-password-list-top-10000.txt
if [ ! -f "$WORDLIST" ]; then
    echo "❌ ERROR: Wordlist not found: $WORDLIST"
    log_attack "Brute force attack skipped: Wordlist missing."
else
    # Simulate Brute Force Attack with Hydra (Optimized for 10 min)
    echo "🔓 Simulating SSH brute force attack with max speed..."
    timeout 600 hydra -l admin -P "$WORDLIST" -t 64 -F -w 1 -V "$HONEYPOT_IP" ssh & wait

    if [ $? -eq 0 ]; then
        log_attack "Brute force attack completed successfully."
    else
        log_attack "Brute force attack attempt failed."
    fi
fi

# Simulate Netcat attack
echo "💀 Simulating malicious connection attempt..."
for i in {1..5}; do
    echo "GET / HTTP/1.1" | nc -w 1 "$HONEYPOT_IP" 80
done
log_attack "Netcat attack simulation completed."

# Take a screenshot (if gnome-screenshot or scrot is installed)
SCREENSHOT_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOT_DIR"
SCREENSHOT_FILE="$SCREENSHOT_DIR/attack_simulation_$(date +%Y-%m-%d_%H-%M-%S).png"

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
echo "🔍 Check attack logs: cat $ATTACK_LOG"
echo "📊 Monitor Splunk logs: ./monitor_splunk.sh"
echo "📑 Run AI log analysis: ./log_analyzer_ai.py ~/DECEIVE/deceive.log 3"

