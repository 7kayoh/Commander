-- Player.lua
-- hiyorisaka & 7kayoh
-- Jan 16, 2022


local Player = {}
Player.Extensions = {
    Checkers = {},
    PlayerProfile = {
        DataFetchers = {}
    }
}

local MainAPI = require(script.Parent.Main)
local SharedAssets = require(MainAPI.Assets.Shared)

local Kache = require(SharedAssets.Kache)
local Typings = require(MainAPI.Assets.Modules.Typings)
local MainConfig: Typings.MainConfig = require(MainAPI.Configs.MainConfig)

Player._caches = {
    AdminCache = Kache.new()
}

function Player.getAdminInfo(userId: number): Typings.GroupConfig
    local cachedData: number? = Player._caches.AdminCache:Get(userId)

    if cachedData then
        return MainConfig.Groups[cachedData]
    else
        local index: number? = nil
        for _, module: ModuleScript in ipairs(Player.Extensions.Checkers) do
            local status: boolean, response: number|string = require(module).Target.Main(userId)
            if status and type(response) == "number" and response > index then
                index = response
                if index == 1 then
                    break
                end
                continue
            elseif not status then
                error("Error occurred when checking player's admin with checker " .. module:GetFullName() .. "\n\n" .. response, 2)
            end
        end
    
        Player._caches.AdminCache:Set(userId, index, MainConfig.Misc.CacheTimeout)
        return MainConfig.Groups[index]
    end
end

function Player.isAdmin(userId: number): boolean
    return Player.getAdminInfo(userId) ~= nil
end

function Player.getProfile(player: Player): {any}
    local profile = {
        Packages = {},
        Name = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        _instance = player
    }

    function profile.AdminInfo(): Typings.GroupConfig
        return Player.getAdminInfo(profile.UserId) or {}
    end

    function profile.IsAdmin(): boolean
        return Player.isAdmin(profile.UserId)
    end
    function profile.Character(): Model?
        if profile._instance then
            return profile._instance.Character or profile._instance.CharacterAppearanceLoaded:Wait()
        end

        warn("Player " .. profile.UserId .. " left already")
        return nil
    end

    function profile.Latency(): number?
        if profile._instance then
            return profile._instance:GetNetworkPing()
        end

        warn("Player " .. profile.UserId .. " left already")
        return 0
    end

    function profile:GetPackage(Id: string): {any}?
        local package: {any}? = profile.Packages[Id]
        if not package then
            warn("A script tried to require a data fetcher, but it was not found: " .. Id)
        end

        return package
    end

    for _, module: ModuleScript in ipairs(Player.Extensions.PlayerProfile) do
        local package: Typings.BasePackage = require(module)
        local status: boolean, response: string|{string: any} = pcall(package.Target.Main, profile)
        if status and typeof(response) == "table" then
            local packageTable = {}
            for index: number|string, data: any in pairs(response) do
                packageTable[index] = data
            end
            profile.Packages[package.Id] = packageTable
        else
            warn("Skipping package " .. package.Id .. " as process exited with an error: " .. response)
        end
    end

    return profile
end 
function Player.addChecker(checker: ModuleScript): boolean
    assert(type(require(checker).Target.Main) == "function", "Checker must include a function called Main inside Package.Target")
    if not table.find(Player.Extensions.Checkers, checker) then
        table.insert(Player.Extensions.Checkers, checker)
        return true
    end

    warn("Checker " .. checker:GetFullName() .. " already added")
    return false
end

function Player.addDataFetcher(fetcher: ModuleScript): boolean
    assert(type(require(fetcher).Target.Main) == "function", "Fetcher must include a function called Main inside Package.Target")
    if not table.find(Player.Extensions.DataFetchers, fetcher) then
        table.insert(Player.Extensions.DataFetchers, fetcher)
        return true
    end
    
    warn("Fetcher " .. fetcher:GetFullName() .. " already added")
    return false
end

function Player._onInit()
    Player._OnInit = nil
end

return Player