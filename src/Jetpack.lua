-- Jetpack.lua
-- First-run script for Commander, to set up things for initialization
-- 7kayoh
-- Jan 16, 2022
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = script.Parent.Assets
local Configs = script.Parent.Configs
local Core = script.Parent.Core
local Packages = script.Parent.Packages
local Remotes = script.Parent.Remotes
local Modules = Assets.Modules

local Typings = require(Modules.Typings)

local function moveSharedAssets()
    local sharedFolder = Instance.new("Folder")
    sharedFolder.Name = "CommanderShared"
    for _, children in ipairs(Assets.Shared:GetChildren()) do
        children.Parent = sharedFolder
    end
    sharedFolder.Parent = ReplicatedStorage

    require(Assets.Shared)(sharedFolder)
end

local function setupRemotes()
    local remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "CommanderRemotes"
    for _, children in ipairs(Remotes:GetChildren()) do
        children.Parent = remotesFolder
    end
    remotesFolder.Parent = ReplicatedStorage

    require(Remotes)(remotesFolder)
end

return function(configuration: ModuleScript, packages: Folder)
    print("Setting up Commander...")
    local loadedConfig: Typings.MainConfig = require(configuration) -- For typechecking purposes

    print("Running Jetpack...")
    moveSharedAssets()
    setupRemotes()
    configuration.Name = "MainConfig"
    configuration.Parent = Configs
    packages.Parent = Packages.Unloaded

    local MainAPI = require(Core.Main)
    for _, API: ModuleScript in ipairs(Core:GetChildren()) do
        if API ~= Core.Main then
            API = require(API)
            if API._onInit then
                API._onInit()
            end
        end
    end

    for _, package in ipairs(packages:GetChildren()) do
        MainAPI.addPackage(package)
    end

    -- TBD
    -- Should be done afterward.
end