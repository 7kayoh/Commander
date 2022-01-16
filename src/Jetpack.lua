-- Jetpack.lua
-- First-run script for Commander, to set up things for initialization
-- 7kayoh
-- Jan 16, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = script.Parent.Assets
local Packages = script.Parent.Packages
local Configs = script.Parent.Configs
local Remotes = script.Parent.Remotes
local Modules = Assets.Modules

local Typings = require(Modules.Typings)
local Log = require(Assets.Shared.Log)

local function moveSharedAssets()
    local sharedFolder = Instance.new("Folder")
    sharedFolder.Name = "CommanderShared"
    for _, children in ipairs(Assets.Shared:GetChildren()) do
        children.Parent = sharedFolder
    end
    sharedFolder.Parent = ReplicatedStorage

    require(Assets.Shared)(sharedFolder)
    Log(4, "Moved shared assets to " .. sharedFolder:GetFullName())
end

local function setupRemotes()
    local remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "CommanderRemotes"
    for _, children in ipairs(Remotes:GetChildren()) do
        children.Parent = remotesFolder
    end
    remotesFolder.Parent = ReplicatedStorage

    require(Remotes)(remotesFolder)
    Log(4, "Moved remotes to " .. remotesFolder:GetFullName())
end

return function(configuration: ModuleScript, packages: Folder)
    Log(1, "Setting up Commander...")
    local loadedConfig: Typings.MainConfig = require(configuration) -- For typechecking purposes
    Log.DebugMode = loadedConfig.Misc.Debugging

    Log(4, "Running Jetpack...")
    moveSharedAssets()
    setupRemotes()
    configuration.Parent = Configs
    packages.Parent = Packages.Unloaded

    -- TODO: Write Core first, then setup packages with the Core module
    -- TODO: Write EventRunner in Core, require and call it here
    -- Should be done afterward.
end