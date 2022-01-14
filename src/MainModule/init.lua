-- 7kayoh, hiyorisaka, 
-- MainModule.lua (synced from internal .git evo/commander)
-- Jan 14, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local import = require(script.Assets.Modules.Import)
local log = import("log")
return function(configFile: ModuleScript, packages: Folder)
	log(log.info, "Welcome to Commander")

	script.Remotes.Parent = ReplicatedStorage
	configFile.Parent = script.Config
	packages.Parent = script.Unloaded

	require(script.Core.Main)()
end