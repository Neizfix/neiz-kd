local oldurme, olum = 0, 0
local deathRegistered = false

local function loadKD()
    TriggerServerEvent("loadKD")
end

AddEventHandler('playerSpawned', function()
    deathRegistered = false
    loadKD()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        loadKD()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        TriggerServerEvent("saveKD", oldurme, olum)
    end
end)

RegisterNetEvent("updateKD")
AddEventHandler("updateKD", function(newoldurme, newolum)
    oldurme, olum = newoldurme, newolum
    SendNUIMessage({
        type = "updateKD",
        oldurme = oldurme,
        olum = olum
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()

        if IsEntityDead(playerPed) and not deathRegistered then
            deathRegistered = true
            local killer = GetPedSourceOfDeath(playerPed)
            local killerId = killer ~= 0 and GetPlayerServerId(NetworkGetPlayerIndexFromPed(killer)) or nil
            olum = olum + 1
            TriggerServerEvent("registerDeath", killerId)

            while IsEntityDead(playerPed) do
                Citizen.Wait(1000)
            end
        elseif not IsEntityDead(playerPed) then
            deathRegistered = false
        end
    end
end)