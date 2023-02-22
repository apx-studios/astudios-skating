Config = {}
Config.Debug = false -- True / False for Debug System

Config.Framework = "qb" -- Pick your framework: "qb" or "esx" - Default: "qb"

-- Notifications
Config.NotificationType = { -- 'qbcore' / 'esx' / 'astudios' / 'okok' Choose your notification script.
    server = 'astudios',
    client = 'astudios' 
}

-- Settings
Config.ItemName = 'skateboard'
Config.MaxSpeedKmh = 40 -- This does not really change that much unless you get a boost somehow.
Config.maxJumpHeigh = 5.0 -- We suggest not to mess to much with this (And yes, you can jump very high).
Config.LoseConnectionDistance = 2.0 -- This is the distance from you to the skateboard (Don't mess with this, unless you know, what you are doing).

Config.Language = {
    Info = {
        ['controls'] = 'Press E to remove | Press G to jump on',
    }
}
