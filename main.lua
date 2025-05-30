local my_utility = require("my_utility/my_utility")
local my_target_selector = require("my_utility/my_target_selector")
local spell_data = require("my_utility/spell_data")
local spell_priority = require("spell_priority")
local menu = require("menu")
local enhancements_manager = require("my_utility/enhancements_manager")

local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_rogue = character_id == 3;
if not is_rogue then
 return
end;

-- orbwalker settings
orbwalker.set_block_movement(true);
orbwalker.set_clear_toggle(true);

local spells =
{
    concealment             = require("spells/concealment"),
    caltrop                 = require("spells/caltrop"),
    puncture                = require("spells/puncture"),
    heartseeker             = require("spells/heartseeker"),
    forcefull_arrow         = require("spells/forcefull_arrow"),
    blade_shift             = require("spells/blade_shift"),
    invigorating_strike     = require("spells/invigorating_strike"),
    twisting_blade          = require("spells/twisting_blade"),
    barrage                 = require("spells/barrage"),
    rapid_fire              = require("spells/rapid_fire"),
    flurry                  = require("spells/flurry"),
    penetrating_shot        = require("spells/penetrating_shot"),
    shadow_step             = require("spells/shadow_step"),
    smoke_grenade           = require("spells/smoke_grenade"),
    poison_trap             = require("spells/poison_trap"),
    dark_shroud             = require("spells/dark_shroud"),
    shadow_imbuement        = require("spells/shadow_imbuement"),
    poison_imbuement        = require("spells/poison_imbuement"),
    cold_imbuement          = require("spells/cold_imbuement"),
    shadow_clone            = require("spells/shadow_clone"),
    death_trap              = require("spells/death_trap"),
    rain_of_arrows          = require("spells/rain_of_arrows"),
    dance_of_knives         = require("spells/dance_of_knives"),
    evade                  = require("spells/evade"),
    dash                   = require("spells/dash"),
}

-- Add tracking variables for spell timings and cooldowns
if not _G.last_death_trap_time then _G.last_death_trap_time = 0 end
if not _G.last_concealment_time then _G.last_concealment_time = 0 end
if not _G.last_heartseeker_cast_time then _G.last_heartseeker_cast_time = 0 end
if not _G.last_shadowstep_time then _G.last_shadowstep_time = 0 end
if not _G.last_poison_trap_time then _G.last_poison_trap_time = 0 end
if not _G.last_caltrop_time then _G.last_caltrop_time = 0 end
if not _G.last_penetrating_shot_time then _G.last_penetrating_shot_time = 0 end
if not _G.last_health_potion_time then _G.last_health_potion_time = 0 end
if not _G.last_dash_time then _G.last_dash_time = 0 end
if not _G.initial_momentum_stacked then _G.initial_momentum_stacked = false end

-- Variables for casting
local can_move = 0.0
local cast_end_time = 0.0
local cast_delay = 0.2

