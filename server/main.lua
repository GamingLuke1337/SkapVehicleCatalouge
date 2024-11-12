local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("SkapVehicleCatalogue:server:spawnVehicle", function(model, coords, heading)
    local src = source
    local modelHash = GetHashKey(model)

    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        return
    end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    SetEntityAsMissionEntity(vehicle, true, true)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetVehicleDoorsLocked(vehicle, 2)
    SetEntityInvincible(vehicle, true)
    FreezeEntityPosition(vehicle, true)
    TriggerClientEvent("SkapVehicleCatalogue:client:syncVehicle", -1, netId)
end)
