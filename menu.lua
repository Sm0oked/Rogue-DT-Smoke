local my_utility = require("my_utility/my_utility")

local menu_elements =
{
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean")),
    main_tree           = tree_node:new(0),
    mode                = combo_box:new(0, get_hash(my_utility.plugin_label .. "mode_melee_range")),
    evade_cooldown      = slider_int:new(0, 20, 6, get_hash(my_utility.plugin_label .. "evade_cooldown")),
    
    -- Advanced settings
    settings_tree       = tree_node:new(1),
    enemy_count_threshold = slider_int:new(1, 10, 1, get_hash(my_utility.plugin_label .. "enemy_count_threshold")),
    max_targeting_range = slider_int:new(5, 40, 30, get_hash(my_utility.plugin_label .. "max_targeting_range")),
    min_enemy_distance = slider_float:new(0.0, 15.0, 0.0, get_hash(my_utility.plugin_label .. "min_enemy_distance")),
    cursor_targeting_radius = slider_float:new(1.0, 10.0, 5.0, get_hash(my_utility.plugin_label .. "cursor_targeting_radius")),
    cursor_targeting_angle = slider_int:new(10, 180, 45, get_hash(my_utility.plugin_label .. "cursor_targeting_angle")),
    best_target_evaluation_radius = slider_float:new(1.0, 15.0, 5.0, get_hash(my_utility.plugin_label .. "best_target_evaluation_radius")),
    
    -- Debug options
    enable_debug = checkbox:new(false, get_hash(my_utility.plugin_label .. "enable_debug")),
    debug_tree = tree_node:new(2),
    draw_targets = checkbox:new(false, get_hash(my_utility.plugin_label .. "draw_targets")),
    draw_max_range = checkbox:new(false, get_hash(my_utility.plugin_label .. "draw_max_range")),
    draw_melee_range = checkbox:new(false, get_hash(my_utility.plugin_label .. "draw_melee_range")),
    draw_enemy_circles = checkbox:new(false, get_hash(my_utility.plugin_label .. "draw_enemy_circles")),
    draw_cursor_target = checkbox:new(false, get_hash(my_utility.plugin_label .. "draw_cursor_target")),
    targeting_refresh_interval = slider_float:new(0.1, 1.0, 0.2, get_hash(my_utility.plugin_label .. "targeting_refresh_interval")),
    
    -- Custom enemy weights
    custom_enemy_weights_tree = tree_node:new(2),
    custom_enemy_weights = checkbox:new(false, get_hash(my_utility.plugin_label .. "custom_enemy_weights")),
    enemy_weight_normal = slider_int:new(1, 10, 2, get_hash(my_utility.plugin_label .. "enemy_weight_normal")),
    enemy_weight_elite = slider_int:new(5, 30, 10, get_hash(my_utility.plugin_label .. "enemy_weight_elite")),
    enemy_weight_champion = slider_int:new(10, 50, 15, get_hash(my_utility.plugin_label .. "enemy_weight_champion")),
    enemy_weight_boss = slider_int:new(20, 100, 50, get_hash(my_utility.plugin_label .. "enemy_weight_boss")),
    enemy_weight_damage_resistance = slider_int:new(5, 50, 25, get_hash(my_utility.plugin_label .. "enemy_weight_damage_resistance")),
    
    -- Spell categories
    spells_tree = tree_node:new(1),
    disabled_spells_tree = tree_node:new(1),
}

local draw_targets_description = "Display target selection information"
local cursor_target_description = "Visualize cursor targeting radius"

return {
    menu_elements = menu_elements,
    draw_targets_description = draw_targets_description,
    cursor_target_description = cursor_target_description
}