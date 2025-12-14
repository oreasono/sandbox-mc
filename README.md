# Claude Code + Minecraft Docker Environment

A Docker-based setup that enables Claude Code to play Minecraft through MCP (Model Context Protocol), with VNC remote viewing capability.

## Architecture

```
Your Machine                          Docker Environment
┌──────────────┐                     ┌────────────────────────────────┐
│              │                     │                                │
│  Browser     │──── :5800 ─────────►│  VNC Web Interface             │
│  (VNC View)  │                     │         │                      │
│              │                     │         ▼                      │
│  VNC Client  │──── :5900 ─────────►│  Minecraft Client (visual)     │
│              │                     │                                │
│  Your MC     │──── :25565 ────────►│  Minecraft Server (1.21.4)     │
│  Client      │                     │         ▲                      │
│              │                     │         │                      │
└──────────────┘                     │  MCP Server ─── Claude Code    │
                                     │  (Mineflayer bot)              │
                                     └────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Anthropic API key (for Claude Code)

### Setup

```bash
# 1. Run the setup script
./setup.sh

# 2. Edit .env file with your API key
nano .env
# Add: ANTHROPIC_API_KEY=your_key_here

# 3. Start the environment
./run.sh start

# 4. Access the VNC interface
# Open browser: http://localhost:5800

# 5. Run Claude Code with Minecraft
./run.sh claude
```

## Commands

| Command | Description |
|---------|-------------|
| `./run.sh start` | Start all containers |
| `./run.sh stop` | Stop all containers |
| `./run.sh claude` | Run Claude Code CLI with MCP |
| `./run.sh shell` | Open shell in client container |
| `./run.sh logs` | View container logs |
| `./run.sh status` | Show container status |
| `./run.sh mc-console` | Access Minecraft server console |
| `./run.sh clean` | Remove containers and data |

## Access Points

| Service | URL/Port |
|---------|----------|
| VNC (Web) | http://localhost:5800 |
| VNC (Client) | localhost:5900 |
| Minecraft Server | localhost:25565 |
| RCON Console | localhost:25575 |

## Using Claude to Play Minecraft

Once the environment is running:

```bash
./run.sh claude
```

This starts Claude Code with the Minecraft MCP server connected. You can then ask Claude to:

- "Move to coordinates 100, 64, 100"
- "Build a small house"
- "Find and mine some stone"
- "Check my inventory"
- "Look around and describe what you see"

The MCP server provides these tools to Claude:
- Movement: `get-position`, `move-to-position`, `look-at`, `jump`
- Blocks: `place-block`, `dig-block`, `find-block`, `get-block-info`
- Inventory: `list-inventory`, `find-item`, `equip-item`
- Chat: `send-chat`, `read-chat`
- Flight: `fly-to` (in creative mode)
- Entities: `find-entity`

## Configuration

### Environment Variables (.env)

```bash
# Required
ANTHROPIC_API_KEY=sk-ant-...

