import pandas as pd

# Part One: Saving the results of Docking and Lipinski
data = {
    'Compound': ['Celecoxib', 'Indomethacin', 'Ibuprofen'],
    'Binding_Affinity': [-6.541, -6.382, -5.88],
    'Lipinski_Pass': ['Yes', 'Yes', 'Yes']
}
df_results = pd.DataFrame(data)
df_results.to_csv('binding_results.csv', index=False)
print("1. 'binding_results.csv' successfully created!")

# Part 2: Extracting alpha-fold confidence (pLDDT) from the PDB file
residues = []
plddt_scores = []

# Reading the protein file
with open('receptor.pdb', 'r') as f:
    for line in f:
        # Searching for alpha carbon atoms (protein backbone)
        if line.startswith('ATOM') and line[13:15] == 'CA': 
            residue_num = int(line[22:26].strip())
            # Alphafold stores the confidence score in the B-factor column (characters 60 to 66).
            confidence_score = float(line[60:66].strip())
            
            residues.append(residue_num)
            plddt_scores.append(confidence_score)

df_af = pd.DataFrame({'Residue': residues, 'Confidence_pLDDT': plddt_scores})
df_af.to_csv('alphafold_confidence.csv', index=False)
print("2. 'alphafold_confidence.csv' successfully created!")