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