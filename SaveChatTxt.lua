-- SaveChatTxt: Automatically saves channel chat messages to logs
-- Author: JimmyKodu
-- Version: 1.0.0

local ADDON_NAME = "SaveChatTxt"
local MAX_LOG_ENTRIES = 10000  -- Maximum number of log entries to keep

-- Initialize saved variables
SaveChatTxtDB = SaveChatTxtDB or {
    chatLogs = {},
    enabled = true,
    maxEntries = MAX_LOG_ENTRIES
}

-- Create main frame for event handling
local frame = CreateFrame("Frame")

-- Format timestamp
local function GetTimestamp()
    return date("%Y-%m-%d %H:%M:%S")
end

-- Save chat message to log
local function SaveChatMessage(chatType, message, sender)
    if not SaveChatTxtDB.enabled then
        return
    end
    
    local timestamp = GetTimestamp()
    local logEntry = {
        timestamp = timestamp,
        chatType = chatType,
        sender = sender or "Unknown",
        message = message
    }
    
    table.insert(SaveChatTxtDB.chatLogs, logEntry)
    
    -- Trim old entries if exceeding max
    while #SaveChatTxtDB.chatLogs > SaveChatTxtDB.maxEntries do
        table.remove(SaveChatTxtDB.chatLogs, 1)
    end
end

-- Chat message event handler
local function OnChatMessage(self, event, message, sender, ...)
    -- Extract chat type from event name (e.g., "CHAT_MSG_SAY" -> "SAY")
    local chatType = event:match("CHAT_MSG_(.+)")
    
    -- Clean sender name (remove server name if present)
    if sender then
        sender = sender:match("([^-]+)") or sender
    end
    
    SaveChatMessage(chatType, message, sender)
end

-- Register all chat events
local function RegisterChatEvents()
    -- Main chat channels
    frame:RegisterEvent("CHAT_MSG_SAY")
    frame:RegisterEvent("CHAT_MSG_YELL")
    frame:RegisterEvent("CHAT_MSG_WHISPER")
    frame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
    frame:RegisterEvent("CHAT_MSG_PARTY")
    frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    frame:RegisterEvent("CHAT_MSG_RAID")
    frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
    frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
    frame:RegisterEvent("CHAT_MSG_GUILD")
    frame:RegisterEvent("CHAT_MSG_OFFICER")
    
    -- Numbered channels (1-10)
    frame:RegisterEvent("CHAT_MSG_CHANNEL")
    
    -- Emotes
    frame:RegisterEvent("CHAT_MSG_EMOTE")
    frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
    
    -- System messages
    frame:RegisterEvent("CHAT_MSG_SYSTEM")
end

-- Slash command handler
local function SlashCommandHandler(msg)
    local command = msg:lower()
    
    if command == "clear" then
        SaveChatTxtDB.chatLogs = {}
        print(ADDON_NAME .. ": Chat logs cleared.")
    elseif command == "count" then
        print(ADDON_NAME .. ": " .. #SaveChatTxtDB.chatLogs .. " messages logged.")
    elseif command == "enable" then
        SaveChatTxtDB.enabled = true
        print(ADDON_NAME .. ": Logging enabled.")
    elseif command == "disable" then
        SaveChatTxtDB.enabled = false
        print(ADDON_NAME .. ": Logging disabled.")
    elseif command == "status" then
        local status = SaveChatTxtDB.enabled and "enabled" or "disabled"
        print(ADDON_NAME .. ": Status: " .. status .. ", " .. #SaveChatTxtDB.chatLogs .. " messages logged.")
    else
        print(ADDON_NAME .. " Commands:")
        print("  /savechat status - Show current status")
        print("  /savechat enable - Enable logging")
        print("  /savechat disable - Disable logging")
        print("  /savechat count - Show number of logged messages")
        print("  /savechat clear - Clear all logged messages")
    end
end

-- Initialize addon
local function Initialize()
    -- Register slash commands
    SLASH_SAVECHATTXT1 = "/savechat"
    SLASH_SAVECHATTXT2 = "/savechattxt"
    SlashCmdList["SAVECHATTXT"] = SlashCommandHandler
    
    -- Register chat events
    RegisterChatEvents()
    
    -- Set event handler
    frame:SetScript("OnEvent", OnChatMessage)
    
    print(ADDON_NAME .. " v1.0.0 loaded. Type /savechat for commands.")
end

-- Wait for addon to load
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_NAME then
        Initialize()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
