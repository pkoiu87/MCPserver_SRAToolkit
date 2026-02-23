// main.nf
nextflow.enable.dsl=2

include { LATF_LOAD } from './modules/latf_load'
include { BAM_LOAD } from './modules/bam_load'
include { KAR_PACKAGING } from './modules/kar_packaging'
include { VDB_VALIDATE } from './modules/vdb_validate'
include { SRA_STAT } from './modules/sra_stat'

workflow {
    // 1. 샘플 ID 추출
    def sample_id = params.outputFileNm.replace(".sra", "")

    // 2. 입력 파일 확장자 자동 감지 → 분기 처리
    def r1_name = params.srcFileNmR1.toLowerCase()

    if (r1_name.endsWith('.bam')) {
        // ── BAM 입력 경로 ──
        def bam_file = file("${params.srcFilePathR1}/${params.srcFileNmR1}")
        bam_ch = Channel.of([sample_id, bam_file])
        BAM_LOAD(bam_ch)
        vdb_ch = BAM_LOAD.out.vdb

    } else {
        // ── FASTQ 입력 경로 (.fastq, .fastq.gz, .fq, .fq.gz) ──
        def r1_file = file("${params.srcFilePathR1}/${params.srcFileNmR1}")
        def reads = [r1_file]
        if (params.srcFileNmR2 != "") reads.add(file("${params.srcFilePathR2}/${params.srcFileNmR2}"))
        input_ch = Channel.of([sample_id, reads])
        LATF_LOAD(input_ch)
        vdb_ch = LATF_LOAD.out.vdb
    }

    // 3. 공통 공정: KAR → VDB_VALIDATE → SRA_STAT
    KAR_PACKAGING(vdb_ch)
    VDB_VALIDATE(KAR_PACKAGING.out.sra_with_tmp)
    SRA_STAT(VDB_VALIDATE.out.sra_for_stats)
}
