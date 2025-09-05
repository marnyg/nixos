{ lib, config, ... }:
with lib;
{
  options.modules.mcpServer = {
    enable = mkOption { type = types.bool; default = true; };
  };
  config = mkIf config.modules.mcpServer.enable
    {
      home.file.".config/mcphub/servers.json".text = ''
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
              "disabled": true,
              "args": [
                "mcp-server-kubernetes"
              ],
              "command": "npx"
            },
            "postgres": {
              "disabled": true,
              "args": [
                "-y",
                "@modelcontextprotocol/server-postgres",
                "postgresql://localhost/mydb"
              ],
              "command": "npx"
            },
            "memory": {
              "disabled": true,
              "args": [
                "-y",
                "@modelcontextprotocol/server-memory"
              ],
              "command": "npx"
            },
            "notionApi": {
              "disabled": true,
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
              "disabled": true,
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
            },
            "zettelkasten": {
              "command": "nix",
              "args": [
                "run",
                "/home/mar/git/tst#default",
                "--",
                "server"
              ],
              "env": {
                "ZETTEL_NODES_DIR": "/home/mar/git/tst/nodes",
                "ZETTEL_CACHE_DIR": "/home/mar/git/tst/cache"
              }
            }
          }
        }
      '';
    };
}
