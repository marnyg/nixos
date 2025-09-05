# Agentic D&D Dungeon Master - Design Document

## Overview

The Agentic D&D DM is an AI-powered Dungeon Master system that provides an interactive, persistent D&D gaming experience. The system uses Large Language Models to generate dynamic narratives while maintaining game state, character progression, and world consistency through structured data models and tool integration.

## Core Features

### 1. AI Dungeon Master
- **LLM-Powered Narration**: Uses OpenRouter API with configurable models (default: Claude-3.5-Sonnet)
- **Dynamic Storytelling**: Responds to player actions with contextually appropriate narratives
- **Rule Enforcement**: Automatically manages D&D mechanics through integrated tools
- **Context Management**: Maintains conversation history with intelligent summarization

### 2. Character Management
- **Full D&D Character Support**: Stats, inventory, status effects, background
- **SillyTavern Import**: Import existing characters from SillyTavern JSON format
- **Persistent Character Data**: Characters saved between sessions
- **Dynamic Stat Updates**: Real-time stat modifications during gameplay

### 3. World State Management
- **Persistent World**: Locations, NPCs, and events persist across sessions
- **Dynamic Environment**: Weather, time of day, environmental effects
- **Story Flag System**: Track quest progress and narrative decisions
- **Event System**: Trigger-based events that respond to world changes

### 4. Lorebook System
- **Dynamic Context Injection**: Automatically inject relevant lore based on keywords
- **Multiple Insertion Points**: Control where lore appears in context
- **Priority-Based Selection**: Important lore takes precedence
- **Token Budget Management**: Respects context limits while maximizing relevance
- **SillyTavern Compatibility**: Import world info from SillyTavern format

### 5. Tool Integration (MCP)
- **Dice Rolling**: Full D&D dice mechanics with advantage/disadvantage
- **Character Operations**: Query and modify character stats in real-time
- **Inventory Management**: Add/remove items automatically during gameplay
- **World Updates**: Modify locations, NPCs, and story flags
- **Status Effects**: Apply temporary effects to characters

### 6. Data Persistence
- **Swappable Storage Backend**: Choose between SQL database or JSON files
- **Session Management**: Save/load complete game sessions
- **Character Database**: Centralized character storage across campaigns
- **World State Persistence**: Maintain consistent world across sessions

## Architecture

### Data Flow
```
Player Input → DM Agent → LLM Client (with context + tools) → Response
     ↓              ↓              ↓                            ↓
Game State ← Tool Execution ← Tool Calls ← Response Processing
     ↓
Data Store (SQL/File)
```

### Component Architecture

#### Core Services
- **DMAgent**: Main orchestrator, coordinates all components
- **GameStateManager**: Manages active sessions and character state
- **LLMClient**: Handles OpenRouter API communication and context management
- **LorebookManager**: Dynamic context injection system

#### Data Layer
- **DataStore Interface**: Abstract interface for data persistence
- **SQLDataStore**: SQLAlchemy-based database storage
- **FileDataStore**: JSON file-based storage for debugging
- **StoreFactory**: Creates appropriate store based on configuration

#### Models
- **Character**: Player character data model with D&D stats
- **WorldState**: Complete world state including locations, NPCs, events
- **GameSession**: Session metadata and active context
- **LorebookEntry**: Individual lore entries with trigger conditions
- **LorebookCollection**: Collection of related lore entries

### MCP Tool System
The system uses Model Context Protocol (MCP) to provide the AI with structured tools:

- **roll_dice**: Handle all dice rolling mechanics
- **get_character_stats**: Query character information
- **update_character_stat**: Modify character attributes
- **manage_inventory**: Add/remove items
- **apply_status_effect**: Apply temporary effects
- **update_world_state**: Modify world elements
- **query_world_info**: Retrieve world information
- **add_lorebook_entry**: Create dynamic lore entries

## Configuration

### Environment Variables
```bash
# API Configuration
OPENROUTER_API_KEY=your_api_key
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
DEFAULT_MODEL=anthropic/claude-3.5-sonnet

# Data Storage
DATA_STORE_TYPE=sql  # 'sql' or 'file'
DATABASE_URL=sqlite:///./dnd_sessions.db
FILE_STORE_PATH=game_data

# MCP Server
MCP_SERVER_PORT=3000
```

