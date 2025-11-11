-- SaveChatTxt: Automatically saves channel chat messages to logs
-- Author: JimmyKodu
-- Version: 1.1.0

local ADDON_NAME = "SaveChatTxt"
local MAX_LOG_ENTRIES = 10000  -- Maximum number of log entries to keep
local LOG_FILE_PATH = "Logs\\WoWChatLog.txt"  -- Log file path relative to WoW directory
local BATCH_WRITE_INTERVAL = 30  -- Seconds between batch writes

-- Initialize saved variables
SaveChatTxtDB = SaveChatTxtDB or {
    chatLogs = {},
    enabled = true,
    maxEntries = MAX_LOG_ENTRIES,
    lastWriteTime = 0
}

-- Create main frame for event handling
local frame = CreateFrame("Frame")
local logFile = nil
local pendingLogs = {}

-- Format timestamp
local function GetTimestamp()
    return date("%Y-%m-%d %H:%M:%S")
end

-- Write log entry to external file immediately
local function WriteToFile(logEntry)
    -- Note: WoW Classic does not support file I/O directly through Lua
    -- This function prepares the log format for manual export
    local logLine = string.format("[%s] [%s] <%s> %s\n", 
        logEntry.timestamp, 
        logEntry.chatType, 
        logEntry.sender, 
        logEntry.message)
    
    -- Add to pending logs buffer for potential export
    table.insert(pendingLogs, logLine)
    
    -- Keep pending logs under control
    while #pendingLogs > 1000 do
        table.remove(pendingLogs, 1)
    end
    
    return logLine
end

-- Get exportable log text
local function GetExportableText(count)
    count = count or #SaveChatTxtDB.chatLogs
    local text = ""
    local startIdx = math.max(1, #SaveChatTxtDB.chatLogs - count + 1)
    
    for i = startIdx, #SaveChatTxtDB.chatLogs do
        local entry = SaveChatTxtDB.chatLogs[i]
        text = text .. string.format("[%s] [%s] <%s> %s\n", 
            entry.timestamp, 
            entry.chatType, 
            entry.sender, 
            entry.message)
    end
    
    return text
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
    
    -- Write to external format immediately
    WriteToFile(logEntry)
    
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

-- Export logs to chat frame for copying
local function ExportLogs(count)
    count = tonumber(count) or 50
    if count > #SaveChatTxtDB.chatLogs then
        count = #SaveChatTxtDB.chatLogs
    end
    
    local text = GetExportableText(count)
    
    -- Create a frame to display the text
    if not SaveChatTxtExportFrame then
        local f = CreateFrame("Frame", "SaveChatTxtExportFrame", UIParent)
        f:SetWidth(600)
        f:SetHeight(400)
        f:SetPoint("CENTER")
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -15)
        title:SetText("SaveChatTxt Export")
        
        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 20, -40)
        scroll:SetPoint("BOTTOMRIGHT", -30, 50)
        
        local editBox = CreateFrame("EditBox", nil, scroll)
        editBox:SetWidth(540)
        editBox:SetHeight(320)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetScript("OnEscapePressed", function() f:Hide() end)
        scroll:SetScrollChild(editBox)
        f.editBox = editBox
        
        local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        close:SetWidth(80)
        close:SetHeight(22)
        close:SetPoint("BOTTOM", 0, 15)
        close:SetText("Close")
        close:SetScript("OnClick", function() f:Hide() end)
        
        local instructions = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        instructions:SetPoint("BOTTOM", 0, 35)
        instructions:SetText("Press Ctrl+A to select all, then Ctrl+C to copy")
    end
    
    SaveChatTxtExportFrame.editBox:SetText(text)
    SaveChatTxtExportFrame.editBox:HighlightText()
    SaveChatTxtExportFrame:Show()
end

-- Slash command handler
local function SlashCommandHandler(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()
    
    if command == "clear" then
        SaveChatTxtDB.chatLogs = {}
        pendingLogs = {}
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
    elseif command == "export" then
        local count = tonumber(arg) or 50
        ExportLogs(count)
        print(ADDON_NAME .. ": Exported last " .. count .. " messages. Press Ctrl+A then Ctrl+C to copy.")
    elseif command == "save" then
        -- Force a reload to save data immediately
        print(ADDON_NAME .. ": Reloading UI to save logs...")
        ReloadUI()
    else
        print(ADDON_NAME .. " Commands:")
        print("  /savechat status - Show current status")
        print("  /savechat enable - Enable logging")
        print("  /savechat disable - Disable logging")
        print("  /savechat count - Show number of logged messages")
        print("  /savechat clear - Clear all logged messages")
        print("  /savechat export [count] - Export last N messages (default 50) to copyable window")
        print("  /savechat save - Force save logs (reloads UI)")
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
    
    print(ADDON_NAME .. " v1.1.0 loaded. Type /savechat for commands.")
    print(ADDON_NAME .. ": Use /savechat export to copy logs to external file or /savechat save to force save.")
end

-- Wait for addon to load
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_NAME then
        Initialize()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
