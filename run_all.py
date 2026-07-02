import os
import subprocess
import re

# Our medicine list
ligands = ['ibuprofen', 'indomethacin', 'celecoxib']
results = {}

print("Starting Automated Docking Pipeline...\n")

for lig in ligands:
    log_file_path = f"{lig}_log.txt"
    
    # If the log file does not already exist, run the docking
    if not os.path.exists(log_file_path):
        print(f"Running Vina for {lig} (This may take a few minutes)...")
        cmd = f"vina.exe --config config.txt --ligand {lig}.pdbqt --out {lig}_out.pdbqt"
        
        with open(log_file_path, "w") as log_file:
            subprocess.run(cmd, shell=True, stdout=log_file)
    else:
        print(f"Skipping {lig}: Already docked.")

    # Automatically extract and filter the best score from the log file
    with open(log_file_path, "r") as f:
        content = f.read()
        # Search to find the first row number (mode 1)
        match = re.search(r"\s+1\s+([-+]\d+\.\d+)", content)
        if match:
            results[lig] = float(match.group(1))

# Ranking of drugs from best (most negative) to worst
print("\n--- Final Ranked Results ---")
for lig, score in sorted(results.items(), key=lambda x: x[1]):
    print(f"{lig.capitalize():<15}: {score} kcal/mol")