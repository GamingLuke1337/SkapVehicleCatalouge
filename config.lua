QBCore = nil
ESX = nil
Framework = nil

Citizen.CreateThread(function()
    if GetResourceState("qb-core") == "started" then
        QBCore = exports["qb-core"]:GetCoreObject()
        Framework = "qb"
    elseif GetResourceState("es_extended") == "started" then
        ESX = exports["es_extended"]:getSharedObject()
        Framework = "esx"
    else
        print("^1[SkapVehicleCatalogue] No compatible Framework found!^7")
    end
end)

Config = {}

Config.Language = 'en' -- 'en', 'de', 'es', 'fr', 'it', 'nl', 'pt', 'ru - available languages

Config.Categories = { 
    "compacts",
    "suvs",
    "sports",
    "super",
    "sedans",
    "muscle",
    "sportsclassics",
    "Motorcyklar",
    "offroad",
    "vans",
    "cycles"
}

Config.PreviewCoords = vector4(-794.12, -218.87, 36.73, 239.71)
Config.PreviewRotationSpeed = 0.5  

Config.TargetType = 'ox'  -- 'qb', 'ox' or 'esx'
Config.NotifyType = 'ox' -- 'qb', 'ox' or 'esx'

Config.NPC = {
    model = 'a_m_m_business_01',
    coords = vector4(-302.11, -810.56, 31.75, 159.16),  
}

Config.BlacklistedCategories = {
    ["emergency"] = true,
    ["boats"] = true,
    ["planes"] = true,
    ["helicopters"] = true,
    ["service"] = true
}