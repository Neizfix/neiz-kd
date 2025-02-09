local oxmysql = exports['oxmysql']

function getPlayerData(identifier, callback)
    oxmysql:execute('SELECT * FROM kd_stats WHERE identifier = ?', {identifier}, function(result)
        if result and #result > 0 then
            callback(result[1])
        else
            oxmysql:execute('INSERT INTO kd_stats (identifier, oldurme, olum) VALUES (?, 0, 0)', {identifier})
            callback({identifier = identifier, oldurme = 0, olum = 0})
        end
    end)
end

RegisterServerEvent("loadKD")
AddEventHandler("loadKD", function()
    local playerId = source
    if not playerId then return end
    local identifier = GetPlayerIdentifier(playerId)

    getPlayerData(identifier, function(data)
        TriggerClientEvent("updateKD", playerId, data.oldurme, data.olum)
    end)
end)

RegisterServerEvent("playerDied")
AddEventHandler("playerDied", function()
    local playerId = source
    if not playerId then return end
    local identifier = GetPlayerIdentifier(playerId)

    getPlayerData(identifier, function(data)
        local newOlum = data.olum + 1
        oxmysql:execute('UPDATE kd_stats SET olum = ? WHERE identifier = ?', {newOlum, identifier})
        TriggerClientEvent("updateKD", playerId, data.oldurme, newOlum)
    end)
end)

RegisterServerEvent("playerKilled")
AddEventHandler("playerKilled", function(killerId)
    if not killerId then return end
    local identifier = GetPlayerIdentifier(killerId)

    getPlayerData(identifier, function(data)
        local newOldurme = data.oldurme + 1
        oxmysql:execute('UPDATE kd_stats SET oldurme = ? WHERE identifier = ?', {newOldurme, identifier})
        TriggerClientEvent("updateKD", killerId, newOldurme, data.olum)
    end)
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local playerId = source
    local identifier = GetPlayerIdentifier(playerId)

    getPlayerData(identifier, function(data)
        TriggerClientEvent("updateKD", playerId, data.oldurme, data.olum)
    end)
end)
