# /home/wpark/nextflow-test/project/A01.SRAtoolkit/sra_mcp_server.py
from mcp.server.fastmcp import FastMCP
import subprocess
import json
import os

# 1. MCP 서버 초기화
mcp = FastMCP("AXP-SRA-Manager")

# 2. 도구 정의: 파이프라인 실행
@mcp.tool()
def run_sra_pipeline(r1_path: str, r1_name: str, out_path: str, out_name: str, r2_name: str = "") -> str:
    """Nextflow SRA 파이프라인을 실행합니다."""
    cmd = [
        "nextflow", "run", "main.nf", "-with-apptainer",
        "--srcFilePathR1", r1_path,
        "--srcFileNmR1", r1_name,
        "--srcFilePathR2", r1_path,
        "--srcFileNmR2", r2_name,
        "--outputFilePath", out_path,
        "--outputFileNm", out_name
    ]
    # 비동기로 실행하거나 결과를 기다림
    result = subprocess.run(cmd, capture_output=True, text=True)
    return f"실행 완료: {result.stdout}"

# 3. 도구 정의: 결과 조회
@mcp.tool()
def get_sample_metadata(sample_id: str, results_dir: str) -> str:
    """특정 샘플의 품질 통계(JSONL)를 읽어서 반환합니다."""
    file_path = os.path.join(results_dir, f"{sample_id}.stat.jsonl")
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            return f.read()
    return "해당 샘플의 통계 파일을 찾을 수 없습니다."

if __name__ == "__main__":
    mcp.run()
