# Agentic D&D Dungeon Master

An AI-powered Dungeon Master system built with Elixir that provides an interactive, persistent D&D gaming experience.

## Features

- 🧙 **AI Dungeon Master**: LLM-powered narration using OpenRouter API
- ⚔️ **Character Management**: Full D&D character support with stats, inventory, and progression
- 🌍 **Persistent World State**: Locations, NPCs, and events that persist across sessions
- 📚 **Dynamic Lorebook**: Automatic context injection based on conversation
- 🎲 **Tool Integration**: Automatic dice rolling, stat updates, and game mechanics
- 💾 **Swappable Storage**: SQL database backend for production use
- 🖥️ **CLI Interface**: Interactive command-line interface for easy access

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository_url>
   cd agentic_dm
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   ```

3. **Set up the database**
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

4. **Configure environment variables**
   ```bash
   export OPENROUTER_API_KEY="your_api_key_here"
   export DEFAULT_MODEL="anthropic/claude-3.5-sonnet"
   ```

## Usage

### Starting a New Campaign

```bash
# Interactive mode
mix run -e "AgenticDm.Main.main([])"

# Or start a campaign directly
mix run -e "AgenticDm.Main.main(['start', 'Lost Mines of Phandelver'])"
```

### Available Commands

- `start <campaign_name>` - Start a new campaign
- `start <campaign_name> --session <session_id>` - Resume existing session
- `list campaigns` - List all campaigns
- `list sessions` - List active sessions
- `list characters` - List active characters
- `import character <file.json>` - Import character from SillyTavern format
- `import lorebook <file.json> <campaign>` - Import world info
- `stats <campaign_name>` - Show campaign statistics

### Session Commands

Once in a game session, you can use:

- `/help` - Show session commands
- `/info` - Display current session information
- `/characters` - List active characters
- `/save` - Save current session
- `/quit` - Save and exit session

### Natural Language Interaction

Simply type your actions in natural language:

- "I search the room for traps"
- "I want to persuade the guard to let us pass"
- "I cast fireball at the goblins"

The AI will automatically:
- Roll appropriate dice
- Update character stats
- Modify world state
- Apply consequences

## Configuration

### Environment Variables

```bash
# Required
OPENROUTER_API_KEY=your_api_key

# Optional
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
DEFAULT_MODEL=anthropic/claude-3.5-sonnet
DATABASE_PATH=dnd_sessions.db
POOL_SIZE=10
```

## Architecture

The system follows a modular architecture:

- **DM Agent**: Main orchestrator (GenServer)
- **LLM Client**: OpenRouter API integration
- **Game State**: Data persistence and management
- **DnD Tools**: Dice rolling and game mechanics
- **Lorebook Manager**: Dynamic context injection
- **CLI**: Interactive command-line interface

## Development

### Running Tests

```bash
mix test
```

### Database Operations

```bash
# Create a new migration
mix ecto.gen.migration create_new_table

# Run migrations
mix ecto.migrate

# Roll back migrations
mix ecto.rollback
```

### Formatting Code

```bash
mix format
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run `mix format` and `mix test`
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Troubleshooting

### Common Issues

**Database errors**: Ensure the database is created and migrated:
```bash
mix ecto.create
mix ecto.migrate
```

**API errors**: Check your OpenRouter API key is valid and has credits.

**Memory issues**: Adjust the database pool size in configuration.

### Support

For issues and questions, please open an issue on GitHub.