on_render_menu(function()
    if not menu.menu_elements.main_tree:push("Rogue: Death_Trap | Smoke Edition") then
        return
    end

    menu.menu_elements.main_boolean:render("Enable Plugin", "")
    if menu.menu_elements.main_boolean:get() == false then
        menu.menu_elements.main_tree:pop()
        return
    end

    local options = {"Melee", "Ranged"}
    menu.menu_elements.mode:render("Mode", options, "")
    menu.menu_elements.evade_cooldown:render("Evade Cooldown", "")

    if menu.menu_elements.settings_tree:push("Settings") then
        menu.menu_elements.enemy_count_threshold:render("Minimum Enemy Count",
            "       Minimum number of enemies in Enemy Evaluation Radius to consider them for targeting")
        menu.menu_elements.targeting_refresh_interval:render("Targeting Refresh Interval",
            "       Time between target checks in seconds       ", 1)
        menu.menu_elements.max_targeting_range:render("Max Targeting Range",
            "       Maximum range for targeting       ")
        menu.menu_elements.min_enemy_distance:render("Minimum Enemy Distance",
            "       Minimum distance to enemies before targeting them       ", 1)
        menu.menu_elements.cursor_targeting_radius:render("Cursor Targeting Radius",
            "       Area size for selecting target around the cursor       ", 1)
        menu.menu_elements.cursor_targeting_angle:render("Cursor Targeting Angle",
            "       Maximum angle between cursor and target to cast targetted spells       ")
        menu.menu_elements.best_target_evaluation_radius:render("Enemy Evaluation Radius",
            "       Area size around an enemy to evaluate if it's the best target       \n" ..
            "       If you use huge aoe spells, you should increase this value       \n" ..
            "       Size is displayed with debug/display targets with faded white circles       ", 1)

        menu.menu_elements.custom_enemy_weights:render("Custom Enemy Weights",
            "Enable custom enemy weights for determining best targets within Enemy Evaluation Radius")
        if menu.menu_elements.custom_enemy_weights:get() then
            if menu.menu_elements.custom_enemy_weights_tree:push("Custom Enemy Weights") then
                menu.menu_elements.enemy_weight_normal:render("Normal Enemy Weight",
                    "Weighing score for normal enemies - default is 2")
                menu.menu_elements.enemy_weight_elite:render("Elite Enemy Weight",
                    "Weighing score for elite enemies - default is 10")
                menu.menu_elements.enemy_weight_champion:render("Champion Enemy Weight",
                    "Weighing score for champion enemies - default is 15")
                menu.menu_elements.enemy_weight_boss:render("Boss Enemy Weight",
                    "Weighing score for boss enemies - default is 50")
                menu.menu_elements.enemy_weight_damage_resistance:render("Damage Resistance Aura Enemy Weight",
                    "Weighing score for enemies with damage resistance aura - default is 25")
                menu.menu_elements.custom_enemy_weights_tree:pop()
            end
        end

        menu.menu_elements.enable_debug:render("Enable Debug", "")
        if menu.menu_elements.enable_debug:get() then
            if menu.menu_elements.debug_tree:push("Debug") then
                menu.menu_elements.draw_targets:render("Display Targets", menu.draw_targets_description)
                menu.menu_elements.draw_max_range:render("Display Max Range",
                    "Draw max range circle")
                menu.menu_elements.draw_melee_range:render("Display Melee Range",
                    "Draw melee range circle")
                menu.menu_elements.draw_enemy_circles:render("Display Enemy Circles",
                    "Draw enemy circles")
                menu.menu_elements.draw_cursor_target:render("Display Cursor Target", menu.cursor_target_description)
                menu.menu_elements.debug_tree:pop()
            end
        end

        menu.menu_elements.settings_tree:pop()
    end

    local equipped_spells = get_equipped_spell_ids()
    table.insert(equipped_spells, spell_data.evade.spell_id) -- add evade to the list
    
    -- Create a lookup table for equipped spells
    local equipped_lookup = {}
    for _, spell_id in ipairs(equipped_spells) do
        -- Check each spell in spell_data to find matching spell_id
        for spell_name, data in pairs(spell_data) do
            if data.spell_id == spell_id then
                equipped_lookup[spell_name] = true
                break
            end
        end
    end

    if menu.menu_elements.spells_tree:push("Equipped Spells") then
        -- Display spells in priority order, but only if they're equipped
        for _, spell_name in ipairs(spell_priority) do
            if equipped_lookup[spell_name] and spells[spell_name] then
                local spell = spells[spell_name]
                if spell and spell.menu then
                    spell.menu()
                end
            end
        end
        menu.menu_elements.spells_tree:pop()
    end

    if menu.menu_elements.disabled_spells_tree:push("Inactive Spells") then
        for _, spell_name in ipairs(spell_priority) do
            local spell = spells[spell_name]
            if spell and spell.menu and (not equipped_lookup[spell_name] or 
               (spell.menu_elements and not spell.menu_elements.main_boolean:get())) then
                spell.menu()
            end
        end
        menu.menu_elements.disabled_spells_tree:pop()
    end

    -- Add enhancements menu
    enhancements_manager.render_enhancements_menu(menu.menu_elements)

    menu.menu_elements.main_tree:pop();
end)

