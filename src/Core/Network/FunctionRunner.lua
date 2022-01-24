-- FunctionRunner.lua
-- 7kayoh
-- Jan 16, 2022

local MainAPI = require(script.Parent.Parent.Main)
local Methods = script.Parent.RemoteMethods
local Assets = MainAPI.Assets

local Remotes = MainAPI.Remotes

local Typings = require(Assets.Modules.Typings)

Remotes.RemoteFunction.OnServerInvoke = function(player: Player, body: Typings.RemoteBody)
    local method = Methods.Functions:FindFirstChild(body.Method)
    if method then
        return pcall(method(player, body.data))
    else
        return false, body.Method .. " is not a valid member of " .. Methods.Functions:GetFullName()
    end
end

return true