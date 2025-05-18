
local my_utility = require("my_utility/my_utility")
local my_target_selector = require("my_utility/my_target_selector")

local menu_elements_death_trap =
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_trap_base")),
   
    trap_mode            = combo_box:new(0, get_hash(my_utility.plugin_label .. "trap_base_base")),
    keybind              = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "trap_base_keybind")),
    keybind_ignore_hits  = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hitstrap_base")),

    min_hits             = slider_int:new(1, 20, 1, get_hash(my_utility.plugin_label .. "min_hits_to_casttrap_base")),
    
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_trap_base")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.55, get_hash(my_utility.plugin_label .. "min_percentage_hits_trap_base")),
    spell_range          = slider_float:new(1.0, 15.0, 3.50, get_hash(my_utility.plugin_label .. "death_trap_spell_range_2")),
    spell_radius         = slider_float:new(0.50, 10.0, 5.50, get_hash(my_utility.plugin_label .. "death_trap_spell_radius_2")),
}

local function menu()
    if menu_elements_death_trap.tree_tab:push("Death Trap") then
        menu_elements_death_trap.main_boolean:render("Enable Spell", "");

        local options =  {"Auto", "Keybind"};
        menu_elements_death_trap.trap_mode:render("Mode", options, "");

        menu_elements_death_trap.keybind:render("Keybind", "");
        menu_elements_death_trap.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

        menu_elements_death_trap.min_hits:render("Min Hits", "");

        menu_elements_death_trap.allow_percentage_hits:render("Allow Percentage Hits", "");
        if menu_elements_death_trap.allow_percentage_hits:get() then
            menu_elements_death_trap.min_percentage_hits:render("Min Percentage Hits", "", 1);
        end       

        menu_elements_death_trap.spell_range:render("Spell Range", "", 1)
        menu_elements_death_trap.spell_radius:render("Spell Radius", "", 1)

        menu_elements_death_trap.tree_tab:pop();
    end
end

local death_trap_spell_id = 421161;
local next_time_allowed_cast = 0.01;

local function logics(entity_list, target_selector_data, best_target)
    local menu_boolean = menu_elements_death_trap.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                death_trap_spell_id);

    if not is_logic_allowed then
        return false;
    end;

    local player_position = get_player_position()
    local keybind_used = menu_elements_death_trap.keybind:get_state();
    local trap_mode = menu_elements_death_trap.trap_mode:get();
    if trap_mode == 1 and keybind_used == 0 then   
        return false;
    end;
    
    local spell_range = menu_elements_death_trap.spell_range:get()
    local spell_radius = menu_elements_death_trap.spell_radius:get()

    local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)
    if not area_data.main_target then
        return false;
    end

    local cast_position_a = area_data.main_target:get_position();
    local best_cast_data = my_utility.get_best_point(cast_position_a, spell_radius, area_data.victim_list);
 
    -- Check range only
    local closer_target_to_zone = nil
    local closest_distance_sqr = math.huge

    for _, victim in ipairs(best_cast_data.victim_list) do
        local victim_position = victim:get_position()
        local distance_sqr = player_position:squared_dist_to_ignore_z(victim_position)
        
        if distance_sqr < closest_distance_sqr then
            closer_target_to_zone = victim
            closest_distance_sqr = distance_sqr
        end
    end
    
    if closest_distance_sqr > (spell_range * spell_range) then
        return false;
    end

    local cast_position = best_cast_data.point
    if cast_spell.position(death_trap_spell_id, cast_position, 0.40) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.01;
            
        console.print("Rouge Plugin, Casted death Trap");
        return true;
    end
 
    return false;
end

return {
    menu = menu,
    logics = logics,   
}