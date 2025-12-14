# Claude Code + Minecraft Docker Setup Plan

## Overview

This plan outlines how to create a Docker-based environment where Claude Code can play Minecraft, with remote viewing capability via VNC.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Docker Network                                │
│                                                                      │
│  ┌──────────────────────┐      ┌──────────────────────────────────┐ │
│  │  Minecraft Server    │      │  Claude + Minecraft Client       │ │
│  │  (itzg/minecraft)    │      │  (custom image)                  │ │
│  │                      │      │                                  │ │
│  │  - MC Server 1.21.4  │◄────►│  - Minecraft Client (launcher)   │ │
│  │  - Port 25565        │      │  - minecraft-mcp-server          │ │
│  │  - Java 21           │      │  - Claude Code CLI               │ │
│  │                      │      │  - VNC Server (port 5900)        │ │
│  └──────────────────────┘      │  - Web VNC (port 5800)           │ │
│                                │  - Node.js 22                    │ │
│                                └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                            ┌─────────────────────┐
                            │  Your Local Machine │
                            │                     │
                            │  Browser → :5800    │
                            │  VNC Client → :5900 │
                            └─────────────────────┘
```

## Components

### 1. Minecraft Server Container
- **Image**: `itzg/minecraft-server:java21`
- **Version**: MC 1.21.4 (closest available to MCP server's 1.21.8 requirement, or latest 1.21.x)
- **Configuration**: Online mode disabled for bot access, open LAN

### 2. Claude + Client Container (Custom Build)
Base image options:
- **Option A (Recommended)**: `jlesage/baseimage-gui:ubuntu-22.04-v4` - mature VNC+web solution
- **Option B**: Build from `ubuntu:22.04` with manual VNC setup

Components to install:
- **Java 21** (for Minecraft client)
- **Node.js 22** (for MCP server and Claude Code)
- **Minecraft Launcher** (official .deb)
- **minecraft-mcp-server** (from local repo)
- **Claude Code CLI** (`npm install -g @anthropic-ai/claude-code`)
- **VNC/Display**: TigerVNC + Openbox (provided by base image)

## File Structure

```
sandbox-mc/
├── docker-compose.yml           # Orchestration
├── Dockerfile.claude-mc         # Custom client container
├── scripts/
│   ├── start-minecraft.sh       # Launch MC client
│   ├── start-claude-mcp.sh      # Start MCP server
│   └── entrypoint.sh            # Container startup
├── config/
│   ├── claude-mcp-config.json   # MCP server config
│   └── .minecraft/              # MC client data (volume mount)
└── minecraft-mcp-server/        # Already present
```

## Implementation Steps

### Step 1: Create Dockerfile.claude-mc

The Dockerfile needs to:
1. Start from `jlesage/baseimage-gui:ubuntu-22.04-v4`
2. Install Java 21 (Eclipse Temurin)
3. Install Node.js 22
4. Install Minecraft launcher
5. Install Claude Code CLI
6. Copy and build minecraft-mcp-server
7. Configure startup scripts

### Step 2: Create docker-compose.yml

Define two services:
- `mc-server`: Minecraft server (itzg image)
- `claude-client`: Custom container with VNC

Shared network for inter-container communication.

### Step 3: Setup Scripts

- `entrypoint.sh`: Initialize display, start VNC
- `start-minecraft.sh`: Launch MC client and login
- `start-claude-mcp.sh`: Connect MCP server to MC server

### Step 4: Configuration

- Minecraft server: EULA=TRUE, online-mode=false, difficulty=peaceful
- MCP server: --host mc-server --port 25565 --username ClaudeBot
- Claude Code: API key via environment variable

## Key Technical Decisions

### Minecraft Version Compatibility
The minecraft-mcp-server README states it supports **MC 1.21.8**. However, as of late 2024, Minecraft releases are at 1.21.x. We'll use the latest 1.21.x version available and test compatibility. Mineflayer (the underlying bot library) typically works across minor version differences.

### Authentication Challenge
Running Minecraft client in Docker requires dealing with Microsoft authentication. Options:
1. **Offline mode server** - Set `online-mode=false` on server, client connects with any username
2. **Pre-authenticated session** - Mount existing `.minecraft` with saved credentials
3. **Headless bot only** - Skip visual client, use MCP server's Mineflayer bot directly

**Recommendation**: Use offline mode server + MCP bot for Claude, plus optional visual client for human observation.

### VNC Security
For local development:
- No password (convenience)
- Bind to localhost only if security is a concern

For remote access:
- Set VNC_PASSWORD
- Consider SSH tunnel

## Usage Flow

1. **Start containers**:
   ```bash
   docker-compose up -d
   ```

2. **Access VNC**:
   - Browser: http://localhost:5800
   - VNC client: localhost:5900

3. **Authenticate Claude Code** (first time):
   ```bash
   docker exec -it claude-client claude auth
   ```

4. **Start playing**:
   ```bash
   docker exec -it claude-client claude
   # Then ask Claude to play Minecraft via MCP tools
   ```

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `ANTHROPIC_API_KEY` | Claude authentication | (required) |
| `MC_VERSION` | Minecraft version | 1.21.4 |
| `MC_SERVER_HOST` | Server hostname | mc-server |
| `MC_SERVER_PORT` | Server port | 25565 |
| `DISPLAY_WIDTH` | VNC width | 1920 |
| `DISPLAY_HEIGHT` | VNC height | 1080 |
| `VNC_PASSWORD` | VNC access password | (none) |

## Potential Challenges

1. **Minecraft client login**: Microsoft auth in headless container is complex
2. **Graphics rendering**: May need software rendering (Mesa/llvmpipe)
3. **MCP version mismatch**: May need to adjust Mineflayer version
4. **Performance**: Running MC client + server + Claude in Docker is resource-intensive

## Alternative Approach: Headless-Only

If visual client proves too complex, a simpler setup:
- Run only MC server + MCP server in Docker
- Claude controls bot via MCP tools
- No VNC needed (bot operates without visual rendering)
- Connect your local MC client to Docker server to observe

This approach is more reliable but less "visual" for watching Claude play.

## Resource Requirements

Minimum recommended:
- **CPU**: 4 cores
- **RAM**: 8GB
- **Disk**: 10GB (images + MC data)

## Next Steps

1. Create and test `Dockerfile.claude-mc`
2. Create `docker-compose.yml`
3. Write startup scripts
4. Test MC server + MCP connection
5. Add Claude Code and test full workflow
6. Document final setup

## References

- [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)
- [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui)
- [minecraft-mcp-server](./minecraft-mcp-server/README.md)
- [Claude Code DevContainer](https://code.claude.com/docs/en/devcontainer)
- [acaranta/docker-minecraft-client](https://github.com/acaranta/docker-minecraft-client)
