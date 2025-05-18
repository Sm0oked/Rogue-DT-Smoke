local my_utility = require("my_utility/my_utility")
local poison_imbuement = require("spells/poison_imbuement")
local cold_imbuement = require("spells/cold_imbuement")

local shadow_imbuement_menu_elements_base =
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_shadow_base")),
    priority_mode      = combo_box:new(0, get_hash(my_utility.plugin_label .. "shadow_imbuement_priority")),
    min_enemies        = slider_int:new(1, 5, 1, get_hash(my_utility.plugin_label .. "shadow_imbuement_min_enemies"))
}

local function menu()
    if shadow_imbuement_menu_elements_base.main_tab:push("Shadow Imbuement") then
        shadow_imbuement_menu_elements_base.main_boolean:render("Enable Spell", "")
        if shadow_imbuement_menu_elements_base.main_boolean:get() then
            local options = {"Always", "Elite/Boss Only", "Boss Only"}
            shadow_imbuement_menu_elements_base.priority_mode:render("Usage Priority", options, "When to use Shadow Imbuement")
            shadow_imbuement_menu_elements_base.min_enemies:render("Minimum Enemies", "Minimum enemies in range to cast")
        end
        shadow_imbuement_menu_elements_base.main_tab:pop()
    end
end

local spell_id_shadow_imb = 380288
local next_time_allowed_cast = 0.0

local function is_active()
    local local_player = get_local_player()
    local buffs = local_player:get_buffs()

    for i, buff in ipairs(buffs) do
        if buff.name_hash == spell_id_shadow_imb then
            return true
        end
    end

    return false
end

local function logics()
    -- Basic checks
    local current_time = get_time_since_inject()
    local menu_boolean = shadow_imbuement_menu_elements_base.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean,
        next_time_allowed_cast,
        spell_id_shadow_imb)

    if not is_logic_allowed or is_active() or
       poison_imbuement.is_active() or poison_imbuement.will_cast() or
       cold_imbuement.is_active() or cold_imbuement.will_cast() then
        return false
    end

    -- Check nearby enemies
    local player_position = get_player_position()
    local enemies = actors_manager.get_enemy_npcs()
    local nearby_enemies = 0
    local has_elite = false
    local has_boss = false

    for _, enemy in ipairs(enemies) do
        if enemy:get_position():squared_dist_to_ignore_z(player_position) <= (8.0 * 8.0) then
            nearby_enemies = nearby_enemies + 1
            if enemy:is_elite() then has_elite = true end
            if enemy:is_boss() then has_boss = true end
        end
    end

    -- Check conditions based on priority mode
    local priority_mode = shadow_imbuement_menu_elements_base.priority_mode:get()
    local min_enemies = shadow_imbuement_menu_elements_base.min_enemies:get()

    if nearby_enemies < min_enemies then
        return false
    end

    if priority_mode == 1 and not (has_elite or has_boss) then
        return false
    end

    if priority_mode == 2 and not has_boss then
        return false
    end

    -- Cast attempt
    if cast_spell.self(spell_id_shadow_imb, 0.0) then
        next_time_allowed_cast = current_time + 0.2
        console.print("Rouge Plugin, Casted Shadow Imbuement")
        return true
    end
        
    return false
end

return 
{
    menu = menu,
    logics = logics,
    is_active = is_active,
}