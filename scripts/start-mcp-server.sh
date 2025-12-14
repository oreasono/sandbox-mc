#!/bin/bash
# Start the Minecraft MCP server for Claude Code integration

set -e

# Default configuration
MC_SERVER_HOST="${MC_SERVER_HOST:-mc-server}"
MC_SERVER_PORT="${MC_SERVER_PORT:-25565}"
MC_BOT_USERNAME="${MC_BOT_USERNAME:-ClaudeBot}"

echo "Starting Minecraft MCP Server..."
echo "  Host: ${MC_SERVER_HOST}"
echo "  Port: ${MC_SERVER_PORT}"
echo "  Username: ${MC_BOT_USERNAME}"

cd /app/minecraft-mcp-server

# Run the MCP server
exec node dist/main.js \
    --host "${MC_SERVER_HOST}" \
    --port "${MC_SERVER_PORT}" \
    --username "${MC_BOT_USERNAME}"
