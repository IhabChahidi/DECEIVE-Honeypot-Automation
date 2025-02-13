#!/bin/bash


set -e  # Exit immediately if a command fails.

echo "==========================================="
echo "Installing DECEIVE Honeypot, Splunk, and Dependencies"
echo "==========================================="

# Function to check and install missing packages
install_package() {
    if ! dpkg -l | grep -qw "$1"; then
        echo "Installing $1..."
        sudo apt-get install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Update package list
sudo apt-get update && sudo apt-get upgrade -y

# Install required packages
install_package git
install_package python3
install_package python3-pip
install_package virtualenv
install_package wget
install_package nmap
install_package netcat
install_package gnome-screenshot
install_package scrot

# Clone DECEIVE repository if not already present
if [ ! -d "$HOME/DECEIVE" ]; then
    echo "Cloning DECEIVE repository..."
    git clone https://github.com/splunk/DECEIVE.git "$HOME/DECEIVE"
else
    echo "DECEIVE repository already exists."
fi

# Create and activate Python virtual environment
cd "$HOME/DECEIVE"
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi
source venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt || echo "⚠️ No requirements.txt found, skipping."
pip install scikit-learn matplotlib pandas requests

# Install Splunk
if [ ! -d "/opt/splunk" ]; then
    echo "Downloading and Installing Splunk..."
    sudo wget https://download.splunk.com/products/splunk/releases/7.1.1/linux/splunk-7.1.1-8f0ead9ec3db-linux-2.6-amd64.deb
    sudo dpkg -i splunk.deb
    sudo rm splunk.deb
else
    echo "Splunk is already installed."
fi

# Enable and start Splunk
echo "Configuring Splunk..."
sudo /opt/splunk/bin/splunk enable boot-start --accept-license --answer-yes
sudo /opt/splunk/bin/splunk start

# Configure Splunk to monitor DECEIVE logs
SPLUNK_INPUTS="/opt/splunk/etc/apps/deceive_inputs/local/inputs.conf"
if [ ! -f "$SPLUNK_INPUTS" ]; then
    echo "🔧 Configuring Splunk log monitoring..."
    sudo mkdir -p "$(dirname "$SPLUNK_INPUTS")"
    cat << EOF | sudo tee "$SPLUNK_INPUTS"
[monitor:///home/$(whoami)/DECEIVE/deceive.log]
disabled = false
index = main
sourcetype = deceive_logs
EOF
    sudo /opt/splunk/bin/splunk restart
else
    echo "Splunk logging configuration already exists."
fi

echo "==========================================="
echo "Installation Complete!"
echo "==========================================="
echo "Run './run_deceive.sh' to start the honeypot."
echo "Open Splunk UI: http://localhost:8000 (admin:changeme)"
