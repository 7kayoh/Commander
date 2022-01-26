-- EventRunner.lua
-- 7kayoh
-- Jan 16, 2022

local MainAPI = require(script.Parent.Parent.Main)
local Methods = script.Parent.RemoteMethods
local Assets = MainAPI.Assets

local Remotes = MainAPI.Remotes

local Typings = require(Assets.Modules.Typings)

Remotes.RemoteEvent.OnServerEvent:Connect(function(player: Player, body: Typings.RemoteBody)
    local method = Methods.Events:FindFirstChild(body.Method)
    if method then
        method(player, body.data)
    else
        error(3, body.Method .. " is not a valid member of " .. Methods.Events:GetFullName())
    end
end)

return true