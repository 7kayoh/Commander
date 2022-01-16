export type MainConfig = {
    Administration: {
        Users: {
            {Type: string,
            Value: string,
            Group: string}
        },
        Groups: {
            {Id: string,
            Name: string,
            Commands: string|{string}}
        },
        CommandFeatures: {any}, -- Honestly, we do not know what will be in there
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

local module = {}

return module