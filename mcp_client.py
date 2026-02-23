import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def run_test():
    # 1. 서버 실행 파라미터 설정 (절대 경로 사용)
    server_params = StdioServerParameters(
        command="/stge/stge01/nextflow-test/wpark/miniconda3/envs/mcp_env/bin/python",
        args=["-u", "/stge/stge01/nextflow-test/project/A01.SRAtoolkit/sra_mcp_server.py"],
        env=None
    )

    print(">>> [Client] 서버에 연결 시도 중...")
    
    # 2. 서버와 연결 및 세션 시작
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # 초기화 (핸드셰이크)
            await session.initialize()
            print(">>> [Client] 연결 성공!")

            # 3. 도구 목록 확인
            tools = await session.list_tools()
            print(f">>> [Client] 사용 가능한 도구: {[t.name for t in tools.tools]}")

            # 도구 호출 부분 수정
            print(">>> [Client] 샘플 통계 조회 중...")
            # 실제 결과가 있는 경로와 샘플 ID를 넣어보세요
            result = await session.call_tool("get_sample_metadata", arguments={
                "sample_id": "33142T_1", 
                "results_dir": "/stge/stge01/nextflow-test/project/A01.SRAtoolkit/results"
})
            print(f">>> [Server Response]:\n{result.content[0].text}")

if __name__ == "__main__":
    asyncio.run(run_test())
