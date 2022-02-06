-- Network.lua
-- 7kayoh
-- Jan 16, 2022

local MainAPI = require(script.Parent.Main)
local Methods = script.RemoteMethods
local Assets = MainAPI.Assets

local Remotes = MainAPI.Remotes
local Typings = require(Assets.Modules.Typings)

local Network = {
    MethodTypes = { "Event", "Function" }
}

function Network.addMethod(remoteMethod: ModuleScript, methodType: string)
    assert(table.find(Network.MethodTypes, methodType:lower()), "Invalid method type")
    -- lmao im so lazy
    remoteMethod:Clone().Parent = Methods[Network.MethodTypes[table.find(Network.MethodTypes, methodType:lower())]]
end

function Network._onInit()
    Network._OnInit = nil
    Remotes.RemoteFunction.OnServerInvoke = function(player: Player, body: Typings.RemoteBody): any?
        local method = Methods.Functions:FindFirstChild(body.Method)
        if method then
            return pcall(method(player, body.data))
        else
            error(body.Method .. " is not a valid member of " .. Methods.Functions:GetFullName())
        end
    end
    
    Remotes.RemoteEvent.OnServerEvent:Connect(function(player: Player, body: Typings.RemoteBody)
        local method = Methods.Events:FindFirstChild(body.Method)
        if method then
            method(player, body.data)
        else
            error(body.Method .. " is not a valid member of " .. Methods.Events:GetFullName())
        end
    end)
end

return Network