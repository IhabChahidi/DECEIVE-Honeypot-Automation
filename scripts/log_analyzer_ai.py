#!/usr/bin/env python3


import re
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from collections import Counter
import os

# Ensure correct usage
if len(sys.argv) != 3:
    print("Usage: python3 log_analyzer_ai.py <log_file_path> <num_clusters>")
    sys.exit(1)

log_file = sys.argv[1]
num_clusters = int(sys.argv[2])

# Read log file
try:
    with open(log_file, 'r') as f:
        logs = f.readlines()
except FileNotFoundError:
    print(f"Error: Log file '{log_file}' not found!")
    sys.exit(1)

# Extract timestamp, attacker IP, and attack details
log_entries = []
pattern = re.compile(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*?ATTACKER_IP:\s*(\d+\.\d+\.\d+\.\d+)')

for line in logs:
    match = pattern.search(line)
    if match:
        timestamp, ip = match.groups()
        log_entries.append([timestamp, ip, line.strip()])

# Convert to DataFrame
df = pd.DataFrame(log_entries, columns=["Timestamp", "Attacker_IP", "Log_Entry"])

if df.empty:
    print("Warning: No valid attack logs found!")
    sys.exit(1)

# AI-based clustering using TF-IDF + K-Means
vectorizer = TfidfVectorizer(stop_words='english')
X = vectorizer.fit_transform(df["Log_Entry"])

kmeans = KMeans(n_clusters=num_clusters, random_state=42, n_init=10)
df["Cluster"] = kmeans.fit_predict(X)

# Identify most frequent attacker IPs
attacker_counts = Counter(df["Attacker_IP"])
top_attackers = attacker_counts.most_common(5)

# Save analyzed data to CSV
csv_output = "ai_log_analysis.csv"
df.to_csv(csv_output, index=False)
print(f"AI log analysis completed. Results saved to '{csv_output}'")

# Plot results
plt.figure(figsize=(10, 5))
plt.bar([ip for ip, _ in top_attackers], [count for _, count in top_attackers])
plt.xlabel("Attacker IPs")
plt.ylabel("Number of Attacks")
plt.title("Top 5 Attacker IPs")
plt.xticks(rotation=45)
plt.savefig("ai_analysis_plot.png")
plt.show()

# Take a screenshot (if gnome-screenshot or scrot is installed)
screenshot_dir = os.path.expanduser("~/screenshots")
os.makedirs(screenshot_dir, exist_ok=True)
screenshot_file = os.path.join(screenshot_dir, f"ai_analysis_{pd.Timestamp.now().strftime('%Y-%m-%d_%H-%M-%S')}.png")

if os.system("command -v gnome-screenshot") == 0:
    os.system(f"gnome-screenshot -f {screenshot_file}")
elif os.system("command -v scrot") == 0:
    os.system(f"scrot {screenshot_file}")
else:
    print("Screenshot tool not found! Install 'gnome-screenshot' or 'scrot'.")

print(f"Screenshot saved: {screenshot_file}")

print("===========================================")
print("Next Steps:")
print(f"Review the AI-generated report: {csv_output}")
print(f"View attack trends: ai_analysis_plot.png")
print(f"View screenshot: {screenshot_file}")
print("Use Splunk to further analyze logs!")
