#!/bin/bash
################################################################################
# generate_report.sh
# Generates a professional PDF report summarizing AI log analysis and attack data.
################################################################################

set -e  # Exit immediately if a command fails.

echo "==========================================="
echo "Generating Cybersecurity Report"
echo "==========================================="

# Define directories and file paths
REPORT_DIR="$HOME/reports"
LOG_DIR="$HOME/logs"
SCREENSHOT_DIR="$HOME/screenshots"

REPORT_TEX="$REPORT_DIR/attack_report.tex"
REPORT_PDF="$REPORT_DIR/attack_report.pdf"
LOG_ANALYSIS="$LOG_DIR/ai_log_analysis.csv"
ATTACK_LOG="$HOME/logs/ssh_log.log"
PLOT_IMAGE="$REPORT_DIR/ai_analysis_plot.png"

# Ensure required directories exist
mkdir -p "$REPORT_DIR"
mkdir -p "$SCREENSHOT_DIR"

# Check if required log files exist
if [ ! -f "$LOG_ANALYSIS" ]; then
    echo "⚠️ Running AI Log Analysis..."
    python3 ~/scripts/log_analyzer_ai.py "$ATTACK_LOG" > "$LOG_ANALYSIS"
fi


if [ ! -f "$ATTACK_LOG" ]; then
    echo "❌ Error: Attack log file not found! Run 'simulate_attack.sh' first."
    exit 1
fi

if [ ! -f "$PLOT_IMAGE" ]; then
    echo "⚠️ Warning: No AI visualization found! The report will proceed without it."
fi

# Check if LaTeX is installed
if ! command -v pdflatex &> /dev/null; then
    echo "❌ Error: LaTeX is not installed! Install it using:"
    echo "sudo apt install texlive-latex-base -y"
    exit 1
fi

# Generate LaTeX document
cat << EOF > "$REPORT_TEX"
\documentclass{article}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{booktabs}

\title{Cybersecurity Honeypot Report}
\author{Automated System}
\date{\today}

\begin{document}
\maketitle

\section{Introduction}
This report provides an analysis of attacks detected by the DECEIVE honeypot, including AI-based attack classification and Splunk alerting.

\section{Attack Log Summary}
The following logs were recorded during the honeypot deployment:

\begin{verbatim}
$(tail -n 20 "$ATTACK_LOG")
\end{verbatim}

\section{AI Log Analysis}
Automated AI analysis identified the following attack patterns:

\begin{verbatim}
$(head -n 10 "$LOG_ANALYSIS")
\end{verbatim}

\section{Visualizations}
If available, the following graph represents attacker activity patterns:

\begin{center}
\includegraphics[width=0.8\textwidth]{$PLOT_IMAGE}
\end{center}

\section{Conclusion}
This honeypot deployment successfully captured and analyzed attack attempts using AI and Splunk. Continuous monitoring is recommended.

\end{document}
EOF

# Compile LaTeX document
cd "$REPORT_DIR"
pdflatex attack_report.tex > /dev/null 2>&1 || { echo "❌ Error: LaTeX compilation failed!"; exit 1; }
cd -

# Verify report generation
if [ -f "$REPORT_PDF" ]; then
    echo "✅ Report successfully generated: $REPORT_PDF"
else
    echo "❌ Error: Report generation failed!"
    exit 1
fi

# Take a screenshot (if gnome-screenshot or scrot is installed)
SCREENSHOT_FILE="$SCREENSHOT_DIR/report_generated_$(date +%Y-%m-%d_%H-%M-%S).png"

if command -v gnome-screenshot &> /dev/null; then
    gnome-screenshot -f "$SCREENSHOT_FILE"
elif command -v scrot &> /dev/null; then
    scrot "$SCREENSHOT_FILE"
else
    echo "⚠️ Screenshot tool not found! Install 'gnome-screenshot' or 'scrot'."
fi

echo "📸 Screenshot saved: $SCREENSHOT_FILE"
echo "==========================================="
echo "Next Steps:"
echo "📄 View the report: xdg-open $REPORT_PDF"
echo "📊 Review AI-generated CSV: cat $LOG_ANALYSIS"
echo "📸 View screenshots in: $SCREENSHOT_DIR"

