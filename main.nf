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
         --center_x 0 --center_y 0 --center_z 0 \
         --size_x 20 --size_y 20 --size_z 20 \
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

    results = []
    for log_file in glob.glob("*_log.txt"):
        with open(log_file, 'r') as f:
            for line in f.readlines():
                if "   1 " in line:  # Extracting the best connection mode (Pose 1)
                    affinity = float(line.split()[1])
                    results.append({'Complex': log_file.replace('_log.txt', ''), 'Affinity (kcal/mol)': affinity})
                    break
    
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