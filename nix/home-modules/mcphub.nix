{ lib, config, ... }:
with lib;
{
  options.modules.mcpServer = {
    enable = mkOption { type = types.bool; default = true; };
  };
  config = mkIf config.modules.mcpServer.enable
    {
      home.file.".config/mcphub/server.json.nixGen".text = ''
        {
          "nativeMCPServers": [ ],
          "mcpServers": {
            "sqlite": {
              "disabled": true,
              "args": [
                "--directory",
                "parent_of_servers_repo/servers/src/sqlite",
                "run",
                "mcp-server-sqlite",
                "--db-path",
                "~/test.db"
              ],
              "command": "uv"
            },
            "kubernetes": {
              "args": [
                "mcp-server-kubernetes"
              ],
              "command": "npx"
            },
            "postgres": {
              "args": [
                "-y",
                "@modelcontextprotocol/server-postgres",
                "postgresql://localhost/mydb"
              ],
              "command": "npx"
            },
            "memory": {
              "args": [
                "-y",
                "@modelcontextprotocol/server-memory"
              ],
              "command": "npx"
            },
            "notionApi": {
              "env": {
                "OPENAPI_MCP_HEADERS": "{\"Authorization\": \"Bearer -----\", \"Notion-Version\": \"2022-06-28\" }"
              },
              "disabled": false,
              "args": [
                "-y",
                "@notionhq/notion-mcp-server"
              ],
              "command": "npx"
            },
            "github": {
              "env": {
                "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
              },
              "args": [
                "-y",
                "@modelcontextprotocol/server-github"
              ],
              "command": "npx"
            },
            "blender": {
              "args": [
                "blender-mcp"
              ],
              "command": "uvx"
            },
            "git": {
              "args": [
                "mcp-server-git"
              ],
              "command": "uvx"
            }
          }
        }
      '';
    };
}