-- Targets
local best_ranged_target = nil
local best_ranged_target_visible = nil
local best_melee_target = nil
local best_melee_target_visible = nil
local closest_target = nil
local closest_target_visible = nil
local best_cursor_target = nil
local closest_cursor_target = nil
local closest_cursor_target_angle = 0

-- Target scores
local ranged_max_score = 0
local ranged_max_score_visible = 0
local melee_max_score = 0
local melee_max_score_visible = 0
local cursor_max_score = 0

-- Targeting settings
local max_targeting_range = menu.menu_elements.max_targeting_range:get()
local collision_table = { true, 1 } -- collision width
local floor_table = { true, 5.0 }   -- floor height
local angle_table = { false, 90.0 } -- max angle

-- Cache for heavy function results
local next_target_update_time = 0.0 -- Time of next target evaluation
local next_cast_time = 0.0          -- Time of next possible cast
local targeting_refresh_interval = menu.menu_elements.targeting_refresh_interval:get()

-- Default enemy weights for different enemy types
local normal_monster_value = 2
local elite_value = 10
local champion_value = 15
local boss_value = 50
local damage_resistance_value = 25

-- Apply custom weights if enabled
if menu.menu_elements.custom_enemy_weights:get() then
    normal_monster_value = menu.menu_elements.enemy_weight_normal:get()
    elite_value = menu.menu_elements.enemy_weight_elite:get()
    champion_value = menu.menu_elements.enemy_weight_champion:get()
    boss_value = menu.menu_elements.enemy_weight_boss:get()
    damage_resistance_value = menu.menu_elements.enemy_weight_damage_resistance:get()
end

local target_selector_data_all = nil

