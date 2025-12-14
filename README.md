# Claude Code + Minecraft Docker Environment

A Docker-based setup that enables Claude Code to play Minecraft through MCP (Model Context Protocol). Watch Claude's bot from your local Minecraft client.

## Architecture

```
Host Machine                          Docker Environment
┌─────────────────────┐              ┌────────────────────────────────┐
│                     │              │                                │
│  HMCL/MC Client     │───:25565────►│  Minecraft Server (1.21.4)     │
│  (observe ClaudeBot)│              │         ▲                      │
│                     │              │         │                      │
│  Browser            │───:5800─────►│  VNC Terminal                  │
│  (Claude Code UI)   │              │    └─► Claude Code CLI         │
│                     │              │            │                   │
└─────────────────────┘              │            ▼                   │
                                     │      MCP Server (Mineflayer)   │
                                     │      (ClaudeBot in-game)       │
                                     └────────────────────────────────┘
```

## Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Minecraft Server | Docker (:25565) | Game world where ClaudeBot plays |
| Claude Code + MCP | Docker (VNC :5800) | AI agent controlling the bot |
| Minecraft Client | Host machine (HMCL) | Your view into the game world |

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Anthropic API key
- Java 21 (for HMCL launcher)

### 1. Start Docker Environment

```bash
# Build and start containers
./run.sh start

# Or manually:
docker compose up -d
```

### 2. Install Minecraft Client (Host Machine)

**HMCL Launcher (included in project):**

```bash
# Install Java if needed
brew install openjdk@21

# Run HMCL
/opt/homebrew/opt/openjdk@21/bin/java -jar HMCL-3.8.1.jar
```

Setup HMCL:
1. Click **No Account** → **Add Offline Account** → enter username (e.g., "Observer")
2. **Install** → select version **1.21.4** → **Install**
3. Launch game → **Multiplayer** → **Add Server** → `localhost:25565`

### 3. Run Claude Code

**Option A: Via VNC (http://localhost:5800)**
```bash
export ANTHROPIC_API_KEY=your_key
claude
```

**Option B: Via run script**
```bash
./run.sh claude
```

### 4. Watch Claude Play

- Join the server from HMCL client as "Observer"
- You'll see ClaudeBot in the same world
- Use `/tp ClaudeBot` to teleport to the bot

## Commands

| Command | Description |
|---------|-------------|
| `./run.sh start` | Start all containers |
| `./run.sh stop` | Stop all containers |
| `./run.sh claude` | Run Claude Code CLI |
| `./run.sh shell` | Open shell in container |
| `./run.sh logs` | View container logs |
| `./run.sh status` | Show container status |
| `./run.sh mc-console` | Access Minecraft server RCON |
| `./run.sh clean` | Remove containers and data |

## Access Points

| Service | URL/Port |
|---------|----------|
| VNC (Claude Code terminal) | http://localhost:5800 |
| Minecraft Server | localhost:25565 |
| RCON Console | localhost:25575 |

## In-Game Commands

After connecting, get OP permissions:
```bash
docker exec minecraft-server rcon-cli "op YourUsername"
```

Useful commands:
- `/list` - List online players
- `/tp ClaudeBot` - Teleport to ClaudeBot
- `/gamemode spectator` - Fly through blocks, invisible
- `/gamemode creative` - Normal creative mode

## Configuration

### Environment Variables (.env)

```bash
# Required
ANTHROPIC_API_KEY=sk-ant-...

# Optional
VNC_PASSWORD=          # VNC access password
```

### Minecraft Server Settings

Pre-configured for AI gameplay:
- **Online Mode**: Disabled (offline accounts work)
- **Difficulty**: Peaceful
- **Game Mode**: Creative
- **Flight**: Allowed

## MCP Tools Available to Claude

When connected, Claude can use these Minecraft tools:

**Movement:** `get-position`, `move-to-position`, `look-at`, `jump`, `fly-to`

**Blocks:** `place-block`, `dig-block`, `find-block`, `get-block-info`

**Inventory:** `list-inventory`, `find-item`, `equip-item`

**Other:** `send-chat`, `read-chat`, `find-entity`, `detect-gamemode`

## Project Structure

```
sandbox-mc/
├── docker-compose.yml       # Container orchestration
├── Dockerfile.claude-mc     # Claude Code + MCP container
├── .env                     # API keys (create this)
├── .gitignore
├── run.sh                   # Control script
├── setup.sh                 # Initial setup
├── HMCL-3.8.1.jar          # Minecraft launcher (host)
├── CLAUDE.md               # Agent instructions
├── scripts/
│   ├── startapp.sh         # VNC terminal startup
│   └── start-mcp-server.sh # MCP server startup
└── minecraft-mcp-server/    # MCP server source
```

## Troubleshooting

### Can't connect to server
```bash
# Check server status
./run.sh status
docker logs minecraft-server
```

### MCP not loading in Claude Code
```bash
# Check config exists
docker exec claude-minecraft-client cat /app/.mcp.json

# Verify with /mcp command in Claude Code
```

### Get OP permissions
```bash
docker exec minecraft-server rcon-cli "op YourUsername"
```

## References

- [minecraft-mcp-server](https://github.com/yuniko-software/minecraft-mcp-server)
- [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)
- [HMCL Launcher](https://github.com/HMCL-dev/HMCL)
- [Claude Code MCP Docs](https://docs.claude.com/en/docs/claude-code/mcp)
