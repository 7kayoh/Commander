local TestService = game:GetService("TestService")

local Log = {
    Info = 1,
    Warning = 2,
    Error = 3,

    Templates = {
        "ℹ️ ",
        "⚠️ ",
        "⛔ ",
    }
}

function Log.func(level: number, message: string)
    if level == Log.Error then
        error(Log.Templates[level] .. message, 2)
    elseif level == Log.Warning then
        warn(Log.Templates[level] .. message)
    else
        TestService:Message(Log.Templates[1] .. message)
    end
end

return setmetatable(Log, {
    __call = Log.func
})