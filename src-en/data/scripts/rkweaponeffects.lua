local vter = mods.multiverse.vter

local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

local function get_adjacent_rooms(shipId, roomId, diagonals)
    local shipGraph = Hyperspace.ShipGraph.GetShipInfo(shipId)
    local roomShape = shipGraph:GetRoomShape(roomId)
    local adjacentRooms = {}
    local currentRoom = nil
    local function check_for_room(x, y)
        currentRoom = shipGraph:GetSelectedRoom(x, y, false)
        if currentRoom > -1 and not adjacentRooms[currentRoom] then
            adjacentRooms[currentRoom] = Hyperspace.Pointf(x, y)
        end
    end
    for offset = 0, roomShape.w - 35, 35 do
        check_for_room(roomShape.x + offset + 17, roomShape.y - 17)
        check_for_room(roomShape.x + offset + 17, roomShape.y + roomShape.h + 17)
    end
    for offset = 0, roomShape.h - 35, 35 do
        check_for_room(roomShape.x - 17,               roomShape.y + offset + 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y + offset + 17)
    end
    if diagonals then
        check_for_room(roomShape.x - 17,               roomShape.y - 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y - 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y + roomShape.h + 17)
        check_for_room(roomShape.x - 17,               roomShape.y + roomShape.h + 17)
    end
    return adjacentRooms
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

--[[ REF: ARS+ Challenges. "varr" is a GIGANTIFIC thing, i only pasted the one line needed.
function clear_LaunchOrder()
	--print('clean')
	for i = 0, 100 do
		varr.event_order_caller[i] = ""
	end
end
function add_to_LaunchOrder(ev_name_loc)
	for i = 0, 100 do
		if varr.event_order_caller[i] == "" then
			varr.event_order_caller[i] = ev_name_loc
			--print('added'..ev_name_loc)
			return
		end
	end
end
function try_zero_in_LaunchOrder()
	if varr.event_order_caller[0] ~= "" then
		--print('launch'..varr.event_order_caller[0])
		Hyperspace.CustomEventsParser.GetInstance():LoadEvent(Hyperspace.App.world, varr.event_order_caller[0], true, -1)
		varr.event_order_caller[0] = ""
		for i = 0, 99 do
			varr.event_order_caller[i] = varr.event_order_caller[i+1]
		end
		varr.event_order_caller[100] = ""
	end
end ]]
--[[ local event_order_caller = {[0]="",[1]=""}
function Add_to_LaunchOrder(ev_name_loc)
	for i = 0, 100 do
		if event_order_caller[i] == "" then
			event_order_caller[i] = ev_name_loc
			print('added event'..ev_name_loc)
			return
		end
	end
end ]]


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    -- "Decency" Anti-RK laser: +1 hull damage for each RK weapon/augment the enemy has.
    --WORKS (against weapons only for now)

    --print("rk_a_hull start")

    if weapon.blueprint and weapon.blueprint.name == "RK_A_LASER_1" then
        --print("Decency detected")    --WORKS
    else 
        return Defines.Chain.CONTINUE
    end

    if projectile then
        --local projectileOwner = Hyperspace.ships(projectile.ownerId)
        local otherShip = Hyperspace.ships(1 - projectile.ownerId)

        --print("rk_a_hull otherShip " .. otherShip)      --error attempt to concatenate a userdata table
        --print("rk_a_hull otherShip " .. otherShip.name)     --error attempt to concatenate a nil value (field 'name')
        --Just dont try to print here.
        local bonusValue = 0

        --local projectileReceiverCrew = {}
        --local projectileReceiverAugments = {}     --TODO
        --mods.rk.augmentsAntiRKWeaponsShouldReactTo
        
        local projectileReceiverWeapons =  otherShip:GetWeaponList()    --WORKS
        
        --local index = math.random(0, projectileReceiverWeapons:size()-1)
        for i = 0, projectileReceiverWeapons:size()-1, 1 do
            local enemyWeapon = nil
            enemyWeapon = projectileReceiverWeapons[i]
            if enemyWeapon then
                --print("rk_a_hull eneWeap " .. tostring(i) .. " = " .. tostring(enemyWeapon))
                
                local enemyWeaponName = nil
                --pcall(function() weaponName = projectileReceiverWeapons[i].name end)    --Name in UI, not ID
                enemyWeaponName = enemyWeapon.blueprint.name

                if enemyWeapon.blueprint then
                    enemyWeaponName = enemyWeapon.blueprint.name
                end
                --print("rk_a_hull WeapName " .. tostring(i) .. " = " .. enemyWeaponName)

                if has_value(mods.rk.weaponsAntiRKWeaponsShouldReactTo, enemyWeaponName) then
                    bonusValue = bonusValue + 1
                end
            end
        end
        
        --print("rk_a_hull bonus " .. bonusValue)
        --Add the damage then CONTINUE if needed. (Not needed)
        projectile.damage.iDamage = bonusValue + projectile.damage.iDamage
    end
    -- return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    -- "Measure" Anti-RK missile: +1 system damage for each RK weapon/augment the enemy has.
    --(against weapons only for now)

    --print("rk_a_sys start")

    if weapon.blueprint and weapon.blueprint.name == "RK_A_MISSLAUNCHER" then
        --print("Measure detected")    --WORKS
    else 
        return Defines.Chain.CONTINUE
    end

    if projectile then
        --local projectileOwner = Hyperspace.ships(projectile.ownerId)
        local otherShip = Hyperspace.ships(1 - projectile.ownerId)
        --Just dont try to print here.
        local bonusValue = 0

        --local projectileReceiverCrew = {}
        --local projectileReceiverAugments = {}     --TODO
        --mods.rk.augmentsAntiRKWeaponsShouldReactTo
        
        local projectileReceiverWeapons =  otherShip:GetWeaponList()    --WORKS
        
        --local index = math.random(0, projectileReceiverWeapons:size()-1)
        for i = 0, projectileReceiverWeapons:size()-1, 1 do
            local enemyWeapon = nil
            enemyWeapon = projectileReceiverWeapons[i]
            if enemyWeapon then
                --print("rk_a_sys eneWeap " .. tostring(i) .. " = " .. tostring(enemyWeapon))
                
                local enemyWeaponName = nil
                --pcall(function() weaponName = projectileReceiverWeapons[i].name end)    --Name in UI, not ID
                enemyWeaponName = enemyWeapon.blueprint.name

                if enemyWeapon.blueprint then
                    enemyWeaponName = enemyWeapon.blueprint.name
                end
                --print("rk_a_hull WeapName " .. tostring(i) .. " = " .. enemyWeaponName)

                if has_value(mods.rk.weaponsAntiRKWeaponsShouldReactTo, enemyWeaponName) then
                    bonusValue = bonusValue + 1
                end
            end
        end
        
        --print("rk_a_sys bonus " .. bonusValue)
        --Add the damage
        projectile.damage.iSystemDamage = bonusValue + projectile.damage.iSystemDamage
    end
