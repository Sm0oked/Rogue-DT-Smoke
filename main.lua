local my_utility = require("my_utility/my_utility")
local my_target_selector = require("my_utility/my_target_selector")


local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_rouge = character_id == 3;
if not is_rouge then
 return
end;

local menu = require("menu");

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
    dash                    = require("spells/dash"),
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
    dance_of_knives        = require("spells/dance_of_knives"),
}

-- Initialize global spell tracking variables
if not _G.last_death_trap_time then _G.last_death_trap_time = 0 end
if not _G.last_concealment_time then _G.last_concealment_time = 0 end
if not _G.last_heartseeker_cast_time then _G.last_heartseeker_cast_time = 0 end

on_render_menu(function()
    if not menu.main_tree:push("Rogue: Death_Trap - Smoke") then
        return
    end

    menu.main_boolean:render("Enable Plugin", "")
    if menu.main_boolean:get() == false then
        menu.main_tree:pop()
        return
    end

    menu.cast_wait_boolean:render("Skill Cast Waiting", "")
    local options = {"Melee", "Ranged"}
    menu.mode:render("Mode", options, "")
    menu.dash_cooldown:render("Dash Cooldown", "")

    -- Render all spell menus
    for _, spell in pairs(spells) do
        if spell.menu then
            spell.menu()
        end
    end

    menu.main_tree:pop()
end)

local can_move = 0.0
local cast_end_time = 0.0
local cast_delay = 0.2
local glow_target = nil
local last_dash_cast_time = 0.0
global_poison_trap_last_cast_time = 0.0
global_poison_trap_last_cast_position = nil

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

