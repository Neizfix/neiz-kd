local oldurme, olum = 0, 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
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

AddEventHandler("baseevents:onPlayerDied", function()
    olum = olum + 1
    TriggerServerEvent("playerDied")
end)

AddEventHandler("baseevents:onPlayerKilled", function(killerId)
    if killerId and killerId ~= -1 then
        oldurme = oldurme + 1
        TriggerServerEvent("playerKilled", killerId)
    end
end)

AddEventHandler("playerSpawned", function()
    TriggerServerEvent("loadKD")
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent("loadKD")
    end
end)