end)


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)

    -- Calibrator: bonus accuracy. WORKS. Even when Beams shoot, FWIW.
    if projectile then
        local shipManager = Hyperspace.ships(projectile.ownerId)

        if shipManager then
            local accuAugCount = shipManager:HasAugmentation("INTERNAL_RK_CALIBRATOR")
            --print("Calibrators: " .. accuAugCount)

            if accuAugCount > 0 then
                -- intended: 10. WORKS
                accuBoost = 10 * accuAugCount
                --print("Calib accuBoost: " .. accuBoost)
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod + accuBoost
                --print("Calib newAccu: " .. projectile.extend.customDamage.accuracyMod)
            end
        end
    end
--[[ REF: Lily's Innovations: "ECM Suite" internal upgrade "Jamming Screen".

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if projectile then
        local shipManager = Hyperspace.ships(projectile.ownerId)
        local otherShipManager = Hyperspace.ships(1 - projectile.ownerId)
        if shipManager and otherShipManager then
            if otherShipManager:HasSystem(Hyperspace.ShipSystem.NameToSystemId("lily_ecm_suite")) and otherShipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId("lily_ecm_suite")):Functioning() and (otherShipManager:HasAugmentation("UPG_LILY_ECM_JAMMER_FIELD") > 0 or otherShipManager:HasAugmentation("EX_LILY_ECM_JAMMER_FIELD") > 0) then
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod - 10
            end
            if otherShipManager:HasSystem(Hyperspace.ShipSystem.NameToSystemId("lily_ecm_suite")) and (uecmCache[1 - shipManager.iShipId]) then
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod - 15
            end

            if otherShipManager and otherShipManager:HasSystem(Hyperspace.ShipSystem.NameToSystemId("lily_ecm_suite")) then
                if mods.lilyinno.ecmsuite.getState(otherShipManager, "jammer") > 0 then
                    local targetroom = userdata_table(otherShipManager, "mods.lilyinno.ecmsuite").jammerTargetroom or -1
                    local strength = userdata_table(otherShipManager, "mods.lilyinno.ecmsuite").jammerStrength or 1
                    local system = shipManager:GetSystemInRoom(targetroom)
                    if system then
                        local id = system:GetId()

                        if id == Hyperspace.ShipSystem.NameToSystemId("artillery") then
                            projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod - 10 * strength
                        elseif id == Hyperspace.ShipSystem.NameToSystemId("weapons") then
                            projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod - 5 * strength
                        end
                    end
                end
            end
        end
    end
end, 64) ]]

    -- Heavy Popper lasers. REF: Gravespred, Weapons On Fire (both below).
    local shipId = projectile.ownerId
    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId)
    
    -- Heavy Popper MK I.
    if weapon.blueprint and weapon.blueprint.name == "RK_HEAVY_POPPER_1" then
        -- Systems self-damage

        for system in vter(shipManager.vSystemList) do
            -- print("heavy_popper_2: 1 vter loop")
            local roomId = shipManager:GetSystemRoom(system:GetId())
            local location = shipManager:GetRoomCenter(roomId)
            local sysDmg = Hyperspace.Damage()
            sysDmg.iSystemDamage = 1

            -- Chance system dmg - WORKS
            if math.random() < 0.05 then        --intended: 0.05
                -- print("heavy popper self-dmg triggered")
                shipManager:DamageArea(location, sysDmg, true)
            end
        end
    end
    -- Heavy Popper MK II.
    if weapon.blueprint and weapon.blueprint.name == "RK_HEAVY_POPPER_2" then
        -- Systems self-damage
        for system in vter(shipManager.vSystemList) do
            local roomId = shipManager:GetSystemRoom(system:GetId())
            local location = shipManager:GetRoomCenter(roomId)
            local sysDmg = Hyperspace.Damage()
            sysDmg.iSystemDamage = 1
            -- Chance system dmg
            if math.random() < 0.04 then        --intended: 0.04
                shipManager:DamageArea(location, sysDmg, true)
            end
        end
    end
    -- Heavy Popper MK III.
    if weapon.blueprint and weapon.blueprint.name == "RK_HEAVY_POPPER_3" then
        -- Systems self-damage
        for system in vter(shipManager.vSystemList) do
            local roomId = shipManager:GetSystemRoom(system:GetId())
            local location = shipManager:GetRoomCenter(roomId)
            local sysDmg = Hyperspace.Damage()
            sysDmg.iSystemDamage = 1
            -- Chance system dmg
            if math.random() < 0.03 then        --intended: 0.03
                shipManager:DamageArea(location, sysDmg, true)
            end
        end
    end


    -- Gravespred beam.
    --[[ REF Lily's Beam Emporium:

    if weapon.blueprint and weapon.blueprint.name == "LILY_FOCUS_ION_PHASE" then

        local damage = projectile.damage
        damage.iShieldPiercing = damage.iIonDamage + 1
        damage.iIonDamage = 2 + (damage.iShieldPiercing > 10 and (damage.iShieldPiercing - 10) / 10 or 0)
        --print(projectile.damage.iIonDamage)
        --print(projectile.damage.iShieldPiercing)
    end ]]
    --[[ REF Lizzard's variety:
    if weaponName == "LV_MALF_RECOIL" then

        local shipId = projectile.ownerId
        local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId)

        for system in vter(shipManager.vSystemList) do

            local roomId = shipManager:GetSystemRoom(system:GetId())

            local location = shipManager:GetRoomCenter(roomId)

            local crewDamage = Hyperspace.Damage()
            crewDamage.iPersDamage = 1
            shipManager:DamageArea(location, crewDamage, true)
        end

        userdata_table(weapon, "mods.modname.recoil").recoilGoodTime = 2

    end ]]
    local shipId = projectile.ownerId
    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId)

    if weapon.blueprint and weapon.blueprint.name == "RK_KILLALL_BEAM" then
        -- Scaling piercing
        local damage = projectile.damage
        -- damage.iShieldPiercing = damage.iPersDamage - 1     -- Somehow this is always 1 lower than expected.
        damage.iShieldPiercing = damage.iPersDamage             -- Actually 1 lower than iPersDamage.
        -- print(projectile.damage.iShieldPiercing)
        -- print(projectile.damage.iPersDamage)

        -- Crew self-damage

        for room in vter(shipManager.ship.vRoomList) do
            -- print("killall_beam: 1 vter loop")

            local roomId = room.iRoomId

            local location = shipManager:GetRoomCenter(roomId)

            local crewDamage = Hyperspace.Damage()
            -- If crew damage to other ship is at least 2, deal 1 damage in player ship. Untested!
            -- crewDamage.iPersDamage = math.maxinteger(0, math.mininteger(1, damage.iPersDamage))
            -- Scale with outwards damage. WORKS
            crewDamage.iPersDamage = math.max(0, damage.iPersDamage - 3)
            -- print(crewDamage.iPersDamage)
            if (crewDamage.iPersDamage > 0) then
                shipManager:DamageArea(location, crewDamage, true)
            end
        end
        --[[ WORKS but only does system rooms.
        for system in vter(shipManager.vSystemList) do
            -- print("killall_beam: 1 vter loop")

            local roomId = shipManager:GetSystemRoom(system:GetId())
            local location = shipManager:GetRoomCenter(roomId)
            local crewDamage = Hyperspace.Damage()
            -- Scale with outwards damage. WORKS
            crewDamage.iPersDamage = math.max(0, damage.iPersDamage - 3)
            print(crewDamage.iPersDamage)
            if (crewDamage.iPersDamage > 0) then
                shipManager:DamageArea(location, crewDamage, true)
            end
        end ]]
    end

    -- RK Scorch Pre-Igniter augment
    if shipManager:HasAugmentation("RK_SCORCH_PREIGNITER") > 0 then
        local roomId = shipManager.weaponSystem.roomId
        if roomId then
            shipManager:StartFire(roomId)
        end
    end

    -- Weapons On Fire augment
    local augName = "RK_WEAPONS_ON_FIRE"
    local stackAugName = "RK_WEAPONS_ON_FIRE_TEMP"
    local comboAugName = "RK_SCORCH_PREIGNITER"
    if shipManager:HasAugmentation(augName) > 0 then
        -- Chance fire - WORKS.
        
        -- Make it stack with >1 "Weapons On Fire": turns out shipManager:GetAugmentationValue(augName) ALREADY stacks,
        -- most likely because the augment has <stackable>true</stackable>.
        if math.random() < shipManager:GetAugmentationValue(augName) then
        --[[ local baseAugCount = shipManager:HasAugmentation(augName)
        local realFireChance = shipManager:GetAugmentationValue(augName) * baseAugCount
        print("baseAugCount:"..baseAugCount)
        print("realFireChance:"..realFireChance)
        if math.random() < realFireChance then ]]

            local roomId = shipManager.weaponSystem.roomId
            if roomId then
                shipManager:StartFire(roomId)
            end
            -- Artilleries - WORKS
            for arti in vter(shipManager.artillerySystems) do
                if arti then
                    local artiRoomId = arti.roomId
                    shipManager:StartFire(artiRoomId)
                end
            end
        end

        -- Stack fire rate - clear on jump.
        -- WORKS
        local augCount = shipManager:HasAugmentation(stackAugName)
        -- print("aug count for adding:"..augCount)
        
        -- Add temp augs
        
        -- if Hyperspace.ships.player:HasAugmentation(comboAugName) then        --NO WORK, seems always true.
        -- WORKS
        local comboAugCount = shipManager:HasAugmentation(comboAugName)
        if comboAugCount >= 1 then
            -- intended: 20
            if augCount < 20 then
                shipManager:AddAugmentation("HIDDEN " .. stackAugName)
            end
        else
            -- WORKS
            -- intended: 10
            if augCount < 10 then
                -- Arc's technique: pure Lua. WORKS
                shipManager:AddAugmentation("HIDDEN " .. stackAugName)
            end
        end

    end
