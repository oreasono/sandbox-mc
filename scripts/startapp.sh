#!/bin/bash
# Startup script for Claude Code + Minecraft MCP in VNC environment

set -e

# Set environment
export HOME=/config
export XDG_CONFIG_HOME=/config/.config
export TERM=xterm-256color
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US:en

# Create welcome script that starts in /app
cat > /tmp/welcome.sh << 'WELCOME'
#!/bin/bash
export HOME=/config
export XDG_CONFIG_HOME=/config/.config
export TERM=xterm-256color
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US:en
cd /app

clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        Claude Code + Minecraft MCP Server                    ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  Minecraft server: mc-server:25565                           ║"
echo "║  Watch the bot: connect YOUR MC client to localhost:25565    ║"
echo "║                                                              ║"
echo "║  To start Claude Code:                                       ║"
echo "║    1. export ANTHROPIC_API_KEY=your_key                      ║"
echo "║    2. claude                                                 ║"
echo "║                                                              ║"
echo "║  MCP should auto-load from ~/.claude.json or .mcp.json       ║"
echo "║  If not, run: claude mcp add minecraft ...                   ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Config files:"
echo "  ~/.claude.json : $([ -f /config/.claude.json ] && echo 'exists' || echo 'missing')"
echo "  .mcp.json      : $([ -f /app/.mcp.json ] && echo 'exists' || echo 'missing')"
echo "  CLAUDE.md      : $([ -f /app/CLAUDE.md ] && echo 'exists' || echo 'missing')"
echo ""

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  ANTHROPIC_API_KEY not set!"
    echo "   Run: export ANTHROPIC_API_KEY=your_key"
    echo ""
fi

exec bash
WELCOME
chmod +x /tmp/welcome.sh

# Start terminal in /app directory
exec xfce4-terminal \
    --geometry=120x40 \
    --title="Claude Minecraft" \
    --working-directory=/app \
    --command="/tmp/welcome.sh"
