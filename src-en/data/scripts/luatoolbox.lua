-- This is not to be added in the hyperspace.xml, so it should do nothing.
-- Meant to keep a trace of code i could use in the future.

--[[ DOCUMENTATION / LITERATURE / etc:
https://www.lua.org/pil/8.4.html
https://www.lua.org/pil/3.3.html

]]

-- Lua projectile types. From github FTL-Hyperspace//lua//modules//hyperspace.i

Projectile::GetType; // gets projectile type: 1 = laser, 2 = asteroid, 3 = missile, 4 = bomb, 5 = beam, 6 = asb

-- Lua Damage Types
damage.iDamage       = 0
damage.iSystemDamage = 0
damage.iIonDamage    = 0
damage.iPersDamage   = 0
damage.fireChance    = 0
damage.breachChance  = 0
damage.stunChance    = 0
secondDamage.iStun = 4          --Found in Lizzard's Variety's AoE stun code.


local table_to_list_string = mods.multiverse.table_to_list_string


function chal_jumped_away() -- The file this is in actually contains ALL of the addon's Lua.

    -- REF ARS+ challenges, challenge "Queen Bee to keep alive" aka "gusq".
    playerShip:AddCrewMemberFromString(Hyperspace.Text:GetText('lua_name_gusq'), "gusq", false, -1, false, false)
    if Hyperspace.metaVariables['challenge_nogus'] == 1 then
        if count_of_gusq_on_player_ship() == 0 then
            Hyperspace.metaVariables['challenge_nogus'] = 0
        elseif playerShip.currentScrap > 0 then
            playerShip:ModifyScrapCount(-1, false)
            -- Similar
            playerShip:ModifyDroneCount(-99999)
			playerShip:ModifyMissileCount(-99999)
        end
    end

    -- REF ARS+ challenges, challenge "crew loses all skills every jump".
    if Hyperspace.metaVariables['challenge_nobrain'] == 1 then
        --print('aa')
        for crew in vter(playerShip.vCrewList) do
            if crew.intruder == false then
                crew:SetSkillProgress(0, 0)
                crew:SetSkillProgress(1, 0)
                crew:SetSkillProgress(2, 0)
                crew:SetSkillProgress(3, 0)
                crew:SetSkillProgress(4, 0)
                crew:SetSkillProgress(5, 0)
            end
        end
    end

    -- This is already a bit RK edited, revert to source.
    if playerShip and playerShip.bJumping == true then
        if Hyperspace.metaVariables['challenge_nobuh'] == 1 then
            add_to_LaunchOrder("ADD_WOF_STACK_Q") --check
            print('add')
        end
    end
end
script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, chal_jumped_away)


--[[ REF: ARS+ challenges for MV v5.5.1
Lua can defer to XML for adding/removing hidden augments. See RK Weapons On Fire for pure Lua removal!

<event name="ADD_DRUNK_CREWQ">
	<queueEvent>ADD_DRUNK_CREW</queueEvent>
</event>
<event name="ADD_DRUNK_CREW">
	<hiddenAug>DRUNK_CREW</hiddenAug>
	<!--<variable name="installed_DRUNK_CREW" op="set" val="1"/-->
</event>

<event name="UPDATE_CARGO_SLOT_Q"><!-- 1.35 --> <!-- for no cargo challenge -->
	<queueEvent>UPDATE_CARGO_SLOT1</queueEvent>
</event>
<event name="UPDATE_CARGO_SLOT1"><!-- 1.35 -->
	<remove name="HIDDEN CARGO_SLOT"/>
	<queueEvent>UPDATE_CARGO_SLOT2</queueEvent>
</event>
<event name="UPDATE_CARGO_SLOT2"><!-- 1.35 -->
	<remove name="HIDDEN CARGO_SLOT"/>
	<queueEvent>UPDATE_CARGO_SLOT3</queueEvent>
</event>
<event name="UPDATE_CARGO_SLOT3"><!-- 1.35 -->
	<hiddenAug>CARGO_SLOT</hiddenAug>
</event> ]]

    --[[ Aleev technique
    if stackAugCount > 0 then
        for key, value in pairs(t) do
            add_to_LaunchOrder("REMOVE_WOF_STACK_Q") --check
            print('removed stack on jump')    
        end
    end ]]

    --Aleev technique
    --Add_to_LaunchOrder("REMOVE_WOF_STACK_Q") -- Was happening even at 0 stacks. WORKS NOW?

