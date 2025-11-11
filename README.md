# SaveChatTxt

A World of Warcraft Classic Era (Vanilla 1.15.8) addon that automatically saves all channel chat messages to persistent logs with real-time export capability.

## Features

- **Automatic Logging**: Captures all chat messages from various channels in real-time
- **Real-time Export**: Use `/savechat export` to copy logs to external files immediately
- **Force Save**: Use `/savechat save` to trigger immediate SavedVariables write
- **Persistent Storage**: Saves logs using WoW's SavedVariables system
- **Multiple Channel Support**: Logs messages from:
  - Say, Yell, Whisper
  - Party, Raid, Guild, Officer
  - Custom channels (1-10)
  - Emotes and system messages
- **Easy Management**: Simple slash commands to control logging
- **Memory Efficient**: Automatically limits log size to prevent performance issues
- **Export Window**: GUI window to select and copy logs for external saving

## Installation

1. Download the addon
2. Extract the `SaveChatTxt` folder to your WoW installation directory:
   ```
   World of Warcraft\_classic_era_\Interface\AddOns\
   ```
3. Restart WoW or reload UI (`/reload`)

## Usage

### Slash Commands

- `/savechat` or `/savechattxt` - Show help
- `/savechat status` - Show current status and message count
- `/savechat enable` - Enable chat logging
- `/savechat disable` - Disable chat logging
- `/savechat count` - Show number of logged messages
- `/savechat clear` - Clear all logged messages
- `/savechat export [count]` - Export last N messages (default 50) to a copyable window
- `/savechat save` - Force save logs immediately (reloads UI)

### Real-time Export

**Important**: WoW Classic does not support direct file I/O. To get real-time logs:

1. Use `/savechat export [count]` to open an export window with your logs
2. Press Ctrl+A to select all text
3. Press Ctrl+C to copy
4. Paste into your favorite text editor and save

Alternatively, use `/savechat save` to force a UI reload which will write SavedVariables to disk immediately.

### Accessing Logs

Chat logs are stored in the SavedVariables file:
```
World of Warcraft\_classic_era_\WTF\Account\[ACCOUNT]\SavedVariables\SaveChatTxt.lua
```

Each log entry contains:
- Timestamp (YYYY-MM-DD HH:MM:SS)
- Chat type (SAY, YELL, WHISPER, PARTY, RAID, GUILD, etc.)
- Sender name
- Message content

## Configuration

By default, the addon:
- Is enabled on first load
- Stores up to 10,000 messages
- Automatically trims older messages when the limit is reached

## Technical Details

- **Interface Version**: 11508 (WoW Classic Era Vanilla 1.15.8)
- **SavedVariables**: SaveChatTxtDB
- **Export Format**: `[timestamp] [chatType] <sender> message`

## Limitations

Due to WoW security restrictions, addons cannot write files directly to disk. This addon provides:
- In-memory logging with immediate capture
- Export window for manual copy/paste to external files
- Force save command to trigger SavedVariables write via UI reload

## License

Open source - feel free to modify and distribute.

## Author

JimmyKodu