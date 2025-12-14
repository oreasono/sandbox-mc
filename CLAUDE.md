# Minecraft MCP Agent Environment

You are running inside a Docker container with access to a Minecraft server via the MCP (Model Context Protocol).

## Environment

- **Minecraft Server**: `mc-server:25565` (accessible within Docker network)
- **Server Mode**: Creative, Peaceful difficulty, Offline mode
- **Bot Username**: ClaudeBot
- **MCP Server**: minecraft-mcp-server (Mineflayer-based)

## MCP Tools Available

When the Minecraft MCP server is connected, you have access to these tools:

### Movement
- `get-position` - Get your current coordinates (x, y, z)
- `move-to-position` - Pathfind to specific coordinates
- `look-at` - Look at specific coordinates
- `jump` - Make the bot jump
- `move-in-direction` - Move forward/back/left/right

### Flight (Creative Mode)
- `fly-to` - Fly directly to coordinates

### Blocks
- `place-block` - Place a block at coordinates
- `dig-block` - Break a block at coordinates
- `get-block-info` - Get info about a block
- `find-block` - Find nearest block of a type

### Inventory
- `list-inventory` - List all items in inventory
- `find-item` - Search for specific item
- `equip-item` - Equip an item

### Entities
- `find-entity` - Find nearest entity of a type

### Communication
- `send-chat` - Send a chat message
- `read-chat` - Read recent chat messages

### Game State
- `detect-gamemode` - Check current game mode

## Getting Started

1. First, check your position: use `get-position`
2. Explore: use `find-block` to locate interesting blocks
3. Build something: use `place-block` and `dig-block`
4. Check inventory: use `list-inventory`

## Tips

- The server is in Creative mode, so you have unlimited resources
- Peaceful difficulty means no hostile mobs
- The bot spawns at the world spawn point
- Use pathfinding (`move-to-position`) for safe navigation
- In Creative mode, you can fly with `fly-to`

## Troubleshooting

If MCP tools are not available:
1. The MCP server may need to be loaded - check `/mcp` command in Claude Code
2. Verify config exists: `cat ~/.claude.json` or `cat .mcp.json`
3. Restart Claude Code to reload MCP servers

## Human Observer

The human user can watch your actions by connecting their local Minecraft client to `localhost:25565`. They will see the ClaudeBot player moving and building in the world.
