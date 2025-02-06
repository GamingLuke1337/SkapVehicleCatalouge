QBCore = exports['qb-core']:GetCoreObject()

Config = {}

Config.Categories = { -- Put all your categories here, 
    "compacts", --1
    "suvs", --2
    "sports", --3
    "super", --4
    "sedans", --5
    "muscle", --6
    "sportsclassics", --7
    "Motorcyklar", --8
    "offroad", --9
    "vans", --10
    "cycles", --11
}

Config.PreviewCoords = vector4(-794.12, -218.87, 36.73, 239.71)  -- Where the preview vehicle will spawn (THIS IS NOT SYNCED WITH ALL THE PLAYERS YET. IT'S ONLY SYNCED FOR YOU)
Config.PreviewRotationSpeed = 0.5  

Config.TargetType = 'ox'  -- 'qb' 'ox'
Config.NotifyType = 'qb' -- 'qb' 'ox'

Config.NPC = {
    model = 'a_m_m_business_01', -- Preview ped
    coords = vector4(-302.11, -810.56, 31.75, 159.16),  
}

Config.BlacklistedCategories = { -- Add those categories you want to be blacklisted from the vehicle catalouge!
    ["emergency"] = true,
    ["boats"] = true,
    ["planes"] = true,
    ["helicopters"] = true,
    ["service"] = true
}