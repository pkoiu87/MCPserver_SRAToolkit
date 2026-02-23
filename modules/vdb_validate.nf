process VDB_VALIDATE {
    tag "${sample_id}"; label 'process_low'
    publishDir "${params.outputFilePath}", mode: 'copy'
    input: tuple val(sample_id), path(sra_file), path(vdb_dir)
    output: tuple val(sample_id), path(sra_file), emit: sra_for_stats
            path "${sample_id}.qc_results.jsonl"
    script:
    """
    vdb-validate ${sra_file}
    if [ \$? -eq 0 ]; then
        rm -rf ${vdb_dir}
        echo '{"sample_id": "${sample_id}", "qc_status": "PASS"}' > ${sample_id}.qc_results.jsonl
    else
        exit 1
    fi
    """
}
