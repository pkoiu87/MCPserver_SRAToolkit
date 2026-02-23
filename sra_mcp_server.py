# /home/wpark/nextflow-test/project/A01.SRAtoolkit/sra_mcp_server.py
from mcp.server.fastmcp import FastMCP
import subprocess
import json
import os

# 1. MCP 서버 초기화
mcp = FastMCP("AXP-SRA-Manager")

PROJECT_ROOT = "/home/wpark/nextflow-test/project/A01.SRAtoolkit"

# 2. 도구 정의: 파이프라인 실행
@mcp.tool()
def run_sra_pipeline(r1_path: str, r1_name: str, out_path: str, out_name: str, r2_name: str = "") -> str:
    """Nextflow SRA 파이프라인을 실행합니다.
    입력 파일의 확장자에 따라 자동으로 적절한 변환 공정을 선택합니다:
      - .fastq / .fastq.gz / .fq.gz → latf-load → kar → vdb-validate → sra-stat
      - .bam → bam-load → kar → vdb-validate → sra-stat
    
    r1_path: 입력 파일이 위치한 디렉토리 경로
    r1_name: 입력 파일명 (예: sample.fastq.gz 또는 sample.bam)
    out_path: 결과 저장 경로
    out_name: 출력 SRA 파일명 (예: sample.sra)
    r2_name: (FASTQ 전용) R2 파일명, BAM 입력 시 빈 문자열
    """
    cmd = [
        "nextflow", "run", "main.nf", "-with-apptainer",
        "--srcFilePathR1", r1_path,
        "--srcFileNmR1", r1_name,
        "--srcFilePathR2", r1_path,
        "--srcFileNmR2", r2_name,
        "--outputFilePath", out_path,
        "--outputFileNm", out_name
    ]
    result = subprocess.run(cmd, cwd=PROJECT_ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        return f"실행 실패:\n{result.stderr}"
    return f"실행 완료:\n{result.stdout}"

# 3. 도구 정의: 결과 조회
@mcp.tool()
def get_sample_metadata(sample_id: str, results_dir: str = "") -> str:
    """특정 샘플의 품질 통계(JSONL)를 읽어서 반환합니다."""
    if not results_dir:
        results_dir = os.path.join(PROJECT_ROOT, "results")
    file_path = os.path.join(results_dir, f"{sample_id}.stat.jsonl")
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            return f.read()
    return "해당 샘플의 통계 파일을 찾을 수 없습니다."

if __name__ == "__main__":
    mcp.run()

