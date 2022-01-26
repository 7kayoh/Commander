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

function SocialKit.getTextFilter(message: string, from: number): TextFilterResult?
    return TextService:FilterStringAsync(message, from)
end

function SocialKit.canUserChat(user: number): boolean?
    return Chat:CanUserChatAsync(user)
end

function SocialKit.filterChat(message: string, from: number, to: number): string?
    local status, result = pcall(SocialKit.canUserChat(to))
    if not status or not result then
        error("This user (" .. to .. ") can not chat")
    end

    status, result = pcall(SocialKit.getTextFilter(message, from))
    if status then
        return result:GetChatForUserAsync(result, to)
    end

    error(result)
end

function SocialKit.filterBroadcast(message: string, from: number): string?
    local status, result = pcall(SocialKit.getTextFilter(message, from))
    if status then
        return result:GetNonChatStringForBroadcastAsync(result)
    end
    
    error(result)
end

function SocialKit.isUserSafeChat(user: Player): boolean?
    -- this is an approximate way to determine whether the user is within the
    -- age group for SafeChat, and should only be used for verification only
    local status, result = pcall(PolicyService:GetPolicyInfoForPlayerAsync(user))

    if status then
        return not table.find(result, "Discord") and not result.IsSubjectToChinaPolices
    else
        error(result)
    end
end

function SocialKit.getUserRegion(user: Player): {string}?
    local status, result = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, user)
    if status then
        return {result, CountryCodes[result]}
    else
        error(status)
    end
end

return SocialKit