-- Enhanced target evaluation function
local function evaluate_targets(target_list, melee_range)
    local best_ranged_target = nil
    local best_melee_target = nil
    local best_cursor_target = nil
    local closest_cursor_target = nil
    local closest_cursor_target_angle = 0

    local ranged_max_score = 0
    local melee_max_score = 0
    local cursor_max_score = 0

    local melee_range_sqr = melee_range * melee_range
    local player_position = get_player_position()
    local cursor_position = get_cursor_position()
    local cursor_targeting_radius = menu.menu_elements.cursor_targeting_radius:get()
    local cursor_targeting_radius_sqr = cursor_targeting_radius * cursor_targeting_radius
    local best_target_evaluation_radius = menu.menu_elements.best_target_evaluation_radius:get()
    local cursor_targeting_angle = menu.menu_elements.cursor_targeting_angle:get()
    local enemy_count_threshold = menu.menu_elements.enemy_count_threshold:get()
    local min_enemy_distance = menu.menu_elements.min_enemy_distance:get()
    local min_enemy_distance_sqr = min_enemy_distance * min_enemy_distance
    local closest_cursor_distance_sqr = math.huge

    -- First check if we have enough enemies to satisfy the minimum enemy count threshold
    local total_valid_enemies = 0
    local has_boss_enemy = false
    for _, unit in ipairs(target_list) do
        total_valid_enemies = total_valid_enemies + 1
        if unit:is_boss() then
            has_boss_enemy = true
        end
    end
    
    -- If we don't have enough valid enemies total and no boss is present, return empty targets
    if total_valid_enemies < enemy_count_threshold and not has_boss_enemy then
        return {
            best_ranged_target = nil,
            best_melee_target = nil,
            best_cursor_target = nil,
            closest_cursor_target = nil,
            closest_cursor_target_angle = 0,
            ranged_max_score = 0,
            melee_max_score = 0,
            cursor_max_score = 0
        }
    end

    for _, unit in ipairs(target_list) do
        local unit_health = unit:get_current_health()
        local unit_name = unit:get_skin_name()
        local unit_position = unit:get_position()
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position)
        local cursor_distance_sqr = unit_position:squared_dist_to_ignore_z(cursor_position)
        local buffs = unit:get_buffs()

        -- Skip enemies that are too close based on min_enemy_distance setting
        if distance_sqr < min_enemy_distance_sqr then
            goto continue
        end

        -- Get enemy count in range of enemy unit
        local all_units_count, normal_units_count, elite_units_count, champion_units_count, boss_units_count = my_utility.enemy_count_in_range(best_target_evaluation_radius, unit_position)

        -- Calculate total score based on enemy count and enemy type weights
        local total_score = normal_units_count * normal_monster_value
        if boss_units_count > 0 then
            total_score = total_score + boss_value * boss_units_count
        elseif champion_units_count > 0 then
            total_score = total_score + champion_value * champion_units_count
        elseif elite_units_count > 0 then
            total_score = total_score + elite_value * elite_units_count
        end

        -- Check for damage resistance buffs
        for _, buff in ipairs(buffs) do
            if spell_data.enemies and spell_data.enemies.damage_resistance and 
               buff.name_hash == spell_data.enemies.damage_resistance.spell_id then
                -- If enemy is provider of damage resistance aura
                if spell_data.enemies.damage_resistance.buff_ids and 
                   buff.type == spell_data.enemies.damage_resistance.buff_ids.provider then
                    total_score = total_score + damage_resistance_value
                    break
                else -- Enemy is receiver of damage resistance aura
                    total_score = total_score - damage_resistance_value
                    break
                end
            end
        end

        -- Add bonus score for vulnerable or recently hit enemies
        if unit:is_vulnerable() then
            total_score = total_score + 5000
        end

        -- Update best ranged target if this unit has higher score
        if distance_sqr <= max_targeting_range * max_targeting_range then
            if total_score > ranged_max_score then
                best_ranged_target = unit
                ranged_max_score = total_score
            end
        end

        -- Update best melee target if this unit is in melee range and has higher score
        if distance_sqr <= melee_range_sqr then
            if total_score > melee_max_score then
                best_melee_target = unit
                melee_max_score = total_score
            end
        end

        -- Update cursor targets
        if cursor_distance_sqr <= cursor_targeting_radius_sqr then
            local is_within_angle = my_utility.is_target_within_angle(player_position, cursor_position, unit_position, cursor_targeting_angle)
            
            if is_within_angle then
                if total_score > cursor_max_score then
                    best_cursor_target = unit
                    cursor_max_score = total_score
                end

                if cursor_distance_sqr < closest_cursor_distance_sqr then
                    closest_cursor_target = unit
                    closest_cursor_distance_sqr = cursor_distance_sqr
                    closest_cursor_target_angle = cursor_targeting_angle
                end
            end
        end
        
        ::continue::
    end

    return {
        best_ranged_target = best_ranged_target,
        best_melee_target = best_melee_target,
        best_cursor_target = best_cursor_target,
        closest_cursor_target = closest_cursor_target,
        closest_cursor_target_angle = closest_cursor_target_angle,
        ranged_max_score = ranged_max_score,
        melee_max_score = melee_max_score,
        cursor_max_score = cursor_max_score
    }
end

local function get_momentum_stacks()
    local local_player = get_local_player()
    if not local_player then return 0 end
    local buffs = local_player:get_buffs()
    local momentum_buff_hash = 391681
    for _, buff in ipairs(buffs) do
        if buff.name_hash == momentum_buff_hash then
            return buff.stacks or 0
        end
    end
    return 0
end

-- Initialize enhancements
local enhancements_initialized = false

