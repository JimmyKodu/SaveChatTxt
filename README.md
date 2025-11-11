# SaveChatTxt

A World of Warcraft Classic Era (Vanilla 1.15.8) addon that automatically saves all channel chat messages to persistent logs.

## Features

- **Automatic Logging**: Captures all chat messages from various channels in real-time
- **Persistent Storage**: Saves logs using WoW's SavedVariables system
- **Multiple Channel Support**: Logs messages from:
  - Say, Yell, Whisper
  - Party, Raid, Guild, Officer
  - Custom channels (1-10)
  - Emotes and system messages
- **Easy Management**: Simple slash commands to control logging
- **Memory Efficient**: Automatically limits log size to prevent performance issues

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

## License

Open source - feel free to modify and distribute.

## Author

JimmyKodu