export type MainConfig = {
    Administration: {
        Users: {
            {Type: string, -- Type of UserEntry
            Value: string, -- Value that accepts
            Group: string} -- Which group it belongs to
        },
        Groups: {
            {Id: string, -- Special identifier for the group, must not have space or any symbols
            Name: string, -- Name for the group
            Commands: string|{string}} -- Commands allowed to use, "*" for all commands
        },
        CommandFeatures: {any}, -- Additional configuration for a specific command
    },

    Interface: {
        Toggle: {Keybind: Enum},
        Appearance: {
            DefaultTheme: {
                Light: string,
                Dark: string
            },
            DefaultScheme: string
        }
    },

    Misc: {
        DataStoreKey: string,
        MaxLogs: number,
        Debugging: boolean,
        GlobAPI: {
            Enabled: boolean,
            Key: string
        }
    }
}

export type RemoteBody = {
    Method: string, -- The method (what are you calling)
    Attachment: {any}? -- Attachment for that menthod
}

export type BasePackage = {
    Name: string, -- Name of package
    Id: string, -- Unique identifier of package, must not include space or symbols
    Description: string?, -- Description of package, optional
    Category: string, -- Category of the package, usable for commands
    Type: string, -- Type of the package: Commands/Extensions/Stylesheets
    Container: {any} -- Container for the package, can store functions or data for that package
}

local module = {}

return module