on_update(function()
    local local_player = get_local_player()
    if not local_player or not menu.menu_elements.main_boolean:get() then
        return
    end

    local current_time = get_time_since_inject()

    -- Initialize enhancements if not done already
    if not enhancements_initialized then
        enhancements_initialized = enhancements_manager.initialize(menu.menu_elements)
    end
    
    -- Process enhanced evade if enabled
    if menu.menu_elements.enhanced_evade and menu.menu_elements.enhanced_evade:get() then
        -- Wrap evade processing in pcall to prevent script errors
        local evaded = false
        local evade_success = pcall(function()
            evaded = enhancements_manager.process_evade(menu.menu_elements)
        end)
        
        if evade_success and evaded then
            -- Successfully evaded, skip the rest of this frame
            return
        end
    end
    
    -- Manage buffs if enabled
    if menu.menu_elements.auto_buff_management and menu.menu_elements.auto_buff_management:get() then
        -- Wrap buff management in pcall to prevent script errors
        local buff_managed, buff_action = false, nil
        local buff_success = pcall(function()
            buff_managed, buff_action = enhancements_manager.manage_buffs(menu.menu_elements)
        end)
        
        if buff_success and buff_managed then
            -- Buff management took action, skip the rest of this frame
            return
        end
    end
    
    -- Position optimization if enabled and we're not casting
    if menu.menu_elements.position_optimization and menu.menu_elements.position_optimization:get() and current_time > cast_end_time then
        -- Wrap position optimization in pcall to prevent script errors
        local position_result = { should_move = false }
        local position_success = pcall(function()
            position_result = enhancements_manager.optimize_position(menu.menu_elements)
        end)
        
        if position_success and position_result and position_result.should_move then
            -- Temporarily disable orbwalker movement blocking
            orbwalker.set_block_movement(false)
            -- Let the script handle movement this frame
            return
        end
    end

    -- Check auto-play objective to adapt behavior
    if my_utility.is_auto_play_enabled() then
        local current_objective = auto_play.get_objective()
        
        -- Skip combat logic for non-combat objectives
        if current_objective == objective.loot then
            -- Only handle loot functionality
            local nearby_items = loot_manager.get_all_items_chest_sort_by_distance()
            for _, item in ipairs(nearby_items) do
                if loot_manager.is_lootable_item(item, false, false) then
                    loot_manager.loot_item_orbwalker(item)
                    return
                end
            end
            return
        elseif current_objective == objective.sell or current_objective == objective.repair then
            -- Skip combat rotation during selling/repairing
            return
        elseif current_objective == objective.travel then
            -- During travel, only use mobility spells and avoid combat
            if spells.evade and spells.evade.out_of_combat and current_time - _G.last_dash_time > 5.0 then
                spells.evade.out_of_combat()
            end
            return
        end
        -- Continue with combat rotation for objective.fight
    end

    -- Target selection setup with improved cached targeting
    local player_position = get_player_position()
    local target_list = {}
    local target_evaluation = {}
    
    if current_time >= next_target_update_time then
        -- Only run heavy targeting operations when necessary
        max_targeting_range = menu.menu_elements.max_targeting_range:get()
        targeting_refresh_interval = menu.menu_elements.targeting_refresh_interval:get()
        
        collision_table = {false, 1.0}
        floor_table = {true, 3.0}
        angle_table = {false, 90.0}

        target_list = my_target_selector.get_target_list(
        player_position,
            max_targeting_range,
        collision_table,
        floor_table,
        angle_table)

        target_selector_data_all = my_target_selector.get_target_selector_data(
        player_position,
            target_list)
            
        -- Get all targeting information
        local melee_range = (menu.menu_elements.mode:get() <= 0) and 9.0 or 2.0
        target_evaluation = evaluate_targets(target_list, melee_range)
        
        -- Cache results
        best_ranged_target = target_evaluation.best_ranged_target
        best_melee_target = target_evaluation.best_melee_target
        best_cursor_target = target_evaluation.best_cursor_target
        closest_cursor_target = target_evaluation.closest_cursor_target
        closest_cursor_target_angle = target_evaluation.closest_cursor_target_angle
        ranged_max_score = target_evaluation.ranged_max_score
        melee_max_score = target_evaluation.melee_max_score
        cursor_max_score = target_evaluation.cursor_max_score
        
        next_target_update_time = current_time + targeting_refresh_interval
    end

    if not target_selector_data_all or not target_selector_data_all.is_valid then
        return
    end

    -- Range setup based on mode
    local is_auto_play_active = auto_play.is_active()
    local max_range = 26.0
    local mode_id = menu.menu_elements.mode:get()
    local is_ranged = mode_id >= 1
    if mode_id <= 0 then -- melee
        max_range = 10.0
    end

    if is_auto_play_active then
        max_range = 12.0
    end

    -- Determine primary target based on configuration and context
    local best_target = nil
    local closest_target = target_selector_data_all.closest_unit
    
    if is_ranged then
        best_target = best_ranged_target
    else
        best_target = best_melee_target
    end
    
    if not best_target then
        best_target = closest_target
    end

    -- Heartseeker build check
    local spell_id_heartseeker = 363402
    local is_heartseeker_build = is_ranged and utility.is_spell_ready(spell_id_heartseeker)
    local is_best_target_exception = false

    if is_heartseeker_build and best_target then
        if best_target:is_vulnerable() then
            is_best_target_exception = true
        end

        if not is_best_target_exception then
            local buffs = best_target:get_buffs()
            if buffs then
                for _, debuff in ipairs(buffs) do
                    if debuff.name_hash == 39809 or debuff.name_hash == 298962 then
                        is_best_target_exception = true
                        break
                    end
                end
            end
        end
    end

    -- Momentum stacking phase (use dash and shadow step up to 3 times if not maxed)
    local max_momentum = 10 -- adjust if needed
    local stacks = get_momentum_stacks()
    
    -- Initial Momentum Stacking Phase
    if not _G.initial_momentum_stacked and stacks < max_momentum then
        -- Try to cast shadow step repeatedly until we reach 10 stacks
        if spells.shadow_step.logics(target_list, target_selector_data_all, best_target, closest_target) then
            _G.last_shadowstep_time = current_time
            cast_end_time = current_time + 0.2
            return
        end

        -- Try to use dash for momentum stacking
        if current_time - _G.last_dash_time > 0.2 and spells.dash.logics(best_target or closest_target) then
            _G.last_dash_time = current_time
            console.print("Used Dash for momentum stacking")
            cast_end_time = current_time + 0.2
            return
        end
        
        -- Important: Even if best_target or closest_target is nil, the improved evade.logics can handle it
        -- The evade.logics function now has fallback mechanisms if target is invalid
        if spells.evade.logics(best_target or closest_target) then
            console.print("Used Evade for momentum stacking")
            cast_end_time = current_time + 0.2
            return
        end
    elseif stacks >= max_momentum and not _G.initial_momentum_stacked then
        _G.initial_momentum_stacked = true
        console.print("Initial Momentum Stacking Complete!")
    end
    
    -- Health Potion Usage (for Unstable Elixirs) - use approximately every 30 seconds
    if _G.initial_momentum_stacked and current_time - _G.last_health_potion_time > 30 then
        if utility.use_health_potion() then
            _G.last_health_potion_time = current_time
        cast_end_time = current_time + 0.2
            return
        end
    end

    -- Core Pit Push Rotation - Following Mobalytics guide
    
    -- 1. Shadow Step - Every 8 seconds to maintain Close Quarter Combat
    if _G.initial_momentum_stacked and current_time - _G.last_shadowstep_time > 8.0 then
        if spells.shadow_step.logics(target_list, target_selector_data_all, best_target, closest_target) then
            _G.last_shadowstep_time = current_time
        cast_end_time = current_time + 0.2
        return
    end
    end
    
    -- 2. Penetrating Shot - Every 8 seconds to maintain Close Quarter Combat
    if _G.initial_momentum_stacked and current_time - _G.last_penetrating_shot_time > 8.0 then
        if spells.penetrating_shot.logics(target_list, target_selector_data_all, best_target) then
            _G.last_penetrating_shot_time = current_time
        cast_end_time = current_time + 0.3
        return
        end
    end

    -- 3. Poison Trap - Every 9 seconds
    if _G.initial_momentum_stacked and current_time - _G.last_poison_trap_time > 9.0 then
        if spells.poison_trap.logics(target_list, target_selector_data_all, best_target) then
            _G.last_poison_trap_time = current_time
            cast_end_time = current_time + 0.3
            return
        end
    end
    
    -- 4. Caltrop - Refresh before expiration (assuming ~5 second duration)
    -- Try to place it 1-2 seconds after Poison Trap for best synergy
    local caltrop_timing = math.min(5.0, current_time - _G.last_poison_trap_time - 1.5)
    if _G.initial_momentum_stacked and (current_time - _G.last_caltrop_time > caltrop_timing) then
        if spells.caltrop and spells.caltrop.logics and spells.caltrop.logics(best_target) then
            _G.last_caltrop_time = current_time
            cast_end_time = current_time + 0.3
            return
        end
    end

    -- 5. Concealment → Death Trap loop (primary damage dealers)
    if _G.initial_momentum_stacked then
        -- Try Concealment first (if not recently used)
        if current_time - _G.last_concealment_time > 0.5 and spells.concealment.logics() then
            _G.last_concealment_time = current_time
            cast_end_time = current_time + 0.6
            return
        end

        -- Death Trap (main damage dealer)
        if current_time - _G.last_death_trap_time > 0.05 and spells.death_trap.logics(target_list, target_selector_data_all, best_target) then
            _G.last_death_trap_time = current_time
            cast_end_time = current_time + 0.05
            return
        end
    end

    -- Main spell rotation with prioritization
    -- Iterate through spell priority list for better organized rotation
    for _, spell_name in ipairs(spell_priority) do
        local spell = spells[spell_name]
        if not spell or not spell.logics then
            goto continue
        end
        
        -- Skip if spell isn't enabled or loaded
        if spell.menu_elements and not spell.menu_elements.main_boolean:get() then
            goto continue
        end
        
        -- Different spell types have different parameter requirements
        local result = false
        
        if spell_name == "shadow_clone" then
            result = spell.logics(closest_target)
            if result then
                cast_end_time = current_time + 0.4
        return
    end
        elseif spell_name == "shadow_imbuement" or 
               spell_name == "poison_imbuement" or 
               spell_name == "cold_imbuement" or
               spell_name == "dark_shroud" or
               spell_name == "concealment" or
               spell_name == "dance_of_knives" then
            -- Self-cast spells
            result = spell.logics()
            if result then
        cast_end_time = current_time + 0.3
                if spell_name == "concealment" then
                    _G.last_concealment_time = current_time
                    cast_end_time = current_time + 0.6
                end
        return
    end
        elseif spell_name == "death_trap" or
               spell_name == "poison_trap" or
               spell_name == "smoke_grenade" or
               spell_name == "penetrating_shot" or
               spell_name == "rain_of_arrows" or
               spell_name == "caltrop" then
            -- Area spells that need target_list and data
            result = spell.logics(target_list, target_selector_data_all, best_target)
            if result then
                cast_end_time = current_time + (spell_name == "death_trap" and 0.05 or 0.3)
                if spell_name == "death_trap" then
                    _G.last_death_trap_time = current_time
                end
        return
    end
        elseif spell_name == "shadow_step" then
            -- Special case for shadow step
            result = spell.logics(target_list, target_selector_data_all, best_target, closest_target)
            if result then
                cast_end_time = current_time + 0.2
                return
            end
        elseif spell_name == "evade" then
            -- Special case for evade
            result = spell.logics(best_target)
            if result then
                cast_end_time = current_time + 0.2
                return
            end
        elseif spell_name == "dash" then
            -- Special case for dash
            result = spell.logics(best_target)
            if result then
                _G.last_dash_time = current_time
                cast_end_time = current_time + 0.2
                return
            end
        elseif spell_name == "heartseeker" then
            -- Special case for heartseeker that uses sorted entity list
            if is_best_target_exception then
    local sorted_entities = {}
                for i, v in ipairs(target_list) do
        sorted_entities[i] = v
    end

    table.sort(sorted_entities, function(a, b)
        return my_target_selector.get_unit_weight(a) > my_target_selector.get_unit_weight(b)
    end)

    for _, unit in ipairs(sorted_entities) do
                    if spell.logics(unit) then
                        _G.last_heartseeker_cast_time = current_time
                        cast_end_time = current_time + spell.menu_elements_heartseeker_base.spell_cast_delay:get()
                        return
                    end
                end
            end
        else
            -- Standard target spells
            result = spell.logics(best_target)
            if result then
                cast_end_time = current_time + 0.3
            return
        end
        end
        
        ::continue::
    end

    -- Auto-play movement logic
    if current_time >= can_move and my_utility.is_auto_play_enabled() then
        local is_dangerous = false
        -- Safely check if evade has is_dangerous_position function
        if spells.evade and type(spells.evade.is_dangerous_position) == "function" then
            is_dangerous = spells.evade.is_dangerous_position(player_position)
        end
        
        if not is_dangerous then
            local closer_target = target_selector.get_target_closer(player_position, 15.0)
            if closer_target then
                local move_pos = closer_target:get_position():get_extended(player_position, 4.0)
                if pathfinder.move_to_cpathfinder(move_pos) then
                    can_move = current_time + 1.50
                end
            end
        end
    end

    -- Out of combat evade
    if spells.evade and spells.evade.menu_elements and spells.evade.menu_elements.use_out_of_combat:get() then
        if spells.evade.out_of_combat() then
                    return
        end
    end
    
    -- Enhanced loot management during combat
    if _G.initial_momentum_stacked and menu.menu_elements.main_boolean:get() then
        -- Attempt to loot potions if needed
        if loot_manager.is_potion_necessary() then
            local nearby_items = loot_manager.get_all_items_chest_sort_by_distance()
            for _, item in ipairs(nearby_items) do
                if loot_manager.is_potion(item) and loot_manager.is_lootable_item(item, false, true) then
                    local item_pos = item:get_position()
                    if player_position:dist_to(item_pos) < 4.0 then
                        if loot_manager.loot_item(item, false, true) then
                            console.print("Looted potion during combat")
                            _G.last_health_potion_time = current_time
                            return
                        end
                    end
                end
            end
        end
        
        -- Check for high-value items (gold, obols) in close proximity
        local nearby_items = loot_manager.get_all_items_chest_sort_by_distance()
        for _, item in ipairs(nearby_items) do
            if (loot_manager.is_gold(item) or loot_manager.is_obols(item)) and 
               not evade.is_dangerous_position(player_position) then
                local item_pos = item:get_position()
                if player_position:dist_to(item_pos) < 2.0 then
                    if loot_manager.loot_item(item, true, false) then
                        console.print("Looted currency during combat")
                        return
                    end
                end
            end
        end
    end
end)

