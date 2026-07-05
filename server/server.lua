local RSGCore = exports['rsg-core']:GetCoreObject()
local Config = require "shared.config"

RSGCore.Functions.CreateUseableItem(Config.itemForCleaning, function(source)
    TriggerClientEvent("gm_weaponcomp:client:inspectWeapon", source)
end)

RSGCore.Functions.CreateUseableItem(Config.itemForRepair, function(source)
    TriggerClientEvent("gm_weaponcomp:client:repairweapon", source)
    exports.gm_inventory:RemoveItem(source, Config.itemForRepair, 1)
end)

RegisterNetEvent("gm_weaponcomp:server:repairWeapon", function()
    local src = source
    local weapon = exports.gm_inventory:GetCurrentWeapon(src)

    if weapon then
        exports.gm_inventory:SetDurability(src, weapon.slot, 100)

        local Player = RSGCore.Functions.GetPlayer(src)
        local cid = Player and Player.PlayerData.citizenid or "unknown"
        TriggerEvent('rsg-log:server:CreateLog', 'weaponcomp', 'Weapon Repaired', 'green',
            ("**Player**: %s (%s)\n**Weapon**: %s\n**Slot**: %s\n**Durability**: 100"):format(
                GetPlayerName(src), cid, tostring(weapon.name), tostring(weapon.slot)
            )
        )
    end
end)

RegisterNetEvent('gm_weapons:server:RemoveThrowable', function(hash)
    local RemoveItem = exports.gm_inventory:RemoveItem(source, hash, 1)
end)

RegisterNetEvent('gm_weapons:server:SetDurability', function()
    local weapon = exports.gm_inventory:GetCurrentWeapon(source)
    if not weapon or not weapon.name then
        return
    end

    if weapon.name == 'WEAPON_LASSO' then
        local dur = (weapon.metadata and weapon.metadata.durability or 100) - 2
        exports.gm_inventory:SetDurability(source, weapon.slot, dur)
    end
end)
