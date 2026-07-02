x_list, y_list, z_list = [], [], []

with open('receptor.pdbqt', 'r') as f:
    for line in f:
        if line.startswith('ATOM'):
            try:
                # Read X, Y, Z coordinates from standard file columns
                x_list.append(float(line[30:38]))
                y_list.append(float(line[38:46]))
                z_list.append(float(line[46:54]))
            except ValueError:
                pass

if x_list:
    # Calculate the center of the protein
    cx = sum(x_list) / len(x_list)
    cy = sum(y_list) / len(y_list)
    cz = sum(z_list) / len(z_list)

    # Calculate the box size with 15 angstroms of extra space for drug movement
    sx = max(x_list) - min(x_list) + 15
    sy = max(y_list) - min(y_list) + 15
    sz = max(z_list) - min(z_list) + 15

    print("--- Grid Box Parameters ---")
    print(f"center_x = {cx:.3f}")
    print(f"center_y = {cy:.3f}")
    print(f"center_z = {cz:.3f}")
    print(f"size_x = {sx:.3f}")
    print(f"size_y = {sy:.3f}")
    print(f"size_z = {sz:.3f}")
else:
    print("Error: No ATOM lines found.")