-- REF: codyfun's InExAUg aka "Internalize any augment"
local extAugCount = player:GetAugmentationCount()
player:AddAugmentation("HIDDEN " .. augName)    -- Probably outdated. "HIDDEN " should now only be for removal.
player:RemoveAugmentation(augName)      -- ... and this should be: player:RemoveAugmentation("HIDDEN " .. augName)

-- -REF Pepper's NoConsole's augment_button
ship:AddAugmentation(augId)
notifyOperation("Augment " .. tostring(item.id) .. " was added")

--REF: Lily's Beam Emporium, to find the OTHER SHIP
local shipManager = Hyperspace.ships(projectile.ownerId)
local otherShipManager = Hyperspace.ships(1 - projectile.ownerId)

-- REF: Lizzard's Variety, to find the OTHER SHIP:
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
    local weaponName = nil
    pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)
    local otherShip = Hyperspace.Global.GetInstance():GetShipManager((shipManager.iShipId + 1)%2)
    if otherShip:HasAugmentation("LV_IONIZATOR") > 0 then
        -- ...
    end


-- REF: The Outer Expansion's aea_dark_justicier.lua
--Transform Race
local function transformStatBoost(eliteName)
	local transformRace = Hyperspace.StatBoostDefinition()
	transformRace.stat = Hyperspace.CrewStat.TRANSFORM_RACE
	transformRace.stringValue = eliteName
	transformRace.value = true
	transformRace.cloneClear = false
	transformRace.jumpClear = false
	transformRace.boostType = Hyperspace.StatBoostDefinition.BoostType.SET
	transformRace.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
	transformRace.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
	transformRace.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
	transformRace:GiveId()
	return transformRace
