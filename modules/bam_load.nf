process BAM_LOAD {
    tag "${sample_id}"; label 'process_medium'
    input: tuple val(sample_id), path(bam_file)
    output: tuple val(sample_id), path("vdb_temp"), emit: vdb
    script: "bam-load -o vdb_temp ${bam_file}"
}
