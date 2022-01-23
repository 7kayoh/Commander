local Database = {}

local MainAPI = require(script.Parent.Main)
local Typings = require(MainAPI.Assets.Modules.Typings)

function Database.bind(bindings: ModuleScript): boolean
    local bindings: Typings.DatabaseBindings = require(bindings)
    bindings._onInit()
    Database._bindings = bindings
    Database.bind = nil

    return true
end

return Database