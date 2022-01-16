-- Log.lua
-- 7kayoh
-- Jan 15, 2022

local TestService = game:GetService("TestService")
local Log = {
    Container = {},
    Levels = {
        {Template = "INFO | ", Name = "Info"},
        {Template = "WRN | ", Name = "Warn"},
        {Template = "ERR | ", Name = "Error"},
        {Template = "DEBUG | ", Name = "Debug"}
    },
    DebugMode = false
}

function Log.new(logLevel: number, logMessage: string)
    if logLevel == 4 and not Log.DebugMode then return end
    local levelData = Log.Levels[logLevel]

    if levelData then
        local message = levelData.Template .. logMessage
        table.insert(Log.Container, {
            Type = levelData.Name,
            Time = os.time(),
            Message = logMessage,
        })

        if logLevel == 3 then
            error(message, 2)
        elseif logLevel == 2 then
            warn(message)
        else
            TestService:Message(message)
        end
    end
end

function Log.getAllLogs()
    return Log.Container
end

Log.__index = Log
return setmetatable(Log, {
    __call = function(_, ...)
        Log.new(...)
    end
})