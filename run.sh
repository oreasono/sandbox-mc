#!/bin/bash
# Run script for Claude Code + Minecraft Docker environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Docker compose command (support both v1 and v2)
DOCKER_COMPOSE="docker compose"
if ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
fi

show_help() {
    echo "Claude Code + Minecraft Docker Control Script"
    echo ""
    echo "Usage: ./run.sh <command>"
    echo ""
    echo "Commands:"
    echo "  start       Start all containers"
    echo "  stop        Stop all containers"
    echo "  restart     Restart all containers"
    echo "  status      Show container status"
    echo "  logs        Show container logs"
    echo "  claude      Open Claude Code CLI in the container"
    echo "  mcp         Start the MCP server (for connecting to Claude Desktop)"
    echo "  shell       Open a shell in the client container"
    echo "  mc-console  Open Minecraft server console (RCON)"
    echo "  clean       Remove containers and volumes"
    echo ""
}

start_containers() {
    echo "Starting Claude + Minecraft environment..."
    $DOCKER_COMPOSE up -d

    echo ""
    echo "Waiting for Minecraft server to be ready..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if docker exec minecraft-server mc-health &> /dev/null; then
            echo "Minecraft server is ready!"
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done

    if [ $timeout -le 0 ]; then
        echo "Warning: Minecraft server health check timed out"
    fi

    echo ""
    echo "Environment is running!"
    echo ""
    echo "Access points:"
    echo "  - VNC (Web):        http://localhost:5800"
    echo "  - VNC (Client):     localhost:5900"
    echo "  - Minecraft Server: localhost:25565"
    echo ""
}

stop_containers() {
    echo "Stopping containers..."
    $DOCKER_COMPOSE down
    echo "Containers stopped."
}

restart_containers() {
    stop_containers
    start_containers
}

show_status() {
    $DOCKER_COMPOSE ps
}

show_logs() {
    $DOCKER_COMPOSE logs -f
}

run_claude() {
    echo "Starting Claude Code CLI..."
    echo "The MCP server will connect to the Minecraft server automatically."
    echo ""

    # Start MCP server in background and run Claude
    docker exec -it claude-minecraft-client bash -c '
        # Start MCP server in background
        /app/start-mcp-server.sh &
        MCP_PID=$!

        # Wait a moment for MCP to connect
        sleep 3

        # Run Claude Code
        claude

        # Cleanup
        kill $MCP_PID 2>/dev/null
    '
}

start_mcp_server() {
    echo "Starting MCP server..."
    echo "This will output the stdio for MCP protocol communication."
    echo "Use this with Claude Desktop or other MCP clients."
    echo ""

    docker exec -it claude-minecraft-client /app/start-mcp-server.sh
}

open_shell() {
    echo "Opening shell in claude-minecraft-client container..."
    docker exec -it claude-minecraft-client bash
}

open_mc_console() {
    echo "Connecting to Minecraft server console via RCON..."
    echo "Password is 'claudemc' (as configured in docker-compose.yml)"
    echo ""

    docker exec -it minecraft-server rcon-cli
}

clean_all() {
    echo "WARNING: This will remove all containers and volumes!"
    read -p "Are you sure? (y/N) " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        $DOCKER_COMPOSE down -v
        echo "Cleaned up."
    else
        echo "Cancelled."
    fi
}

# Main command handler
case "${1:-help}" in
    start)
        start_containers
        ;;
    stop)
        stop_containers
        ;;
    restart)
        restart_containers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    claude)
        run_claude
        ;;
    mcp)
        start_mcp_server
        ;;
    shell)
        open_shell
        ;;
    mc-console)
        open_mc_console
        ;;
    clean)
        clean_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