end
--
mods.aea.crewToElite = {}
local crewToElite = mods.aea.crewToElite
crewToElite["human"] = transformStatBoost("human_soldier")
crewToElite["human_engineer"] = transformStatBoost("human_technician")
crewToElite["human_soldier"] = transformStatBoost("human_mfk")
crewToElite["human_mfk"] = transformStatBoost("human_legion")
crewToElite["engi"] = transformStatBoost("engi_defender")
crewToElite["zoltan"] = transformStatBoost("zoltan_peacekeeper")
crewToElite["zoltan_devotee"] = transformStatBoost("zoltan_martyr")
crewToElite["mantis"] = transformStatBoost("mantis_suzerain")
crewToElite["mantis_suzerain"] = transformStatBoost("mantis_bishop")
crewToElite["mantis_free"] = transformStatBoost("mantis_warlord")
crewToElite["rock"] = transformStatBoost("rock_crusader")
crewToElite["rock_crusader"] = transformStatBoost("rock_paladin")
crewToElite["crystal"] = transformStatBoost("crystal_sentinel")
crewToElite["orchid"] = transformStatBoost("orchid_praetor")
crewToElite["orchid_vampweed"] = transformStatBoost("orchid_cultivator")
crewToElite["shell"] = transformStatBoost("shell_radiant")
crewToElite["shell_guardian"] = transformStatBoost("shell_radiant")
crewToElite["leech"] = transformStatBoost("leech_ampere")
crewToElite["slug"] = transformStatBoost("slug_saboteur")
crewToElite["slug_saboteur"] = transformStatBoost("slug_knight")
crewToElite["slug_clansman"] = transformStatBoost("slug_ranger")
crewToElite["lanius"] = transformStatBoost("lanius_welder")
crewToElite["cognitive"] = transformStatBoost("cognitive_advanced")
crewToElite["cognitive_automated"] = transformStatBoost("cognitive_advanced_automated")
crewToElite["obelisk"] = transformStatBoost("obelisk_royal")
crewToElite["phantom"] = transformStatBoost("phantom_alpha")
crewToElite["phantom_goul"] = transformStatBoost("phantom_goul_alpha")
crewToElite["phantom_mare"] = transformStatBoost("phantom_mare_alpha")
crewToElite["phantom_wraith"] = transformStatBoost("phantom_wraith_alpha")
crewToElite["spider_hatch"] = transformStatBoost("spider")
crewToElite["spider"] = transformStatBoost("spider_weaver")
crewToElite["pony"] = transformStatBoost("ponyc")
crewToElite["pony_tamed"] = transformStatBoost("ponyc")
crewToElite["beans"] = transformStatBoost("sylvanrick")
crewToElite["siren"] = transformStatBoost("siren_harpy")
crewToElite["aea_acid_soldier"] = transformStatBoost("aea_acid_captain")
crewToElite["aea_necro_engi"] = transformStatBoost("aea_necro_lich")
crewToElite["aea_bird_avali"] = transformStatBoost("aea_bird_illuminant")
crewToElite["aea_cult_wizard"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_a01"] = transformStatBoost("aea_cult_priest_sup")
crewToElite["aea_cult_wizard_a02"] = transformStatBoost("aea_cult_priest_sup")
crewToElite["aea_cult_wizard_s03"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_s04"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_s05"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_s06"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_a07"] = transformStatBoost("aea_cult_priest_bor")
crewToElite["aea_cult_wizard_s08"] = transformStatBoost("aea_cult_priest_bor")
crewToElite["aea_cult_wizard_s09"] = transformStatBoost("aea_cult_priest_bor")
crewToElite["aea_cult_wizard_a10"] = transformStatBoost("aea_cult_priest_bor")
crewToElite["aea_cult_wizard_a11"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_s12"] = transformStatBoost("aea_cult_priest_sup")
crewToElite["aea_cult_wizard_s13"] = transformStatBoost("aea_cult_priest_off")
crewToElite["aea_cult_wizard_s14"] = transformStatBoost("aea_cult_priest_bor")
--[[function aeatest()
	for crewTarget in vter(Hyperspace.ships.player.vCrewList) do
		if crewToElite[crewTarget.type] then
			Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(Hyperspace.StatBoost(crewToElite[crewTarget.type]), crewTarget)
		end
	end
end]]
local function promoteCrew(shipManager, crewTarget)
	Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(Hyperspace.StatBoost(crewToElite[crewTarget.type]), crewTarget)
	applyWeakened(crewTarget)
end
local function promoteCond(shipManager, crewTarget)
	if crewToElite[crewTarget.type] and checkForValidCrew(crewTarget) then
		return true
	end
	return false
end


-- React to hitting shields. REF: R4V3-0N's AI Cruisers' Anti-Grav Engine augment:
script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(shipManager, projectile, damage, response)
    if shipManager:HasAugmentation("RVS_ANTI_GRAVITY_ENGINE") > 0 then
        if response.damage > 0 or response.superDamage > 0 then
            local dodgeTable = userdata_table(shipManager, "mods.ai.grav_engine")
            if dodgeTable.addDodge then
                dodgeTable.addDodge = math.min(dodgeTable.addDodge + 5, 40)
            else
                dodgeTable.addDodge = 5
            end
        end
    end
end)

-- Make a beam bounce between rooms. REFS: R4V3-0N's AI Cruisers' Chigiriki Focus Beam:
-- Define bounce beams
local bounceBeams = {}
bounceBeams.RVS_FOCUS_BOUNCE = Hyperspace.Blueprints:GetWeaponBlueprint("RVS_PROJECTILE_FOCUS_BOUNCE")
bounceBeams.RVS_FOCUS_BOUNCE_CHAOS = Hyperspace.Blueprints:GetWeaponBlueprint("RVS_PROJECTILE_FOCUS_BOUNCE_CHAOS")
local bounceBeamProjectiles = {}
for _, bp in pairs(bounceBeams) do bounceBeamProjectiles[bp.name] = bp end
-- Handle firing of the weapon
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local bounceBeam = bounceBeams[weapon.blueprint.name]
    if bounceBeam then
        -- Replace fired projectiles with a damage-scaled beam
        local boost = weapon.queuedProjectiles:size()
        weapon.queuedProjectiles:clear()
        local beam = Hyperspace.App.world.space:CreateBeam(
            bounceBeam, projectile.position, projectile.currentSpace, projectile.ownerId,
            projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1),
            projectile.destinationSpace, 1, projectile.heading)
        beam.damage.iDamage = beam.damage.iDamage + boost
        projectile:Kill()

        -- Play sound based on damage
        local soundName = (beam.damage.iDamage <= 2 and "ra_focusbeam" or "ra_focusbeambig")..tostring(math.random(3))
        Hyperspace.Sounds:PlaySoundMix(soundName, -1, false)
    end
