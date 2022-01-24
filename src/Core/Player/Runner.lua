-- Runner.lua
-- 7kayoh
-- Jan 22, 2022

local Players = game:GetService("Players")

local PlayerAPI = require(script.Parent)

Players.PlayerAdded:Connect(function(player: Player)
    PlayerAPI.getAdminInfo(player.UserId) -- TBD: Cache first, faster loading in other scripts
end)

Players.PlayerRemoving:Connect(function(player: Player)
    PlayerAPI._caches.AdminCache:Unset(player.UserId) -- GC: Clean cache of that user

    -- TODO: Other GC clean up
end)

return true