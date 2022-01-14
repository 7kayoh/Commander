local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MainModule = script.Parent.Parent
local Assets = MainModule.Assets
local Config = MainModule.Config
local Core = MainModule.Core
local Packages = MainModule.Packages

local import = require(Assets.Modules.Import)
local log = import("log")