# DECEIVE - AI-Powered Honeypot Automation

<img align="right" src="assets/deceive_banner.png" alt="A cybercriminal interacts with a ghostly, AI-driven honeypot system" width="350">

**DECEIVE** (**DECeption with Evaluative Integrated Validation Engine**) is an AI-driven honeypot designed to simulate real-world system interactions and capture attacker behaviors. Unlike traditional honeypots, DECEIVE automatically generates realistic environments, logs intrusions, and integrates with **Splunk** and AI-driven forensic analysis for cybersecurity intelligence.

## Why DECEIVE?
- **AI-powered deception** to create lifelike system responses  
- **Automated attack simulations** for penetration testing and SOC training  
- **Real-time logging and Splunk integration** for security analysis  
- **Generates professional reports** on honeypot activity  
- **Easy to deploy** with a fully automated installation process  

## Target Users
- **SOC Analysts**
- **Cybersecurity Researchers**
- **Penetration Testers**
- **Ethical Hackers**

**Warning:** This honeypot is for research purposes only. Do not deploy it in production environments without proper security controls.

---

## Repository Structure
```
DECEIVE/
 ├── SSH/                     # SSH honeypot engine
 │   ├── ssh_server.py        # Main SSH honeypot script
 │   ├── config.ini           # Configuration file
 │   ├── prompt.txt           # AI-generated system emulation
 │   ├── ssh_log.log          # SSH attack logs
 │   └── ssh_host_key         # SSH private key for authentication
 │
 ├── scripts/                 # Attack simulation scripts
 │   ├── simulate_attack.sh   # Runs brute force and network attacks
 │   ├── monitor_splunk.sh    # Monitors Splunk logs
 │   ├── install_deceive.sh   # Full honeypot setup script
 │   └── configure_splunk.sh  # Configures Splunk alerts
 │
 ├── reports/                 # Automated cybersecurity reports
 │   ├── attack_report.pdf    # AI-generated cybersecurity report
 │   ├── ai_log_analysis.csv  # AI-detected threats
 │   └── screenshots/         # Honeypot activity snapshots
 │
 ├── logs/                    # Honeypot activity logs
 │   ├── ssh_log.log          # SSH attack logs
 │   ├── attack_simulation.log # Attack simulation logs
 │   └── splunk_monitor.log   # Splunk monitoring logs
 │
 ├── assets/                  # Visual assets
 │   ├── deceive_banner.png   # Project banner
 │   └── README.md            # Documentation images
 │
 ├── run_all.sh               # Master automation script
 ├── log_analyzer_ai.py        # AI-driven threat analysis
 ├── README.md                 # Project documentation
 └── LICENSE                   # Open-source MIT License
```
---

## System Requirements
### Supported Platforms
| OS             | Status  | Notes |
|---------------|--------|-------|
| Ubuntu 22.04+ | Tested | Recommended |
| Debian 11+    | Tested | Requires `apt-get` installation |
| macOS 13+     | Partial | Needs OpenSSH customization |
| Windows (WSL) | Tested | Use WSL2 for best performance |

### Prerequisites
- Python **3.8+**
- **Virtual Environment (venv)**
- **Git, OpenSSH, and Splunk** installed

---

## Installation Guide
### Step 1: Clone the Repository
```bash
git clone https://github.com/IhabChahidi/DECEIVE-Honeypot-Automation.git
cd DECEIVE-Honeypot-Automation
```

### Step 2: Install Dependencies
```bash
pip3 install -r requirements.txt
```

### Step 3: Generate SSH Host Key
```bash
ssh-keygen -t rsa -b 4096 -f SSH/ssh_host_key
```

### Step 4: Configure the Honeypot
```bash
nano SSH/config.ini   # Adjust AI settings, logging, and user accounts
nano SSH/prompt.txt   # Define the simulated system profile
```

### Step 5: Run the Honeypot
```bash
python3 SSH/ssh_server.py
```

---

## Simulating Attacks
Want to test how attackers interact with **DECEIVE**? Run these attack simulations:

### Nmap Port Scan
```bash
nmap -sS -p 22,80,443 "$HONEYPOT_IP"
```

### Brute Force SSH Attack (Hydra)
```bash
hydra -l admin -P wordlists/10k-most-common.txt "$HONEYPOT_IP" ssh -t 4
```

### Automated Cyberattack Simulation
```bash
./scripts/simulate_attack.sh
```

### Monitor Splunk Logs
```bash
./scripts/monitor_splunk.sh
```

---

## Log Analysis & AI Reports
DECEIVE captures all interactions and logs them for analysis. Use the AI engine to analyze threats.

### Run AI Log Analyzer
```bash
python3 log_analyzer_ai.py logs/ssh_log.log 3
```

### View Attack Reports
```bash
cat reports/attack_report.pdf
```

---

## Example Log Output
```
[2025-01-10 20:37:55] SSH brute force attack detected from 192.168.1.100
User: admin | Password: 123456 | Risk: HIGH
```
```json
{
  "timestamp": "2025-01-10T20:37:55.018+00:00",
  "src_ip": "192.168.1.100",
  "username": "admin",
  "password": "123456",
  "judgement": "MALICIOUS"
}
```

---

## Future Improvements
- **Enhance AI deception** with LLM-powered interactions  
- **Automate Splunk alerting** for real-time threat detection  
- **Integrate Elastic Stack** for enterprise monitoring  

---

## Contributing
Want to improve **DECEIVE**? Pull requests are welcome!
1. **Fork the repo**
2. **Create a new branch** (`feature/your-feature`)
3. **Submit a PR**

---

## License
This project is licensed under the **MIT License**.

---

## Author
**Ihab Chahidi**  
[GitHub](https://github.com/IhabChahidi) | [LinkedIn](https://linkedin.com/in/IhabChahidi)


## Project Screenshots
The following images showcase key steps in deploying and running DECEIVE:
- Installation Complete: ![Installation Complete](assets/screenshots/01_installation_complete_2025-02-12_12-35-51.png)
- Honeypot Running: ![Honeypot Running](assets/screenshots/02_honeypot_running_2025-02-12_12-35-57.png)
- Attack Simulation: ![Attack Simulation](assets/screenshots/03_attack_simulation_2025-02-12_20-01-58.png)
- Splunk Monitoring: ![Splunk Monitoring](assets/screenshots/04_splunk_monitoring_2025-02-12_20-15-54.png)
- Splunk Alerts Configured: ![Splunk Alerts Configured](assets/screenshots/05_splunk_alerts_configured_2025-02-12_20-15-56.png)
- AI Log Analysis: ![AI Log Analysis](assets/screenshots/06_ai_log_analysis_2025-02-12_20-15-59.png)
- Report Generated: ![Report Generated](assets/screenshots/07_report_generated_2025-02-12_20-16-00.png)
- Splunk Monitor Error: ![Splunk Monitor Error](assets/screenshots/splunk_monitor_2025-02-12_20-15-53.png)