end)
-- Handle reflections
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ship, projectile, location, damage, newTile, beamHit)
    local bounceBeam = bounceBeamProjectiles[projectile and projectile.extend and projectile.extend.name]
    if bounceBeam then
        local projData = userdata_table(projectile, "mods.ai.bounceBeam")
        local reflectData = userdata_table(projectile, "mods.ai.reflectivePlating")
        if not projData.didBounce and not reflectData.reflect and damage.iDamage > 1 then
            -- Pick a target that isn't the hit room
            local graph = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId)
            local room = math.random(0, graph.rooms:size() - 2)
            if room >= graph:GetSelectedRoom(location.x, location.y, true) then
                room = room + 1
            end
            local target = graph:GetRoomCenter(room)

            -- Create the reflected beam
            local beam = Hyperspace.App.world.space:CreateBeam(
                bounceBeam, location, ship.iShipId, projectile.ownerId,
                target, Hyperspace.Pointf(target.x, target.y + 1),
                ship.iShipId, 1, 0)
            beam.damage.iDamage = damage.iDamage - 1
            userdata_table(beam, "mods.ai.reflectivePlating").reflect = false
        end
        projData.didBounce = true
    end
end)

-- REF Lizzard's Variety:
local function closestCrew (hitmember, crewList, amount)
    local crewTarget = {hitmember}

    for i=1, amount do
        local closest = 1000
        local new = nil
        for crewmem in vter(crewList) do
            if not has_value(crewTarget, crewmem)  then
                local position = crewmem:GetPosition()
                local distance = get_distance(position, hitmember:GetPosition())
                if distance < closest then
                    new = crewmem
                end
            end
        end
        if new ~= nil then
            table.insert(crewTarget, new)
        end
    end

    return crewTarget
end

-- Lizzard's Variety's "Ionizator"

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)

    local shipId = projectile.ownerId

    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId)

    if shipManager:HasAugmentation("LV_IONIZATOR") > 0 then

        if projectile.sub_end then
            userdata_table(projectile, "mods.lvs.ibean").ionDamage = projectile.damage.iIonDamage + projectile.damage.iSystemDamage + projectile.damage.iDamage
            projectile.damage.iIonDamage = 0
        else
            if projectile.damage.iSystemDamage == 0 and projectile.damage.iDamage == 0 and projectile.damage.iIonDamage ~= 0 then
                projectile.damage.iIonDamage = (projectile.damage.iIonDamage + projectile.damage.iSystemDamage + projectile.damage.iDamage) * 2
            else
                projectile.damage.iIonDamage = projectile.damage.iIonDamage + projectile.damage.iSystemDamage + projectile.damage.iDamage
            end
        end

        projectile.damage.iSystemDamage = 0
        projectile.damage.iDamage = 0
    end