on_update(function()
    local local_player = get_local_player()
    if not local_player or not menu.main_boolean:get() then
        return
    end

    local current_time = get_time_since_inject()

    if menu.cast_wait_boolean:get() then
        if current_time < cast_end_time then
            return
        end
    else
        if current_time < cast_delay then
            return
        end
    end

    cast_delay = current_time + 0.2

    if not my_utility.is_action_allowed() then
        return
    end

    -- Target selection setup
    local screen_range = 20.0
    local player_position = get_player_position()
    local collision_table = {false, 1.0}
    local floor_table = {true, 3.0}
    local angle_table = {false, 90.0}

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range,
        collision_table,
        floor_table,
        angle_table)

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position,
        entity_list)

    if not target_selector_data.is_valid then
        return
    end

    -- Range setup
    local is_auto_play_active = auto_play.is_active()
    local max_range = 26.0
    local mode_id = menu.mode:get()
    local is_ranged = mode_id >= 1
    if mode_id <= 0 then -- melee
        max_range = 7.0
    end

    if is_auto_play_active then
        max_range = 12.0
    end

    local best_target = my_target_selector.get_best_weighted_target(entity_list)
    local closest_target = target_selector_data.closest_unit

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
    if stacks < max_momentum then
        -- Try to cast dash first, then shadow step
        if spells.dash.logics(best_target or closest_target) then
            cast_end_time = current_time + 0.2
            return
        end
        if spells.shadow_step.logics(entity_list, target_selector_data, best_target, closest_target) then
            cast_end_time = current_time + 0.2
            return
        end
    end

    -- Main spell rotation
    -- High priority but controlled casting
    if spells.shadow_clone.logics(closest_target) then
        cast_end_time = current_time + 0.4
        return
    end

    -- Always cast shadow imbuement if available
    if spells.shadow_imbuement.logics() then
        cast_end_time = current_time + 0.2
        return
    end

    -- Death Trap with controlled frequency
    if spells.death_trap.logics(entity_list, target_selector_data, best_target) then
        cast_end_time = current_time + 0.05
        _G.last_death_trap_time = current_time
        return
    end

    -- Offensive abilities with higher priority
    if spells.rain_of_arrows.logics(best_target) then
        cast_end_time = current_time + 1.5
        return
    end

    if spells.dance_of_knives.logics() then
        cast_end_time = current_time + 0.3
        return
    end

    -- Concealment with controlled frequency
    local concealment_cooldown = 0.8
    if current_time - _G.last_concealment_time >= concealment_cooldown and math.random() > 0.4 then
        if spells.concealment.logics() then
            cast_end_time = current_time + 0.6
            _G.last_concealment_time = current_time
            return
        end
    end

    -- Mobility and utility spells
    if spells.caltrop.logics(entity_list, target_selector_data, closest_target) then
        cast_end_time = current_time + 0.2
        return
    end

    -- Add dash to main rotation after caltrop and before shadow step
    if spells.dash.logics(best_target or closest_target) then
        cast_end_time = current_time + 0.2
        return
    end

    if spells.shadow_step.logics(entity_list, target_selector_data, best_target, closest_target) then
        cast_end_time = current_time + 0.2
        return
    end

    -- Secondary abilities
    if spells.poison_trap.logics(entity_list, target_selector_data, best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if not is_heartseeker_exception then
        if spells.smoke_grenade.logics(entity_list, target_selector_data, best_target) then
            cast_end_time = current_time + 0.3
            return
        end

        if spells.dark_shroud.logics() then
            cast_end_time = current_time + 0.3
            return
        end
    end

    -- Basic damage abilities
    if spells.twisting_blade.logics(best_target) then
        cast_end_time = current_time + 0.2
        return
    end

    if spells.barrage.logics(best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if spells.rapid_fire.logics(best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if spells.flurry.logics(best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if spells.penetrating_shot.logics(entity_list, target_selector_data, best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    -- Basic attacks and fillers
    if spells.invigorating_strike.logics(best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if spells.blade_shift.logics(best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if spells.forcefull_arrow.logics(best_target) then
        cast_end_time = current_time + 0.3
        return
    end

    if spells.puncture.logics(best_target) then
        cast_end_time = current_time + 0.1
        return
    end

    -- Heartseeker logic
    if is_heartseeker_exception then
        if not any(entity_list, function(e) return e:is_boss() end) then
            evade.set_pause(0.2)
        end
    end

    -- Try Heartseeker on weighted targets
    local sorted_entities = {}
    for i, v in ipairs(entity_list) do
        sorted_entities[i] = v
    end

    table.sort(sorted_entities, function(a, b)
        return my_target_selector.get_unit_weight(a) > my_target_selector.get_unit_weight(b)
    end)

    for _, unit in ipairs(sorted_entities) do
        if spells.heartseeker.logics(unit) then
            last_heartseeker_cast_time = current_time
            cast_end_time = current_time + spells.heartseeker.menu_elements_heartseeker_base.spell_cast_delay:get()
            return
        end
    end

    -- Auto-play movement logic
    if current_time >= can_move and my_utility.is_auto_play_enabled() then
        local is_dangerous = evade.is_dangerous_position(player_position)
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

    -- If fighting a boss and nothing else was cast, use any available spell
    if best_target and best_target:is_boss() then
        -- Try to cast any spell available on the boss
        local spell_list = {
            spells.dash,
            spells.shadow_step,
            spells.caltrop,
            spells.poison_trap,
            spells.smoke_grenade,
            spells.dark_shroud,
            spells.concealment,
            spells.heartseeker,
            spells.shadow_imbuement,
            spells.death_trap
        }
        for _, spell in ipairs(spell_list) do
            if spell == spells.caltrop then
                if spell.logics(entity_list, target_selector_data, closest_target) then
                    cast_end_time = current_time + 0.2
                    return
                end
            else
                if spell.logics(best_target) then
                    cast_end_time = current_time + 0.2
                    return
                end
            end
        end
    end
end)

-- Rendering logic
local draw_player_circle = false
local draw_enemy_circles = false

on_render(function()
    if not menu.main_boolean:get() then
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

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end

    if draw_enemy_circles then
        for _, obj in ipairs(actors_manager.get_enemy_npcs()) do
            local position = obj:get_position()
            graphics.circle_3d(position, 1, color_white(100))
            graphics.circle_3d(prediction.get_future_unit_position(obj, 0.4), 0.5, color_yellow(100))
        end
    end
end)

console.print("Lua Plugin - Rogue: Death Trap | Smoke | Version 1")