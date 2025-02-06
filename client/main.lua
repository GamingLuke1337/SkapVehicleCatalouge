local previewVehicle = nil
local Vehicles = {}
local Framework = nil
local ESX, QBCore = nil, nil
local Lang = {}

Citizen.CreateThread(function()
    local localeFile = LoadResourceFile(GetCurrentResourceName(), "locales/" .. (Config.Language or "en") .. ".lua")
    
    if localeFile then
        Lang = load(localeFile)()
    else
        print("^1[SkapVehicleCatalogue] no locale found for '" .. Config.Language .. "' . Fallback to english.^7")
        Lang = load(LoadResourceFile(GetCurrentResourceName(), "locales/en.lua"))()
    end
end)

local function _L(key)
    return Lang[key] or key
end

Citizen.CreateThread(function()
    if GetResourceState("qb-core") == "started" then
        QBCore = exports["qb-core"]:GetCoreObject()
        Framework = "qb"
        Vehicles = QBCore.Shared.Vehicles
    elseif GetResourceState("es_extended") == "started" then
        ESX = exports["es_extended"]:getSharedObject()
        Framework = "esx"
        Vehicles = Config.Vehicles
    else
        print("^1[SkapVehicleCatalogue] No compatible framwork found!^7")
    end
end)

local function sendNotification(message, type)
    if Config.NotifyType == 'ox' and exports.ox_lib then
        exports.ox_lib:notify({
            title = _L("notification_title"),
            description = message,
            type = type or 'info'
        })
    elsif Config.NotifyType == 'qb' and QBCore then
        QBCore.Functions.Notify(message, type or "info")
    elseif Config.NotifyType == 'esx' and ESX then
        ESX.ShowNotification(message, type or "info")
    else
        print("[Notification] " .. message)
    end
end

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

local function spawnNPC()
    loadModel(Config.NPC.model)
    local npc = CreatePed(4, GetHashKey(Config.NPC.model), Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z, Config.NPC.coords.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    if Config.TargetType == 'qb' and exports["qb-target"] then
        exports["qb-target"]:AddTargetEntity(npc, {
            options = {
                {
                    type = "client",
                    event = "SkapVehicleCatalogue:client:showCategoriesMenu",
                    icon = "fas fa-car",
                    label = _L("open_catalogue"),
                }
            },
            distance = 2.5,
        })
    elseif Config.TargetType == 'ox' and exports.ox_target then
        exports.ox_target:addGlobalPed({
            icon = 'fas fa-car',
            label = _L("open_catalogue"),
            onSelect = function()
                TriggerEvent("SkapVehicleCatalogue:client:showCategoriesMenu")
            end,
            distance = 2.5
        })
    end
end

local function showVehicleMenu(category)
    local vehicleMenu = {}

    for _, v in pairs(Vehicles) do
        if v.category == category then
            table.insert(vehicleMenu, {
                header = v.name .. " - $" .. v.price,
                txt = _L("brand") .. ": " .. (v.brand or _L("unknown")) .. " | " .. _L("model") .. ": " .. v.model,
                params = {
                    event = "SkapVehicleCatalogue:client:previewVehicle",
                    args = {model = v.model, price = v.price, name = v.name, category = v.category}
                }
            })
        end
    end

    if #vehicleMenu > 0 then
        if Framework == "qb" then
            exports["qb-menu"]:openMenu(vehicleMenu)
        elseif Framework == "esx" then
            exports["esx_menu_default"]:Open("default", GetCurrentResourceName(), "vehicle_menu", {
                title = _L("vehicle_catalogue"),
                elements = vehicleMenu,
            }, function(data, menu)
                TriggerEvent("SkapVehicleCatalogue:client:previewVehicle", data.current.params.args)
            end, function(data, menu)
                menu.close()
            end)
        end
    else
        sendNotification(_L("no_vehicles"), "error")
    end
end

RegisterNetEvent("SkapVehicleCatalogue:client:previewVehicle", function(data)
    sendNotification(_L("preview_vehicle"):format(data.name, data.model, data.price, data.category))

    if previewVehicle then
        DeleteEntity(previewVehicle)
    end

    local model = GetHashKey(data.model)
    loadModel(model)
    
    previewVehicle = CreateVehicle(model, Config.PreviewCoords, 0.0, false, false)
    SetEntityInvincible(previewVehicle, true)
    SetEntityHeading(previewVehicle, 0.0)
    FreezeEntityPosition(previewVehicle, true)

    Citizen.CreateThread(function()
        while DoesEntityExist(previewVehicle) do
            local heading = GetEntityHeading(previewVehicle) + Config.PreviewRotationSpeed
            SetEntityHeading(previewVehicle, heading)
            Wait(0)
        end
    end)
end)

Citizen.CreateThread(function()
    Wait(1000)
    if Framework then
        spawnNPC()
    end
end)

RegisterNetEvent("SkapVehicleCatalogue:client:showCategoriesMenu", function()
    sendNotification(_L("choose_vehicle_reminder"))
    local categoriesMenu = {}

    for _, category in ipairs(Config.Categories) do
        table.insert(categoriesMenu, {
            header = category:sub(1,1):upper() .. category:sub(2),
            params = {
                event = "SkapVehicleCatalogue:client:showVehicleMenu",
                args = {category = category}
            }
        })
    end

    if Framework == "qb" then
        exports["qb-menu"]:openMenu(categoriesMenu)
    elseif Framework == "esx" then
        exports["esx_menu_default"]:Open("default", GetCurrentResourceName(), "categories_menu", {
            title = _L("vehicle_categories"),
            elements = categoriesMenu,
        }, function(data, menu)
            TriggerEvent("SkapVehicleCatalogue:client:showVehicleMenu", data.current.params.args)
        end, function(data, menu)
            menu.close()
        end)
    end
end)

RegisterNetEvent("SkapVehicleCatalogue:client:showVehicleMenu", function(data)
    showVehicleMenu(data.category)
end)