end)

--[[ Should prob modify damage value when projectile is shot instead,
there seems to be no Defines.Chain.CONTINUE after DAMAGE_AREA_HIT.
So must hit again and then prevent loop, which is suboptimal. ]]
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)

    --[[ -- "Decency" Anti-RK laser: extra damage vs RK.

    --local table_to_list_string = mods.multiverse.table_to_list_string

    -- local function rk_a_extra_hull_damage(shipManager, projectile, location)
    print("rk_a_hull start")
    if projectile then
        local projectileOwner = Hyperspace.ships(projectile.ownerId)
        local bonusValue = 0

        --local projectileReceiverCrew = {}

        local projectileReceiverAugments = {}
        --mods.rk.augmentsAntiRKWeaponsShouldReactTo

        local projectileReceiverWeapons =  shipManager:GetWeaponList()
        --local index = math.random(0, projectileReceiverWeapons:size()-1)
        for i = 0, projectileReceiverWeapons:size()-1, 1 do
            print("rk_a_hull weap Loop " .. tostring(i))
            
            local weaponName = nil
            --pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)
            --pcall(function() weaponName = projectileReceiverWeapons[i].name end)    --not the ID
            --pcall(function() weaponName = projectileReceiverWeapons[i] end)         --code seems to fail here.
            weaponName = Hyperspace.Blueprints:GetWeaponBlueprint(projectileReceiverWeapons[i]) 

            if weaponName then
                print("rk_a_hull weap " .. tostring(i) .. " = " .. weaponName)
                --print("rk_a_hull weap " .. projectileReceiverWeapons[i])

                -- if has_value(mods.rk.weaponsAntiRKWeaponsShouldReactTo, weaponName) then
                if has_value(mods.rk.weaponsAntiRKWeaponsShouldReactTo, weaponName) then
                    bonusValue = bonusValue + 1
                end
            end
            
        end
        
        --bonusValue = shipManager:HasAugmentation(comboAugName)
        print("rk_a_hull bonus " .. bonusValue)
    end
        
    --end
    --script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, rk_a_extra_hull_damage)
    --script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, rk_a_extra_hull_damage) ]]
