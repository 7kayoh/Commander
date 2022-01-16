-- EventRunner.lua
-- 7kayoh
-- Jan 16, 2022

local Main = require(script.Parent.Parent.Main)
local Methods = script.Parent.RemoteMethods
local Assets = Main.Assets

local Remotes = Main.Remotes
local Shared = require(Assets.Shared)

local Typings = require(Assets.Modules.Typings)
local Log = Shared.Log

Remotes.RemoteEvent.OnServerEvent:Connect(function(player: Player, body: Typings.RemoteBody)
    local method = Methods.Event:FindFirstChild(body.Method)
    if method then
        method(player, body.data)
    else
        Log(3, body.Method .. " is not a valid member of " .. Methods.Event:GetFullName())
    end
end)