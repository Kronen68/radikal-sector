--[[
////////////////////
WARNINGS SILENCER
////////////////////
]]--
-- This muffles IDE warnings about undefined variables provided by Hyperspace
Hyperspace = Hyperspace or {}
Graphics = Graphics or {}
script = script or {}
Defines = Defines or {}
mods = mods or {}
log = log or {}
RapidXML = RapidXML or {}

-- For all scripts to use, in theory.
mods.rk = {}

mods.rk.augmentsAntiRKWeaponsShouldReactTo = {
    "IS_RK_BAM_GEAR",

    "RK_BAM_DIVINE_ARMOR",
    "RK_COMBAT_AUTO_SYS_REPAIR",
    "DJMOD_COMBAT_SHIPVORE_RAM",
    "LOCKED_DJMOD_COMBAT_SHIPVORE_RAM",
    "DJMOD_CREW_ARE_BOMBS",
    "RK_LEAD_TITANS",
    "RK_PERSISTENCE_SHIELD",
    "EX_RK_CHOKING_IS_FINE",

    "IS_RK_PUNK_GEAR",

    "RK_ARROGANCE_SHIELD",
    "RK_COMBAT_ACE_CONSOLE",
    "RK_COMBAT_DEFENSE_REMOVER",
    "RK_COMBAT_HACK_FLEET",
    "RK_COMBAT_OFFENSE_DISABLER",
    "RK_DREAD_DECK",
    "RK_OWN_HARMONY_ON",
    "RK_OWN_HARMONY_OFF",
    "RK_SUPER_DEFENDERS",
    "EX_DJMOD_DEMICLONER",

    "IS_RK_SCORCH_GEAR",

    "RK_SCORCH_SELF",
    "RK_SCORCH_SELF_2",
    "RK_SCORCH_SELF_3",
    "RK_COMBAT_SCORCH_ENEMY",
    "RK_ENEMIES_CAN_BURN",
    "RK_ENEMIES_BURN_MORE",
    "RK_COMBAT_OXYGENIZER",
    "RK_SCORCH_PREIGNITER",
    "RK_WEAPONS_ON_FIRE",

    "IS_RK_BPS_GEAR",

    "RK_BPS_SHIELD_OVER_MATTER",
    "RK_BPS_SURVEYOR",
}
mods.rk.weaponsAntiRKWeaponsShouldReactTo = {
    "DJMOD_BAM_FISSUREBEAM",
    "RK_HEAVY_POPPER_1",
    "RK_HEAVY_POPPER_2",
    "RK_HEAVY_POPPER_3",
    "RK_UNLOADER",

    "RK_BOMBLAUNCHER_ANTIBIO_REPAIR",
    "RK_KILLALL_BEAM",
    "RK_MISSLAUNCHER_2_BATTERY",
    "RK_RAIN_OF_ION",
    "RK_SHOTPHASER",

    "RK_BOMBLAUNCHER_OXYBOTTLE",
    "RK_FOCUS_FIRE",
    "RK_OXY_FIREFILL_MISSILES",
    "DJMOD_RAIN_OF_FIRE",

    "DJMOD_LASER_BPS",
}
--[[ REF: Lily's Beam Emporium
local augCheckList = {
    "LILY_EXONET_SHIP_MAINFRAME_VERDANT",
    "LILY_EXONET_SHIP_MAINFRAME_CRIMSON",
    "LILY_EXONET_SHIP_MAINFRAME_AZURE",
    "LILY_EXONET_SHIP_MAINFRAME_RADIANT",
    "LILY_EXONET_SHIP_MAINFRAME_IRIDIUM",
} ]]