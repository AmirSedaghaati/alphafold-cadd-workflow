#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.data_dir = "$projectDir/data"
params.outdir = "$projectDir/results/nextflow_output"

process PREP_AND_DOCK {
    publishDir "${params.outdir}/docking_results", mode: 'copy'
    
    input:
    path receptor
    path ligand
    
    output:
    path "*_out.pdbqt", emit: docked_poses
    path "*_log.txt", emit: dock_log
    
    script:
    def prefix = "${receptor.baseName}_${ligand.baseName}"
    """
    obabel -ipdb $receptor -opdbqt -O receptor.pdbqt -xr
    obabel -isdf $ligand -opdbqt -O ligand.pdbqt --gen3d

vina --receptor receptor.pdbqt --ligand ligand.pdbqt \
         --center_x -13.681 --center_y -1.686 --center_z 4.773 \
         --size_x 137.500 --size_y 91.140 --size_z 130.500 \
         --out ${prefix}_out.pdbqt \
         --log ${prefix}_log.txt
    """
}

// A new process for automatically extracting and ranking complex results
process ANALYZE_RESULTS {
    publishDir "${params.outdir}/analysis", mode: 'copy'
    
    input:
    path logs
    
    output:
    path "binding_affinities_summary.csv"
    
    script:
    """
    #!/usr/bin/env python3
    import glob
    import pandas as pd

    import re
    for log_file in glob.glob("*_log.txt"):
        with open(log_file, 'r') as f:
            content = f.read()
        match = re.search(r"^\s*1\s+([-+]?\d+\.\d+)", content, re.MULTILINE)
        if match:
            results.append({'Complex': log_file.replace('_log.txt', ''), 'Affinity (kcal/mol)': float(match.group(1))})
    
    df = pd.DataFrame(results).sort_values(by='Affinity (kcal/mol)')
    df.to_csv("binding_affinities_summary.csv", index=False)
    """
}

workflow {
    receptors = Channel.fromPath("${params.data_dir}/*.pdb")
    ligands = Channel.fromPath("${params.data_dir}/*.sdf")

    docking_ch = PREP_AND_DOCK(receptors, ligands)
    
    // Collect all logs after docking is complete and send to Python script
    ANALYZE_RESULTS(docking_ch.dock_log.collect())
}
