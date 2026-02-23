// main.nf
nextflow.enable.dsl=2

include { LATF_LOAD } from './modules/latf_load'
include { KAR_PACKAGING } from './modules/kar_packaging'
include { VDB_VALIDATE } from './modules/vdb_validate'
include { SRA_STAT } from './modules/sra_stat'

workflow {
    // 1. 샘플 ID 추출 및 입력 채널 형성
    def sample_id = params.outputFileNm.replace(".sra", "")
    def r1_file = file("${params.srcFilePathR1}/${params.srcFileNmR1}")
    def reads = [r1_file]
    if (params.srcFileNmR2 != "") reads.add(file("${params.srcFilePathR2}/${params.srcFileNmR2}"))

    input_ch = Channel.of([sample_id, reads])

    // 2. 4단계 표준 공정 실행
    LATF_LOAD(input_ch)
    KAR_PACKAGING(LATF_LOAD.out.vdb)
    VDB_VALIDATE(KAR_PACKAGING.out.sra_with_tmp)
    SRA_STAT(VDB_VALIDATE.out.sra_for_stats)
}
