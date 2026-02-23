# test_mcp.py 를 아래 내용으로 완전히 덮어씌워 보세요.
from mcp.server.fastmcp import FastMCP

# 로그를 포함한 모든 print문을 제거합니다.
mcp = FastMCP("AXP-Echo-Test")

@mcp.tool()
def echo_hello(name: str = "Cell Leader") -> str:
    return f"안녕하세요 {name}님, MCP 서버가 정상 작동 중입니다!"

if __name__ == "__main__":
    mcp.run()
