-- Main.lua
-- 7kayoh
-- Jan 16, 2022

local Main = {}
local Commander = script.Parent.Parent

Main.Extensions = {
    Player = {
        Checkers = {},
        WrapperDataFetcher = {}
    }
}

Main.ACCEPTED_PACKAGE_TYPE = {"Commands", "Extensions", "Stylesheets"}

Main.Assets = Commander.Assets
Main.Configs = Commander.Configs
Main.Packages = Commander.Packages
Main.Remotes = require(Commander.Remotes)

local Typings = require(Main.Assets.Modules.Typings)

function Main.addPackage(package: ModuleScript)
    local loadedPackage: Typings.BasePackage = require(package)

    if table.find(Main.ACCEPTED_PACKAGE_TYPE, loadedPackage.Type) then
        package.Parent = Main.Packages[loadedPackage.Type]

        if loadedPackage.Container._OnInit then
            loadedPackage.Container._OnInit(script)
        end
    end
end

return Main