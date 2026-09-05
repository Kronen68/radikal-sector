--Bam B.I.L.
script.on_game_event("RKS_UPGRADE_DRONES_BY_2", false, function()
	Hyperspace.ships.player:GetSystem(4):UpgradeSystem(2)
end)
script.on_game_event("RKS_UPGRADE_ENGINES_BY_2", false, function()
	Hyperspace.ships.player:GetSystem(1):UpgradeSystem(2)
end)
script.on_game_event("RKS_UPGRADE_SHIELDS_BY_2", false, function()
	Hyperspace.ships.player:GetSystem(0):UpgradeSystem(2)
end)
script.on_game_event("RKS_UPGRADE_WEAPONS_BY_2", false, function()
	Hyperspace.ships.player:GetSystem(3):UpgradeSystem(2)
end)
--[[  REFS: Arc's The Outer Expansion v7.1.10 for MV v5.5.1:
script.on_game_event("INSTALL_AEA_OLD_SHIELDS", false, function()
	Hyperspace.ships.player:GetSystem(0):UpgradeSystem(1)
end) 

This would be necessary to fix "Engines 9 and 10 give 0 evasion",
but the effect would be duplicated if Outer Expansion is installed!:

script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(shipManager, value)
	if shipManager:HasSystem(1) then
		local engine = shipManager:GetSystem(1)
		if engine:GetEffectivePower() >= 9 then
			local powerExtra = engine:GetEffectivePower() - 8
			local pilot = shipManager:GetSystem(6)
			if pilot.bManned then
				value = value + 35 + (5 * powerExtra)
			elseif pilot.powerState.first == 2 then
				value = value + ((35 + (5 * powerExtra)) * 0.5)
			elseif pilot.powerState.first == 3 then
				value = value + ((35 + (5 * powerExtra)) * 0.8)
			end
		end
	end
	return Defines.Chain.CONTINUE, value
end)
]]
script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(shipManager, value)
	if mods.aea then		--Arc's The Outer Expansion ( = the reference) is already doing it.
		return Defines.Chain.CONTINUE, value
	end

	if shipManager:HasSystem(1) then
		local engine = shipManager:GetSystem(1)
		if engine:GetEffectivePower() >= 9 then
			local powerExtra = engine:GetEffectivePower() - 8
			local pilot = shipManager:GetSystem(6)
			if pilot.bManned then
				value = value + 35 + (5 * powerExtra)
			elseif pilot.powerState.first == 2 then
				value = value + ((35 + (5 * powerExtra)) * 0.5)
			elseif pilot.powerState.first == 3 then
				value = value + ((35 + (5 * powerExtra)) * 0.8)
			end
		end
	end
	return Defines.Chain.CONTINUE, value
end)



--Scorch B.I.L.
script.on_game_event("RKS_UPGRADE_REACTOR_BY_5", false, function()
	local powerManager = Hyperspace.PowerManager.GetPowerManager(0)
	powerManager.currentPower.second = powerManager.currentPower.second + 5
end)
--[[ REF: Arc's The Outer Expansion v7.1.10 for MV v5.5.1:

script.on_game_event("INSTALL_AEA_OLD_REACTOR", false, function()
	local powerManager = Hyperspace.PowerManager.GetPowerManager(0)
	powerManager.currentPower.second = powerManager.currentPower.second + 1
end) ]]