end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
    local weaponName = nil
    pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)
    local otherShip = Hyperspace.Global.GetInstance():GetShipManager((shipManager.iShipId + 1)%2)
    if otherShip:HasAugmentation("LV_IONIZATOR") > 0 then
        local room = get_room_at_location(shipManager, location, true)
        local sys = shipManager:GetSystemInRoom(room)
        if sys ~= nil and Hyperspace.Get_Projectile_Extend(projectile).name ~= "abobus" then

            if sys.healthState.first == 0 then

                Hyperspace.Get_Projectile_Extend(projectile).name = "abobus"
                local sd = Hyperspace.Damage()
                sd.iDamage = damage.iIonDamage
                shipManager:DamageArea(location, sd, true)
                Hyperspace.Get_Projectile_Extend(projectile).name = weaponName

            elseif sys.powerState.second - sys.powerState.first >= sys.healthState.second then

                Hyperspace.Get_Projectile_Extend(projectile).name = "abobus"
                local sd = Hyperspace.Damage()
                sd.iSystemDamage = damage.iIonDamage
                shipManager:DamageArea(location, sd, true)
                Hyperspace.Get_Projectile_Extend(projectile).name = weaponName

            end

        end
    end
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(shipManager, projectile, damage, response)

    local weaponName = nil
    pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)
    local otherShip = Hyperspace.Global.GetInstance():GetShipManager((shipManager.iShipId + 1)%2)
    if otherShip:HasAugmentation("LV_IONIZATOR") > 0 then
        if userdata_table(projectile, "mods.lvs.ibean").ionDamage > 0 then
            local ocal = shipManager:GetRoomCenter(shipManager:GetSystemRoom(0))

            Hyperspace.Get_Projectile_Extend(projectile).name = "abobus"
            local sd = Hyperspace.Damage()
            sd.iIonDamage = userdata_table(projectile, "mods.lvs.ibean").ionDamage * 2
            shipManager:DamageArea(ocal, sd, true)
            Hyperspace.Get_Projectile_Extend(projectile).name = weaponName

            userdata_table(projectile, "mods.lvs.ibean").ionDamage = 0
        end
    end

end)

--REFS: TRC's Magnifiers

mods.trc.statChargers = {}
local statChargers = mods.trc.statChargers
statChargers["TRC_MAGNIFIER_1"] = {{stat = "iDamage"},{stat = "breachChance"},{stat = "fireChance"}}
statChargers["TRC_MAGNIFIER_2"] = {{stat = "iDamage"},{stat = "breachChance"},{stat = "fireChance"}}
statChargers["TRC_MAGNIFIER_PIERCE"] = {{stat = "iShieldPiercing"},{stat = "breachChance"}}
statChargers["TRC_MAGNIFIER_ION"] = {{stat = "iIonDamage"},{stat = "iStun"}}
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local statBoosts = statChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if statBoosts then
        local boost = weapon.queuedProjectiles:size() -- Gets how many projectiles are charged up (doesn't include the one that was already shot)
        weapon.queuedProjectiles:clear() -- Delete all other projectiles
        for _, statBoost in ipairs(statBoosts) do -- Apply all stat boosts
            if statBoost.calc then
                projectile.damage[statBoost.stat] = statBoost.calc(boost, projectile.damage[statBoost.stat])
            else
                projectile.damage[statBoost.stat] = boost + projectile.damage[statBoost.stat]
            end
        end
    end
end)

mods.trc.cooldownChargers = {}
local cooldownChargers = mods.trc.cooldownChargers
cooldownChargers["TRC_MAGNIFIER_1"] = 1.3
cooldownChargers["TRC_MAGNIFIER_2"] = 1.5
cooldownChargers["TRC_MAGNIFIER_PIERCE"] = 1.5
cooldownChargers["TRC_MAGNIFIER_ION"] = 1.2

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    local weapons = ship and ship.weaponSystem and ship.weaponSystem.weapons
    if weapons then
        for weapon in vter(weapons) do
            if weapon.chargeLevel ~= 0 and weapon.chargeLevel < weapon.weaponVisual.iChargeLevels then
                local cdBoost = cooldownChargers[weapon and weapon.blueprint and weapon.blueprint.name]
                if cdBoost then
                    local cdLast = userdata_table(weapon, "mods.trc.weaponStuff").cdLast
                    if cdLast and weapon.cooldown.first > cdLast then
                        -- Calculate the new charge level from number of charges and charge level from last frame
                        local chargeUpdate = weapon.cooldown.first - cdLast
                        local chargeNew = weapon.cooldown.first - chargeUpdate + cdBoost^weapon.chargeLevel*chargeUpdate
                        
                        -- Apply the new charge level
                        if chargeNew >= weapon.cooldown.second then
                            weapon.chargeLevel = weapon.chargeLevel + 1
                            if weapon.chargeLevel == weapon.weaponVisual.iChargeLevels then
                                weapon.cooldown.first = weapon.cooldown.second
                            else
                                weapon.cooldown.first = 0
                            end
                        else
                            weapon.cooldown.first = chargeNew
                        end
                    end
                    userdata_table(weapon, "mods.trc.weaponStuff").cdLast = weapon.cooldown.first
                end
            end
        end
    end
end)