end)


local function manually_firefill(shipManager, roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
    shipManager:StartFire(roomId)
end
-- REF: Lizzard's Variety: LV_RECOIL_MISSILES
-- script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
    
    -- RK_FOCUS_FIRE aka "Hot Poker", Fireblast effect.
    
    -- Antibug "Triggers exactly 5 times every shot no matter what."
    if beamHitType ~= Defines.BeamHit.NEW_ROOM then return Defines.Chain.CONTINUE, beamHitType end
    
    local weaponName = nil
    pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)

    if weaponName == "RK_FOCUS_FIRE" then
        -- print("Poker detected")

        local roomId = get_room_at_location(shipManager, location, false)
        local fireCount = shipManager:GetFireCount(get_room_at_location(shipManager, location, true))
        if fireCount > 0 then
            -- print("Poker Fire-Blast checked")
            
            local touchedRooms = {}
            table.insert(touchedRooms, roomId)

            for i, k in pairs(get_adjacent_rooms(shipManager.iShipId, roomId, true)) do

                -- Still counts as damage from the weapon: if weapon spawns crew, will spawn for each of these.
                if (not has_value(touchedRooms, i)) then
                    shipManager:StartFire(i)                -- WORKS
                    -- If above doesn't work, try this:
                    -- local adjacentRoomId = get_room_at_location(shipManager, k, false)
                    -- shipManager:StartFire(adjacentRoomId)

                    local secondDamage = Hyperspace.Damage()
                    -- secondDamage.iStun = 4
                    secondDamage.iSystemDamage = 1
                    secondDamage.iPersDamage = 1
                    -- print(secondDamage.iSystemDamage)
                    shipManager:DamageArea(k, secondDamage, true)
                    table.insert(touchedRooms, i)
                end

            end
        else
            -- Room had no fire. Manually fire-fill. Default fire-fill makes fire detection always true.
        end
        manually_firefill(shipManager, roomId)
    end
    --[[ if weaponName == "LV_RECOIL_MISSILES" then

        local roomId = get_room_at_location(shipManager, location, false)
        Hyperspace.Get_Projectile_Extend(projectile).name = ""

        local firstDamage = Hyperspace.Damage()
        firstDamage.iStun = 6
        shipManager:DamageArea(location, firstDamage, true)

        local touchedRooms = {}
        table.insert(touchedRooms, roomId)

        for i, k in pairs(get_adjacent_rooms(shipManager.iShipId, roomId, true)) do

                if (not has_value(touchedRooms, i)) then
                    local secondDamage = Hyperspace.Damage()
                    secondDamage.iStun = 4
                    shipManager:DamageArea(k, secondDamage, true)
                    table.insert(touchedRooms, i)
                end

            for j, s in pairs(get_adjacent_rooms(shipManager.iShipId, i, true)) do

                    if (not has_value(touchedRooms, j)) then
                        local thirdDamage = Hyperspace.Damage()
                        thirdDamage.iStun = 3
                        shipManager:DamageArea(s, thirdDamage, true)
                        table.insert(touchedRooms, j)
                    end

                for b, c in pairs(get_adjacent_rooms(shipManager.iShipId, j, true)) do

                        if (not has_value(touchedRooms, b)) then
                            local fourthDamage = Hyperspace.Damage()
                            fourthDamage.iStun = 2
                            shipManager:DamageArea(c, fourthDamage, true)
                            table.insert(touchedRooms, b)
                        end
                    for g, w in pairs(get_adjacent_rooms(shipManager.iShipId, b, true)) do

                            if (not has_value(touchedRooms, g)) then
                                local fifthDamage = Hyperspace.Damage()
                                fifthDamage.iStun = 1
                                shipManager:DamageArea(w, fifthDamage, true)
                                table.insert(touchedRooms, g)
                            end
                    end

                end

            end

        end

    end ]]

    -- REF: MV v5.5.1's mind-control.lua
    return Defines.Chain.CONTINUE, beamHitType      -- Doesn't fix "Triggers 5 times per shot". The Antibug line does.
