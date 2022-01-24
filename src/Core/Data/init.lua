-- Data.lua
-- 7kayoh
-- Jan 24, 2022

local Data = {}

local MainAPI = require(script.Parent.Main)
local SharedAssets = require(MainAPI.Assets.Shared)

local Typings = require(MainAPI.Assets.Modules.Typings)
local pcall = require(SharedAssets.pcall)

function Data.get(name: string, key: string): (boolean, any?)
    if not Data._bindings then
        error("This database is not configured yet")
    end

    return pcall(Data._bindings.get, name, key)
end

function Data.set(name: string, key: string, value: any): (boolean, string?)
    if not Data._bindings then
        error("This database is not configured yet")
    end

    return pcall(Data._bindings.set, name, key, value)
end

function Data.bind(bindings: ModuleScript): boolean
    local bindings: Typings.DataAPIBinding = require(bindings)
    bindings._onInit()
    Data._bindings = bindings
    Data.bind = nil

    return true
end

return Data