local RSGCore = exports['rsg-core']:GetCoreObject()
local Config = require "shared.config"
local DAMAGE_MODIFIER = {}
local WEAPON_NAME = {}
local CRITICAL_HIT = {}

for k,v in ipairs(Config.weaponDamage) do
    DAMAGE_MODIFIER[GetHashKey(v.Name)] = v.Damage
    WEAPON_NAME[GetHashKey(v.Name)] = v.Name
    CRITICAL_HIT[GetHashKey(v.Name)] = v.EnableCritical
end

local getWeaponStats = function(weaponHash)
    local emptyStruct = DataView.ArrayBuffer(256)
    local charStruct = DataView.ArrayBuffer(256)
    Citizen.InvokeNative(0x886DFD3E185C8A89, 1, emptyStruct:Buffer(), joaat("CHARACTER"), -1591664384, charStruct:Buffer())

    local unkStruct = DataView.ArrayBuffer(256)
    Citizen.InvokeNative(0x886DFD3E185C8A89, 1, charStruct:Buffer(), 923904168, -740156546, unkStruct:Buffer())

    local weaponStruct = DataView.ArrayBuffer(256)
    Citizen.InvokeNative(0x886DFD3E185C8A89, 1, unkStruct:Buffer(), weaponHash, -1591664384, weaponStruct:Buffer())
    return weaponStruct:Buffer()
end

local showstats = function()
    local _, weapon = GetCurrentPedWeapon(cache.ped, true, 0, true)
    if weapon then
        local uiFlowBlock = RequestFlowBlock(joaat("PM_FLOW_WEAPON_INSPECT"))
        local uiContainer = DatabindingAddDataContainerFromPath("" , "ItemInspection")
        Citizen.InvokeNative(0x46DB71883EE9D5AF, uiContainer, "stats", getWeaponStats(weapon), cache.ped)
        DatabindingAddDataString(uiContainer, "tipText", 'Weapon Information')
        DatabindingAddDataHash(uiContainer, "itemLabel", weapon)
        DatabindingAddDataBool(uiContainer, "Visible", true)

        Citizen.InvokeNative(0x10A93C057B6BD944, uiFlowBlock)
        Citizen.InvokeNative(0x3B7519720C9DCB45, uiFlowBlock, 0)
        Citizen.InvokeNative(0x4C6F2C4B7A03A266, -813354801, uiFlowBlock)
    end
end

RegisterNetEvent("gm_weaponcomp:client:inspectWeapon", function()
    local retval, weaponHash = GetCurrentPedWeapon(cache.ped, true, 0, true)
    local interaction = "LONGARM_HOLD_ENTER"
    local act = joaat("LONGARM_CLEAN_ENTER")
    local object = GetObjectIndexFromEntityIndex(GetCurrentPedWeaponEntityIndex(cache.ped,0))
    local cleaning = false
    Citizen.InvokeNative(0xCB9401F918CB0F75, cache.ped, "GENERIC_WEAPON_CLEAN_PROMPT_AVAILABLE", true, -1)
    if Citizen.InvokeNative(0xD955FEE4B87AFA07,weaponHash) then
        interaction = "SHORTARM_HOLD_ENTER"
        act = joaat("SHORTARM_CLEAN_ENTER")
    end
    if weaponHash ~= -1569615261 then
        TaskItemInteraction(cache.ped, weaponHash, joaat(interaction), 0,0,0)
        showstats()
        while not Citizen.InvokeNative(0xEC7E480FF8BD0BED,cache.ped) do
            Wait(300)
        end
        while Citizen.InvokeNative(0xEC7E480FF8BD0BED,cache.ped) do
            Wait(1)
            if IsDisabledControlJustReleased(0,3002300392) then
                ClearPedTasks(cache.ped,1,1)
                Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)
            end
            if IsDisabledControlJustReleased(0,3820983707) and not cleaning then
                cleaning = true
                local Cloth= CreateObject(joaat('s_balledragcloth01x'), GetEntityCoords(cache.ped), false, true, false, false, true)
                local PropId = joaat("CLOTH")
                Citizen.InvokeNative(0x72F52AA2D2B172CC,  cache.ped, 1242464081, Cloth, PropId, act, 1, 0, -1.0)
                Wait(9500)
                ClearPedTasks(cache.ped,1,1)
                Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)
                Citizen.InvokeNative(0xA7A57E89E965D839,object,0.0,0)
                Citizen.InvokeNative(0x812CE61DEBCAB948,object,0.0,0)
                break
            end
        end
        Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)
    end
end)

RegisterNetEvent("gm_weaponcomp:client:repairweapon", function()
    local ped = cache.ped
    local heldWeapon = Citizen.InvokeNative(0x8425C5F057012DAB, ped)

    if heldWeapon ~= nil and heldWeapon ~= -1569615261 then
        local animDict = nil
        local animName = nil
        local weapon = exports.gm_inventory:getCurrentWeapon()
        local weaponGroup = GetWeapontypeGroup(weapon.hash)

        if weaponGroup == 970310034 or weaponGroup == -594562071 or weaponGroup == 860033945 or weaponGroup == -1212426201 then
            animDict = "MECH_INSPECTION@WEAPONS@LONGARMS@CARBINE@BASE"
            animName = "clean_loop"
        else
            animDict = "MECH_INSPECTION@WEAPONS@SHORTARMS@CATTLEMAN@BASE"
            animName = "clean_loop"
        end

        RequestAnimDict(animDict)
        local timeout = 1000
        while not HasAnimDictLoaded(animDict) and timeout > 0 do
            Citizen.Wait(100)
            timeout = timeout - 100
        end

        if HasAnimDictLoaded(animDict) then
            -- print("[DEBUG] Animation dictionary loaded successfully: " .. animDict)
            TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 31, 0, false, false, false)
        else
            print("[DEBUG] Failed to load animation dictionary: " .. animDict .. ". Falling back to no animation.")
        end

        if lib.progressBar({
            duration = Config.weaponRepairTime,
            label = 'Repairing Weapon',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, combat = true },
        }) then
            ClearPedTasks(ped)
            TriggerServerEvent("gm_weaponcomp:server:repairWeapon")
        else
            ClearPedTasks(ped)
        end
    else
        print("[DEBUG] No valid weapon held. Held weapon hash: " .. tostring(heldWeapon))
    end
end)

CreateThread(function()
	while true do
		Wait(500)
		local ped = cache.ped
		local _, wep = GetCurrentPedWeapon(ped)
		if DAMAGE_MODIFIER[wep] ~= nil then
			Citizen.InvokeNative(0xD77AE48611B7B10A, ped, DAMAGE_MODIFIER[wep])
		else
			Citizen.InvokeNative(0xD77AE48611B7B10A, ped, 1.0)
		end
	end
end)

CreateThread(function()
    while true do
        local ped = cache.ped
        local _, wep = GetCurrentPedWeapon(ped)

		for k,v in ipairs(GetActivePlayers()) do
			local ped = GetPlayerPed(v)
			local noCriticalHit = CRITICAL_HIT[wep] == false
			SetPedConfigFlag(ped, 340, noCriticalHit) -- No Melee Finish
			SetPedConfigFlag(ped, 388, noCriticalHit) -- Disable Fatally Wounded Behaviour (From bullets)
		end

        Wait(1000)
    end
end)