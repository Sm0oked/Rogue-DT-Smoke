-- Spell priority configuration for Rogue class
-- Spells are sorted from highest priority to lowest priority
-- This rotation is optimized for the Death Trap Pit Push build from Mobalytics

local spell_priority = {
    -- Concealment and Death Trap are the primary damage dealers
    "concealment",
    "death_trap",
    
    -- Control abilities that need to be maintained
    "caltrop",
    "poison_trap",
    
    -- Close Quarter Combat maintainers
    "shadow_step",
    "penetrating_shot",
    
    -- Mobility skills with Momentum stacking
    "evade",
    "dash",
    
    -- Imbuements and buffs
    "shadow_imbuement",
    "poison_imbuement",
    "cold_imbuement",
    
    -- Secondary damage abilities
    "dance_of_knives",
    "rain_of_arrows",
    
    -- Utility and defensive abilities
    "shadow_clone",
    "smoke_grenade",
    "dark_shroud",
    
    -- Backup damage abilities
    "heartseeker",
    "twisting_blade",
    "barrage",
    "rapid_fire",
    "forcefull_arrow",
    "flurry",
    
    -- Basic attacks
    "blade_shift",
    "invigorating_strike",
    "puncture"
}

return spell_priority
