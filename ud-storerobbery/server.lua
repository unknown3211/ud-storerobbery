local GetPlayerId

if Config.Core == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()
    GetPlayerId = function(src)
        return ESX.GetPlayerFromId(src)
    end
elseif Config.Core == 'QBCORE' then
    QBCore = exports['qb-core']:GetCoreObject()
    GetPlayerId = function(src)
        return QBCore.Functions.GetPlayer(src)
    end
else
    TriggerClientEvent('ox_lib:notify', src, {
        type = 'error',
        description = "Wrong Core Name, Please change it to 'ESX', 'QBCORE', 'UDBASE."
    }) 
    return
end

RegisterNetEvent('ud-storerobbery:RobDARegister')
AddEventHandler('ud-storerobbery:RobDARegister', function()
    local src = source
    local player = GetPlayerId(src)

    if player then
        exports.ox_inventory:AddItem(src, 'money', 2000)
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = "Register Robbed Come Back Later To Rob Again..."
        }) 
    end
end)
