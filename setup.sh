#!/bin/bash
# Setup script for Claude Code + Minecraft Docker environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================"
echo "Claude Code + Minecraft Docker Setup"
echo "========================================"
echo ""

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."

    if ! command -v docker &> /dev/null; then
        echo "ERROR: Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "ERROR: Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    echo "  ✓ Docker installed"
    echo "  ✓ Docker Compose installed"
}

# Check for API key
check_api_key() {
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo ""
        echo "WARNING: ANTHROPIC_API_KEY is not set."
        echo "You can set it by:"
        echo "  1. Creating a .env file with: ANTHROPIC_API_KEY=your_key"
        echo "  2. Or export it: export ANTHROPIC_API_KEY=your_key"
        echo ""

        if [ -f ".env" ]; then
            echo "Found .env file, will use that."
            source .env
        fi
    else
        echo "  ✓ ANTHROPIC_API_KEY is set"
    fi
}

# Build the Docker image
build_image() {
    echo ""
    echo "Building Claude + Minecraft client image..."
    echo "(This may take several minutes on first run)"
    echo ""

    docker compose build claude-client

    echo ""
    echo "  ✓ Image built successfully"
}

# Create .env template if not exists
create_env_template() {
    if [ ! -f ".env" ]; then
        cat > .env << 'EOF'
# Anthropic API Key for Claude Code
ANTHROPIC_API_KEY=

# Optional: VNC password (leave empty for no password)
VNC_PASSWORD=

# Optional: Minecraft server settings
MC_VERSION=1.21.4
MC_DIFFICULTY=peaceful
MC_MODE=creative
EOF
        echo ""
        echo "Created .env template file. Please edit it with your API key."
    fi
}

# Main setup flow
main() {
    check_prerequisites
    create_env_template
    check_api_key
    build_image

    echo ""
    echo "========================================"
    echo "Setup Complete!"
    echo "========================================"
    echo ""
    echo "To start the environment:"
    echo "  ./run.sh start"
    echo ""
    echo "To access:"
    echo "  - VNC (Web): http://localhost:5800"
    echo "  - VNC (Client): localhost:5900"
    echo "  - Minecraft Server: localhost:25565"
    echo ""
    echo "To run Claude Code with Minecraft MCP:"
    echo "  ./run.sh claude"
    echo ""
}

main "$@"
