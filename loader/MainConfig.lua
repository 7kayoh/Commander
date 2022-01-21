-- MainConfig.lua
-- Design by hiyorisaka & 7kayoh
-- Jan 16, 2022

-- Module code
local Module = {}

Module.Administration = {
    Users = {
        {Type = "UserId", Value = "87924253", Group = "Owner"},
        {Type = "Group", Value = "9719847>=255", Group = "Moderator"},
        {Type = "Name", Value = "7kayoh", Group = "Owner"}
    },

    Groups = {
        -- Priority are based on the list index, top one == greatest priority
        {
            Id = "Owner", -- Id must not include space or symbols
            Name = "Game Owner",
            Commands = "*"
        },
        {
            Id = "Moderator",
            Name = "Moderator",
            Commands = {"Ban", "TempBan", "Unban", "Kick", "Warn", "DM"}
        }
    },

    CommandFeatures = {
        -- This is for if a command has special configuration
        Banning = {
            BannedUser = {
                {Type = "UserId", Value = "1"} -- Basically the same as AdminUserEntry, but without the Group value
            },
            DefaultTempBanDuration = 360, -- Counted in minutes, 360 minutes = 6 hours
            DataStoreKey = "bans" -- Commander's DS key concatenate with this DS key
        }
    }
}

Module.Interface = {
    Toggle = {
        Keybind = Enum.KeyCode.Semicolon,
        -- Custom toggle planned in the future?
    },
    
    Appearance = {
        DefaultTheme = {Light = "Minimal", Dark = "MinimalDark"},
        DefaultScheme = "Teal" -- Follows the Material Colors code
    }
}

Module.Misc = {
    DataStoreKey = "commander",
    CacheTimeout = 3600, -- Cache clears out per hour, by default
    MaxLogs = 2000,
    Debugging = true,
    GlobAPI = {
        Enabled = true,
        Token = "1024"
    }
}

return Module