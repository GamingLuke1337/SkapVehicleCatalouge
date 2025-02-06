local previewVehicle = nil
local Vehicles = {}

Citizen.CreateThread(function()
    Vehicles = QBCore.Shared.Vehicles
end)

local function sendNotification(message, type)
    if Config.NotifyType == 'qb' then
        sendNotification(message, type or 'info')
    elseif Config.NotifyType == 'ox' then
        exports.ox_lib:notify({
            title = 'Notification',
            description = message,
            type = type or 'info'
        })
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

    if Config.TargetType == 'qb' then
        exports['qb-target']:AddTargetEntity(npc, {
            options = {
                {
                    type = "client",
                    event = "SkapVehicleCatalogue:client:showCategoriesMenu",
                    icon = "fas fa-car",
                    label = "Open Catalogue",
                }
            },
            distance = 2.5,
        })
    elseif Config.TargetType == 'ox' then
        exports.ox_target:addGlobalPed({
            icon = 'fas fa-car',
            label = "Open Catalogue",
            onSelect = function()
                TriggerEvent("SkapVehicleCatalogue:client:showCategoriesMenu")
            end,
            distance = 2.5
        })
    end
end

local function showVehicleMenu(category)
    local vehicleMenu = {}
    for _, v in pairs(Config.Vehicles) do
        if v.category == category then
            table.insert(vehicleMenu, {
                header = v.name .. " - $" .. v.price,
                txt = "Brand: " .. (v.brand or "Unkown") .. " | Model: " .. v.model,
                params = {
                    event = "SkapVehicleCatalogue:client:previewVehicle",
                    args = {model = v.model, price = v.price, name = v.name, category = v.category}
                }
            })
        end
    end
    if #vehicleMenu > 0 then
        exports['qb-menu']:openMenu(vehicleMenu)
    else
        QBCore.Functions.Notify("No vehicles were found in this category.", "error")
    end
end

RegisterNetEvent("SkapVehicleCatalogue:client:previewVehicle", function(data)
    sendNotification("Vehicle: " .. data.name .. " - Model: " .. data.model .. " - Price: " .. data.price .. " - Category: " .. data.category)

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
    spawnNPC()
end)

RegisterNetEvent("SkapVehicleCatalogue:client:showCategoriesMenu", function()
    sendNotification("When you choose a vehicle, remember the name of it so the car dealer can give you the right vehicle!")
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
    exports['qb-menu']:openMenu(categoriesMenu)
end)

RegisterNetEvent("SkapVehicleCatalogue:client:showVehicleMenu", function(data)
    category = data.category
    showVehicleMenu(category)
end)
