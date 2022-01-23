-- SocialKit.lua
-- 7kayoh
-- Jan 23, 2022

local Chat = game:GetService("Chat")
local TextService = game:GetService("TextService")
local PolicyService = game:GetService("PolicyService")
local LocalizationService = game:GetService("LocalizationService")

local SharedAssets = require(script.Parent.Parent.Shared)
local CountryCodes = require(script.CountryCodes)
local pcall = require(SharedAssets.pcall)

local SocialKit = {}

function SocialKit.getTextFilter(message: string, from: number): (boolean, TextFilterResult|string)
    return pcall(TextService.FilterStringAsync, TextService, message, from)
end

function SocialKit.canUserChat(user: number): (boolean, boolean|string)
    return pcall(Chat.CanUserChatAsync, user)
end

function SocialKit.filterChat(message: string, from: number, to: number): (boolean, string)
    local status, result = SocialKit.canUserChat(to)
    if not status or not result then
        return false, "This user (" .. to .. ") can not chat"
    end

    status, result = SocialKit.getTextFilter(message, from)
    if status then
        return pcall(result.GetChatForUserAsync, result, to)
    end

    return status, result
end

function SocialKit.filterBroadcast(message: string, from: number): (boolean, string)
    local status, result = SocialKit.getTextFilter(message, from)
    if status then
        return pcall(result.GetNonChatStringForBroadcastAsync, result)
    end
    
    return status, result
end

function SocialKit.isUserSafeChat(user: Player): (boolean, boolean|string)
    -- this is an approximate way to determine whether the user is within the
    -- age group for SafeChat, and should only be used for verification only
    local status, result = pcall(PolicyService:GetPolicyInfoForPlayerAsync(user))

    if status then
        return status, (not table.find(result, "Discord") and not result.IsSubjectToChinaPolices)
    else
        return status, result
    end
end

function SocialKit.getUserRegion(user: Player): (boolean, string|{string})
    local status, result = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, user)
    if status then
        result = {result, CountryCodes[result]}
    end

    return status, result
end

return SocialKit
