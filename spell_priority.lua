-- Spell priority configuration for Rouge class
-- Spells are sorted from highest priority to lowest priority

local spell_priority = {
    -- Ultimate abilities
    "rain_of_arrows",
    "shadow_clone",

    -- High priority damage abilities
    "penetrating_shot",
    "dance_of_knives",
    "heartseeker",
    "twisting_blade",

    -- Mobility and utility
    "shadow_step",
    "dash",
    "smoke_grenade",

    -- Imbuements and buffs
    "shadow_imbuement",
    "poison_imbuement",
    "cold_imbuement",

    -- Control and setup
    "poison_trap",
    "death_trap",
    "caltrop",

    -- Basic damage abilities
    "rapid_fire",
    "forcefull_arrow",
    "flurry",
    "barrage",

    -- Defensive abilities
    "concealment",
    "dark_shroud",
    "blade_shift",

    -- Basic attacks and fillers
    "invigorating_strike",
    "puncture"
}

-- Create a lookup table for quick priority checking
local priority_lookup = {}
for index, spell_name in ipairs(spell_priority) do
    priority_lookup[spell_name] = index
end

-- Return both tables in a single table
return {
    spell_priority = spell_priority,
    priority_lookup = priority_lookup
}