### Data Store Configuration
- **SQL Mode**: Uses SQLAlchemy with SQLite/PostgreSQL for production use
- **File Mode**: Uses JSON files in structured directories for debugging
  - `game_data/characters/` - Character JSON files
  - `game_data/world_states/` - World state JSON files
  - `game_data/game_sessions/` - Session JSON files
  - `game_data/lorebooks/` - Lorebook JSON files

## Usage Patterns

### Starting a New Campaign
```bash
dnd-dm start "Lost Mines of Phandelver"
```

### Loading Existing Session
```bash
dnd-dm start "Lost Mines of Phandelver" --session session_id
```

### Character Import
```bash
dnd-dm import-character character.json
dnd-dm import-directory ./characters/
```

### Lorebook Import
```bash
dnd-dm import-sillytavern-lorebook worldinfo.json "Campaign Name"
```

## Interactive Commands

### In-Game Commands
- `/help` - Show available commands
- `/info` - Display current session information
- `/quit`, `/exit` - Save and exit session

### Natural Language Actions
Players interact using natural language:
- "I search the room for traps"
- "I want to persuade the guard to let us pass"
- "I cast fireball at the goblins"

The AI automatically:
- Rolls appropriate dice
- Updates character stats
- Modifies world state
- Applies consequences

## Context Management

### Memory Hierarchy
1. **Active Context**: Recent conversation (limited by tokens)
2. **Session Summary**: Compressed summary of current session
3. **Campaign Memory**: Long-term campaign events and decisions
4. **Lorebook Entries**: Dynamically injected relevant lore

### Lorebook Integration
- **Keyword Matching**: Entries trigger based on recent conversation
- **Priority System**: Important lore takes precedence
- **Token Budget**: Respects context limits while maximizing relevance
- **Multiple Positions**: Inject lore at appropriate context points

## Technical Implementation

### Key Technologies
- **FastAPI/MCP**: Tool integration framework
- **Pydantic**: Data validation and serialization
- **SQLAlchemy**: Database ORM (SQL mode)
- **OpenRouter**: LLM API access
- **Typer**: CLI interface
- **Rich**: Enhanced terminal output

### Error Handling
- Graceful degradation when tools fail
- Automatic state recovery on restart
- Input validation for all user data
- Comprehensive logging for debugging

### Performance Optimizations
- Context summarization to manage token limits
- Lazy loading of world state components
- Efficient lorebook scanning with keyword indexing
- Batch operations for data persistence

## Extensibility

### Adding New Tools
1. Define tool function in `DnDTools` class
2. Register with MCP server in `_register_tools()`
3. Add tool schema to `_get_available_tools()`

### Custom Data Stores
1. Implement `DataStore` interface
2. Add factory logic in `store_factory.py`
3. Update configuration options

### Lorebook Extensions
- Custom trigger logic implementations
- Additional insertion positions
- Advanced keyword matching algorithms
- Integration with external knowledge bases

## Security Considerations

- API keys stored in environment variables
- Input validation on all user data
- No direct database access from AI
- Structured tool interface prevents arbitrary code execution
- Local data storage (no external data transmission beyond LLM API)

## Development and Debugging

### File-Based Store Benefits
- **Human-Readable**: JSON files can be manually inspected/edited
- **Version Control Friendly**: Easy to track changes in git
- **Debugging**: Directly examine game state without database tools
- **Backup/Restore**: Simple file operations for data management

### Logging and Monitoring
- Configurable log levels
- Tool execution tracking
- Performance metrics for context management
- Error tracking and recovery

## Future Enhancements

### Planned Features
- Web UI for campaign management
- Multi-player session support
- Voice input/output integration
- Advanced AI agent coordination
- Campaign template system
- Integration with D&D Beyond
- Real-time session sharing

### Technical Improvements
- Distributed session storage
- Advanced context optimization
- Custom model fine-tuning
- Performance monitoring dashboard
- Automated testing framework