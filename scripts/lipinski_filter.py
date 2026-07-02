import pubchempy as pcp

# Drugs we tested in the previous step
compounds = ['Celecoxib', 'Indomethacin', 'Ibuprofen']

print("--- Lipinski Rule of Five Analysis ---\n")

for name in compounds:
    # Retrieve drug information from the database
    c = pcp.get_compounds(name, 'name')[0]
    
    mw = float(c.molecular_weight)
    logp = float(c.xlogp)
    hbd = c.h_bond_donor_count
    hba = c.h_bond_acceptor_count

    print(f"Drug: {name}")
    print(f"  Molecular Weight (<500) : {mw}")
    print(f"  LogP (<5)               : {logp}")
    print(f"  H-Bond Donors (<5)      : {hbd}")
    print(f"  H-Bond Acceptors (<10)  : {hba}")
    
    # Review the rules
    violations = 0
    if mw >= 500: violations += 1
    if logp >= 5: violations += 1
    if hbd >= 5: violations += 1
    if hba >= 10: violations += 1
    
    if violations <= 1:
        print("  >> Result: PASS (Drug-like)")
    else:
        print("  >> Result: FAIL (Not Drug-like)")
    print("-" * 30)