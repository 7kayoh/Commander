-- hiyorisaka
-- Import.lua
-- Jan 14, 2022
local Modules = {}

for _, module in ipairs(script.Parent:GetChildren()) do
    if module:IsA("ModuleScript") and module ~= script then
        Modules[module.Name:lower()] = module
    end
end

return function(imports: string|{string})
    if typeof(imports) == "string" then
        assert(Modules[imports:lower()], "No such module found " .. imports)
        return require(Modules[imports:lower()])
    else
        local returns = {}
        for _, name in ipairs(imports) do
            assert(Modules[name:lower()], "No such module found " .. name)
            table.insert(returns, require(Modules[name:lower()]))
        end

        return unpack(returns)
    end
end