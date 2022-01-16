local Module = {}

return setmetatable(Module, {
    __call = function(_, alias: Instance)
        warn("Alias set to " .. alias:GetFullName())
        Module.Alias = alias
    end,

    __index = function(_, index: string)
        if Module.Alias then
            return Module.Alias[index]
        end
        error("Alias is not set yet")
    end
})