-- Enhanced rendering logic
on_render(function()
    if not menu.menu_elements.main_boolean:get() or not menu.menu_elements.enable_debug:get() then
        return
    end

    local local_player = get_local_player()
    if not local_player then
        return
    end

    local player_position = local_player:get_position()
    local player_screen_position = graphics.w2s(player_position)
    if player_screen_position:is_zero() then
        return
    end

    -- Draw player range circles
    if menu.menu_elements.draw_max_range:get() then
        graphics.circle_3d(player_position, menu.menu_elements.max_targeting_range:get(), color_white(85), 3.5, 144)
    end
    
    if menu.menu_elements.draw_melee_range:get() then
        graphics.circle_3d(player_position, 7.0, color_white(85), 2.5, 144)
    end

    -- Draw cursor target radius
    if menu.menu_elements.draw_cursor_target:get() then
        local cursor_position = get_cursor_position()
        graphics.circle_3d(cursor_position, menu.menu_elements.cursor_targeting_radius:get(), color_yellow(85), 1.0, 72)
    end

    -- Draw enemy circles and positions
    if menu.menu_elements.draw_enemy_circles:get() then
        for _, obj in ipairs(actors_manager.get_enemy_npcs()) do
            local position = obj:get_position()
            graphics.circle_3d(position, 1, color_white(100))
            graphics.circle_3d(prediction.get_future_unit_position(obj, 0.4), 0.5, color_yellow(100))
        end
    end

    -- Draw targets
    if menu.menu_elements.draw_targets:get() then
        -- Draw best ranged target
        if best_ranged_target then
            graphics.circle_3d(best_ranged_target:get_position(), 1.5, color_green(150), 2.0, 36)
        end
        
        -- Draw best melee target
        if best_melee_target then
            graphics.circle_3d(best_melee_target:get_position(), 1.5, color_blue(150), 2.0, 36)
        end
        
        -- Draw cursor targets
        if best_cursor_target then
            graphics.circle_3d(best_cursor_target:get_position(), 1.5, color_purple(150), 2.0, 36)
        end
        
        if closest_cursor_target then
            graphics.circle_3d(closest_cursor_target:get_position(), 1.5, color_red(150), 2.0, 36)
        end
    end

    -- Call enhanced rendering if debug is enabled
    enhancements_manager.on_render(menu.menu_elements)
end);

console.print("Rogue Death Trap Smoke Enhanced | Pit Push Rotation | Version 1")