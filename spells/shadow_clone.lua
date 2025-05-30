local my_utility = require("my_utility/my_utility")
-- Add enhanced targeting and enhancements manager
local enhanced_targeting = require("my_utility/enhanced_targeting")
local enhancements_manager = require("my_utility/enhancements_manager")
local menu_module = require("menu")

local menu_elements_shadow_clone_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "shadow_clone_main_bool_base")),
    spell_range   = slider_float:new(1.0, 15.0, 2.60, get_hash(my_utility.plugin_label .. "shadow_clone_spell_range")),
    spell_radius  = slider_float:new(1.0, 8.0, 4.0, get_hash(my_utility.plugin_label .. "shadow_clone_spell_radius")),
}

local function menu()
    
    if menu_elements_shadow_clone_base.tree_tab:push("Shadow Clone")then
        menu_elements_shadow_clone_base.main_boolean:render("Enable Spell", "")
        menu_elements_shadow_clone_base.spell_range:render("Spell Range", "", 1)
        menu_elements_shadow_clone_base.spell_radius:render("Clone Effect Radius", "Estimated area of effect for the clone", 1)
 
        menu_elements_shadow_clone_base.tree_tab:pop()
    end
end

local spell_id_shadow_clone = 357628;
local next_time_allowed_cast = 0.0;
local last_cast_position = nil;

local function logics(target)
    
    local menu_boolean = menu_elements_shadow_clone_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shadow_clone);

    if not is_logic_allowed then
        return false;
    end;

    -- Validate target
    if not target then
        return false
    end

    -- Get spell parameters
    local spell_range = menu_elements_shadow_clone_base.spell_range:get()
    local spell_radius = menu_elements_shadow_clone_base.spell_radius:get()
    
    -- Update spell range info for visualization
    enhancements_manager.update_spell_range("shadow_clone", spell_range, spell_radius, last_cast_position)

    -- Get target properties safely
    local is_exception = false
    local target_position = nil
    
    pcall(function()
        is_exception = target:get_current_health() < target:get_max_health() and target:is_boss()
        target_position = target:get_position()
    end)
    
    if not target_position then
        return false
    end
    
    local player_position = get_player_position()
    if not player_position then
        return false
    end
    
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) and not is_exception then
        return false
    end

    -- Check if enhanced targeting is enabled and try to use it
    if menu_module and menu_module.menu_elements and 
       menu_module.menu_elements.enhanced_targeting and 
       menu_module.menu_elements.enhanced_targeting:get() and 
       menu_module.menu_elements.aoe_optimization and
       menu_module.menu_elements.aoe_optimization:get() then
        
        local enemies = {}
        pcall(function()
            enemies = utility.get_units_inside_circle_list(player_position, spell_range) or {}
        end)
        
        -- If we have at least one enemy (plus the target)
        if #enemies > 0 then
            local success, hit_count = false, 0
            pcall(function()
                success, hit_count = enhanced_targeting.optimize_aoe_positioning(
                    spell_id_shadow_clone, 
                    spell_radius, 
                    1
                )
            end)
            
            if success then
                local current_time = get_time_since_inject()
                next_time_allowed_cast = current_time + 0.6
                last_cast_position = target_position
                console.print(string.format("Rouge Plugin: Casted Shadow Clone using enhanced targeting, affecting ~%d enemies", hit_count))
                return true
            end
        end
    end

    -- Safe cast with error handling
    local cast_success = false
    pcall(function()
        cast_success = cast_spell.position(spell_id_shadow_clone, target_position, 0.6)
    end)
    
    if cast_success then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.6;
        last_cast_position = target_position;
        console.print("Rouge, Casted Shadow Clone");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}