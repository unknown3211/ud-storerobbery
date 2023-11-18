local isGunOnPed = false
-- local camId = 1 -- Uncomment If Using ps-dispatch
registerCooldowns = {}

Citizen.CreateThread(function()
    local handsUp = false

    while true do
        Citizen.Wait(0)

        local ped = GetPlayerPed(-1)
        local isAiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

        if isAiming and DoesEntityExist(entity) and IsEntityAPed(entity) and not IsPedAPlayer(entity) and GetEntityModel(entity) == GetHashKey('mp_m_shopkeep_01') then
            if not handsUp then
                TaskHandsUp(entity, -1, ped, -1, true)
                handsUp = true
                isGunOnPed = true
            end
        else
            if handsUp then
                ClearPedTasks(entity)
                handsUp = false
            end
            
            if isGunOnPed then
                isGunOnPed = false
                -- DispatchStoreRobbery()
            end
        end
    end
end)

function DispatchStoreRobbery()
    -- ADD DISPATCH EXPORT HERE AND UNCHECK THE DispatchStoreRobbery() and local camId -- exmaple below for ps-dispatch
    -- exports['ps-dispatch']:StoreRobbery(camId)
end

RegisterNetEvent('ud-storerobbery:robthefuckingstore')
AddEventHandler('ud-storerobbery:robthefuckingstore', function()
    local isNearRegister = false
    local playerCoords = GetEntityCoords(PlayerPedId())

    for index, registerCoords in pairs(Config.Registers) do
        if #(playerCoords - registerCoords) < (Config.RegisterRadius + 1.0) then
            local lastRobbed = registerCooldowns[index] or 0
            local time = GetGameTimer() / 1000

            if (time - lastRobbed) < Config.Cooldown then
                lib.notify({type = 'error', description = "This register is on cooldown !"})
                return
            end

            isNearRegister = true
            exports['ps-ui']:Circle(function(success)
                if success then
                    local dict = "oddjobs@shop_robbery@rob_till"
                    local anim = "loop"

                    RequestAnimDict(dict)
                    while not HasAnimDictLoaded(dict) do
                        Citizen.Wait(50)
                    end

                    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

                    TriggerServerEvent('ud-storerobbery:RobDARegister')
                    registerCooldowns[index] = time
                else
                    lib.notify({type = 'error', description = "You failed the robbery !"})
                    -- DispatchStoreRobbery()
                end
            end, 2, 20) -- NumberOfCircles, MS

            break
        end
    end

    if not isNearRegister then
        lib.notify({type = 'error', description = "Not near a register !"}) 
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local isInRobberyZone = false

        for index, registerCoords in pairs(Config.Registers) do
            local distance = #(playerCoords - registerCoords)

            if distance < Config.RegisterRadius then
                isInRobberyZone = true

                exports['ox_lib']:showTextUI('[E] - Rob Store', {
                    position = "top-center",
                    icon = 'fa-solid fa-circle',
                    style = {
                        borderRadius = 0,
                        backgroundColor = '#ff0000',
                        color = 'white'
                    }
                })

                if IsControlJustReleased(0, 38) then
                    TriggerEvent('ud-storerobbery:robthefuckingstore')
                    break
                end
            end
        end

        if not isInRobberyZone then
            exports['ox_lib']:hideTextUI()
        end
    end
end)