# Optional
VNC_PASSWORD=          # VNC access password (empty = no password)
MC_VERSION=1.21.4      # Minecraft version
MC_DIFFICULTY=peaceful # Game difficulty
MC_MODE=creative       # Game mode
```

### Minecraft Server Settings

The server is pre-configured for AI-friendly gameplay:
- **Online Mode**: Disabled (allows bot connection without Microsoft auth)
- **Difficulty**: Peaceful (no hostile mobs by default)
- **Game Mode**: Creative (flight and unlimited resources)
- **Flight**: Allowed

## Watching Claude Play

You have two options to observe Claude playing Minecraft:

### Option 1: VNC Web Interface
Open http://localhost:5800 in your browser to see Claude Code's terminal interface.

### Option 2: Connect Your Minecraft Client (Recommended)

Connect your own Minecraft client to watch the ClaudeBot in the same world. Since the server runs in **offline mode**, you don't need a paid Minecraft account.

#### macOS Client Installation

**Option A: HMCL (Hello Minecraft Launcher) - Recommended**

[HMCL](https://github.com/HMCL-dev/HMCL) is an open-source, cross-platform launcher with native offline account support.

1. Download from: https://github.com/HMCL-dev/HMCL/releases
   - Get the `.jar` file (requires Java) or platform-specific package
2. Run HMCL
3. Click **No Account** → **Add Offline Account** → enter any username (e.g., "Observer")
4. Download game: **Install** → select version **1.21.4** → **Install**
5. Launch the game
6. **Multiplayer** → **Add Server** → `localhost:25565`

**Option B: UltimMC (Fork of MultiMC)**

[UltimMC](https://github.com/UltimMC/Launcher) is a MultiMC fork designed for offline play.

1. Download from: https://github.com/UltimMC/Launcher/releases
   - Get the macOS `.tar.gz` or `.dmg` file
2. Extract and run (you may need to run `chmod +x UltimMC.app/Contents/MacOS/UltimMC`)
3. Go to **Accounts** → **Add Local** → enter any username
4. Create instance: **Add Instance** → select **1.21.4**
5. Launch and connect to `localhost:25565`

**Option C: Official Minecraft Launcher (Requires Purchase)**

If you own Minecraft Java Edition:
1. Download from https://www.minecraft.net/download
2. Login with your Microsoft/Mojang account
3. Launch Minecraft 1.21.4
4. Multiplayer → Add Server → `localhost:25565`

#### Windows/Linux

- **HMCL**: https://github.com/HMCL-dev/HMCL/releases (cross-platform)
- **UltimMC**: https://github.com/UltimMC/Launcher/releases

#### Connecting to the Server

Once your client is running:
1. Click **Multiplayer**
2. Click **Add Server**
3. Server Name: `Claude Minecraft` (or anything)
4. Server Address: `localhost:25565`
5. Click **Done**, then select the server and **Join**

You'll spawn in the same world as ClaudeBot and can watch it move, build, and interact in real-time.

## Troubleshooting

### Minecraft client won't start
The client requires Microsoft authentication. For bot-only operation (no visual client), the MCP server's Mineflayer bot works independently of the launcher.

### MCP server connection failed
```bash
# Check if Minecraft server is running
./run.sh status

# View server logs
docker logs minecraft-server

# Ensure server is healthy before connecting
docker exec minecraft-server mc-health
```

### VNC connection issues
```bash
# Check client container logs
docker logs claude-minecraft-client

# Verify ports are mapped
docker port claude-minecraft-client
```

### Performance issues
Increase Docker resources in Docker Desktop settings:
- Memory: 8GB minimum
- CPUs: 4 cores minimum

## Files

```
sandbox-mc/
├── docker-compose.yml      # Container orchestration
├── Dockerfile.claude-mc    # Client container definition
├── setup.sh               # Initial setup script
├── run.sh                 # Control script
├── .env                   # Environment variables (create this)
├── scripts/
│   ├── startapp.sh        # Minecraft launcher startup
│   └── start-mcp-server.sh # MCP server startup
└── minecraft-mcp-server/   # MCP server source code
```

## Known Limitations

1. **Minecraft Authentication**: The visual client requires Microsoft login. The MCP bot works without it when server is in offline mode.

2. **Version Compatibility**: minecraft-mcp-server targets MC 1.21.8. Using 1.21.4 may have minor compatibility differences.

3. **Graphics**: Uses software rendering (llvmpipe). Performance won't match native hardware.

4. **Resource Usage**: Running server + client + Claude in Docker requires significant RAM (~4-6GB).

## Alternative: Headless Operation

If you don't need the visual client, you can run a simpler setup:
- Minecraft server + MCP server only
- Connect your local MC client to observe
- Less resource intensive

See `CLAUDE-MINECRAFT-DOCKER-PLAN.md` for the headless alternative architecture.

## References

- [minecraft-mcp-server](https://github.com/yuniko-software/minecraft-mcp-server)
- [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)
- [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui)
- [Claude Code Documentation](https://code.claude.com/docs)
