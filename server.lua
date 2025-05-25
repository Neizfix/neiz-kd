local oxmysql = exports['oxmysql']


local function getIdentifier(playerId)
    for _, idType in ipairs({'steam', 'license', 'fivem'}) do
        local identifier = GetPlayerIdentifier(playerId, 0)
        if identifier then
            return identifier
        end
    end
    return nil
end
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
    local identifier = getIdentifier(playerId)
    if not identifier then return end

    getPlayerData(identifier, function(data)
        TriggerClientEvent("updateKD", playerId, data.oldurme or 0, data.olum or 0)
    end)
end)

RegisterServerEvent("registerDeath")
AddEventHandler("registerDeath", function(killerId)
    local victimId = source
    local victimIdentifier = getIdentifier(victimId)
    if victimIdentifier then
        getPlayerData(victimIdentifier, function(data)
            local newOlum = (data.olum or 0) + 1
            oxmysql:execute('UPDATE kd_stats SET olum = ? WHERE identifier = ?', {newOlum, victimIdentifier})
            TriggerClientEvent("updateKD", victimId, data.oldurme or 0, newOlum)
        end)
    end
    if killerId and killerId ~= victimId then
        local killerIdentifier = getIdentifier(killerId)
        if killerIdentifier then
            getPlayerData(killerIdentifier, function(data)
                local newOldurme = (data.oldurme or 0) + 1
                oxmysql:execute('UPDATE kd_stats SET oldurme = ? WHERE identifier = ?', {newOldurme, killerIdentifier})
                TriggerClientEvent("updateKD", killerId, newOldurme, data.olum or 0)
            end)
        end
    end
end)

RegisterServerEvent("saveKD")
AddEventHandler("saveKD", function(oldurme, olum)
    local playerId = source
    local identifier = getIdentifier(playerId)
    if not identifier then return end

    oxmysql:execute('UPDATE kd_stats SET oldurme = ?, olum = ? WHERE identifier = ?', {oldurme, olum, identifier})
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local playerId = source
    local identifier = getIdentifier(playerId)
    if not identifier then return end

    getPlayerData(identifier, function(data)
        TriggerClientEvent("updateKD", playerId, data.oldurme or 0, data.olum or 0)
    end)
end)
