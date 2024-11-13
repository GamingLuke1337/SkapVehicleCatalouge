local QBCore = exports['qb-core']:GetCoreObject()
local previewVehicle;
local vehiclesByCategory = Lib.Table.FilterByKey(QBCore.Shared.Vehicles, "category")
local categoriesMenu = {}

local openCategoryMenu = function(vehicles)
    Lib.Menu({
        id = "vehCatalogueVehicles",
        title = "Vehicles",
        options = vehicles,
    })
end

for k, v in pairs(vehiclesByCategory) do
    categoriesMenu[#categoriesMenu+1] = {
        title = k:gsub("^%l", string.upper),
        onSelect = function()
            openCategoryMenu(v)
        end,
    }
    for _, vehicle in pairs(v) do
        vehicle.title = ("%s %s - $%s"):format(vehicle.brand, vehicle.name, vehicle.price)
        vehicle.onSelect = function()

            if previewVehicle then Lib.DeleteEntity(previewVehicle) end

            previewVehicle = Lib.SpawnVehicle({
                model = vehicle.model,
                coords = Config.PreviewCoords,
                networked = true,
                plate = "PREVIEW",
            })

            CreateThread(function()
                while DoesEntityExist(previewVehicle) do
                    local heading = GetEntityHeading(previewVehicle) + Config.PreviewRotationSpeed
                    SetEntityHeading(previewVehicle, heading)
                    Wait(0)
                end
            end)

        end
    end
    table.sort(v, function(a, b)
        return (a.price or 9999999999) < (b.price or 9999999999)
    end)
end

table.sort(vehiclesByCategory)
table.sort(categoriesMenu, function(a, b)
    return a.title < b.title
end)

Lib.SpawnPed({
    model = Config.NPC.model,
    coords = Config.NPC.coords,
    freeze = true,
    blockEvents = true,
    invincible = true,
    default = true,
    targets = {
        {
            label = "Show Vehicle Catalogue",
            onSelect = function()
                Lib.Menu({
                    id = "vehCatalogueCategories",
                    title = "Vehicle Catalogue",
                    options = categoriesMenu,
                })
            end
        }
    }
})