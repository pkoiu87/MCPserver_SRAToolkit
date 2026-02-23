process LATF_LOAD {
    tag "${sample_id}"; label 'process_medium'
    input: tuple val(sample_id), path(reads)
    output: tuple val(sample_id), path("vdb_temp"), emit: vdb
    script: "latf-load --quality PHRED_33 -o vdb_temp ${reads}"
}