end)


-- Heavy Popper lasers "breach extra" effect. REF: MV's fire-fill.lua

--[[ local breachExtraWeapons = {
    RK_HEAVY_POPPER_1,
    RK_HEAVY_POPPER_2,
    RK_HEAVY_POPPER_3
} ]]

local projectileAlreadyExtraBreached = {}

-- INFINITE LOOP FIXED.
do
    local function breach_extra(shipManager, projectile, location)
        -- print("breach_extra start")
        
        -- Stop infinite loop
        if has_value(projectileAlreadyExtraBreached, projectile) then return end

        -- Don't react to the self-system-damage chance.
        if projectile then
            -- REF somewhere higher in this file: 
            -- local shipManager = Hyperspace.ships(projectile.ownerId)
            local projectileOwner = Hyperspace.ships(projectile.ownerId)
            if shipManager ~= projectileOwner then
                -- print("breach_extra: otherShip")
        
                local weaponName = nil
                pcall(function() weaponName = Hyperspace.Get_Projectile_Extend(projectile).name end)

                -- THIS LINE ALWAYS TRUE
                -- if weaponName == "RK_HEAVY_POPPER_1" or "RK_HEAVY_POPPER_2" or "RK_HEAVY_POPPER_3" then
                if (weaponName == "RK_HEAVY_POPPER_1") or (weaponName == "RK_HEAVY_POPPER_2") or (weaponName == "RK_HEAVY_POPPER_3") then
                    -- print("breach_extra: popper")

                    local roomId = get_room_at_location(shipManager, location, false)
                    if roomId > -1 then
                        -- print("breach_extra: room good")
                        
                        table.insert(projectileAlreadyExtraBreached, projectile)
                        local secondDamage = Hyperspace.Damage()
                        secondDamage.breachChance = 10
                        shipManager:DamageArea(location, secondDamage, true)
                    end
                end
            end
        end
    end
    -- script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, breach_extra)
    script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, breach_extra)
end


