-- Main.lua
-- 7kayoh
-- Jan 16, 2022

local Main = { PackageAliases = {}, Binders = {} }
local Commander = script.Parent.Parent

Main.ACCEPTED_PACKAGE_TYPE = { "Commands", "Extensions", "Stylesheets" }

Main.Assets = Commander.Assets
Main.Configs = Commander.Configs
Main.Packages = Commander.Packages
Main.Remotes = require(Commander.Remotes)

local SharedAssets = require(Main.Assets.Shared)

local Typings = require(Main.Assets.Modules.Typings)
local GlobConstants = require(SharedAssets.Constants)

function Main.addPackage(package: ModuleScript)
	if package.Name:match(".pkg$") then
		local loadedPackage: Typings.BasePackage = require(package)

		if table.find(Main.ACCEPTED_PACKAGE_TYPE, loadedPackage.Type) then
			Main.PackageAliases[loadedPackage.Id:lower()] = package
			package.Parent = Main.Packages[loadedPackage.Type]

			if loadedPackage.Container._OnInit then
				loadedPackage.Container._OnInit(script)
			end
		end
	end
end

function Main.addPackageDir(directory: Folder)
	for _, instance in ipairs(directory:GetDescendants()) do
		if instance:IsA("ModuleScript") and instance.Name:match(".pkg$") then
			Main.addPackage(instance)
		end
	end
end

function Main.findPackage(packageId: string): Typings.BasePackage?
	for name, alias in pairs(Main.PackageAliases) do
		if name == packageId:lower() then
			return require(alias)
		end
	end
end

function Main.addBinder(binder: Typings.BaseBinder)
	assert(Main.Binders[binder.BindType], "Binder already exists")
	Main.Binders[binder.BindType] = binder.Callback
end

function Main.getVersion(pattern: string): string
	local patterns = {
		["%SV%"] = GlobConstants.Version[1],
		["%CN%"] = GlobConstants.Version[2],
		["%LC%"] = GlobConstants.Version[3],
	}

	pattern = pattern:gsub("%%%w+%%", function(text)
		return patterns[text] or text
	end)

	return pattern
end

return Main
