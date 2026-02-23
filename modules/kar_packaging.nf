process KAR_PACKAGING {
    tag "${sample_id}"
    label 'process_low'

    input:
    tuple val(sample_id), path(vdb_dir)

    output:
    // 생성된 파일명만 내보냅니다.
    tuple val(sample_id), path("${params.outputFileNm}"), path(vdb_dir), emit: sra_with_tmp

    script:
    """
    # vdb_dir는 Nextflow가 알아서 심볼릭 링크로 연결해줍니다.
    kar -f -c ${params.outputFileNm} -d ${vdb_dir}
    """
}
