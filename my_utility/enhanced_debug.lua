local my_utility = require("my_utility/my_utility")

local enhanced_debug = {}

function enhanced_debug.enhanced_debug_visualization(debug_enabled)
    if not debug_enabled then return end
    
    local player_position = nil
    
    -- Safely get player position
    local position_valid = pcall(function()
        player_position = get_player_position()
        if not player_position then error("Invalid player position") end
    end)
    
    if not position_valid or not player_position then
        return
    end
    
    -- Draw player info
    local player = nil
    local player_valid = pcall(function()
        player = get_local_player()
        if not player then error("Player is nil") end
        
        -- Try to access a method to verify player is valid
        if not player.get_position then error("Player object invalid") end
    end)
    
    if not player_valid or not player then 
        return 
    end
    
    -- Safely get health and energy values with pcall
    local health_percent = 1.0
    local energy_percent = 1.0
    
    -- Try different ways to get health/energy data
    local health_energy_success = false
    
    pcall(function()
        -- First attempt - standard way
        pcall(function()
            if player.get_health and player.get_max_health and
               player.get_energy and player.get_max_energy then
                
                local health = player:get_health()
                local max_health = player:get_max_health()
                local energy = player:get_energy()
                local max_energy = player:get_max_energy()
                
                -- Verify values are valid
                if health and max_health and max_health > 0 and
                   energy and max_energy and max_energy > 0 then
                    
                    health_percent = health / max_health
                    energy_percent = energy / max_energy
                    health_energy_success = true
                end
            end
        end)
        
        -- Second attempt - try alternative methods if first failed
        if not health_energy_success then
            pcall(function()
                if player.get_health_percent then
                    health_percent = player:get_health_percent()
                end
                
                if player.get_energy_percent then
                    energy_percent = player:get_energy_percent()
                end
                
                health_energy_success = true
            end)
        end
    end)
    
    -- Safely draw UI elements
    pcall(function()
        -- Draw health and energy bars
        local screen_pos = graphics.w2s(player_position)
        local bar_width = 100
        local bar_height = 10
        
        -- Health bar
        graphics.rect_filled(
            vec2.new(screen_pos:x() - bar_width/2, screen_pos:y() - 40),
            vec2.new(screen_pos:x() - bar_width/2 + bar_width * health_percent, screen_pos:y() - 40 + bar_height),
            color_green(200)
        )
        
        -- Energy bar
        graphics.rect_filled(
            vec2.new(screen_pos:x() - bar_width/2, screen_pos:y() - 25),
            vec2.new(screen_pos:x() - bar_width/2 + bar_width * energy_percent, screen_pos:y() - 25 + bar_height),
            color_blue(200)
        )
    end)
    
    -- Draw spell cooldowns for key spells
    pcall(function()
        local spell_ids = {
            {id = 421161, name = "Death Trap"},
            {id = 420327, name = "Shadow Step"},
            {id = 421064, name = "Smoke Grenade"},
            {id = 421062, name = "Poison Trap"}
        }
        
        for i, spell in ipairs(spell_ids) do
            local is_ready = utility.is_spell_ready(spell.id)
            local color = is_ready and color_green(255) or color_red(255)
            
            graphics.text_2d(spell.name, vec2.new(50, 100 + i * 20), 15, color)
        end
    end)
end

function enhanced_debug.draw_spell_areas(spell_ranges, debug_enabled)
    if not debug_enabled then return end
    
    local player_position = get_player_position()
    
    for spell_name, range in pairs(spell_ranges) do
        local radius = range.radius or 5.0
        local distance = range.range or 10.0
        local color = range.color or color_yellow(80)
        
        -- Draw spell range
        graphics.circle_3d(player_position, distance, color, 1)
        
        -- If there's a cast position, draw the effect area
        if range.last_cast_position then
            graphics.circle_3d(range.last_cast_position, radius, color_green(80), 1)
        end
    end
end

function enhanced_debug.draw_enemy_info(debug_enabled)
    if not debug_enabled then return end
    
    local player_position = get_player_position()
    local enemies = utility.get_units_inside_circle_list(player_position, 20.0)
    
    for _, enemy in ipairs(enemies) do
        local enemy_pos = enemy:get_position()
        local screen_pos = graphics.w2s(enemy_pos)
        local health_percent = enemy:get_health() / enemy:get_max_health()
        
        -- Draw enemy health bar
        local bar_width = 50
        local bar_height = 5
        
        graphics.rect_filled(
            vec2.new(screen_pos:x() - bar_width/2, screen_pos:y() - 20),
            vec2.new(screen_pos:x() - bar_width/2 + bar_width * health_percent, screen_pos:y() - 20 + bar_height),
            color_red(200)
        )
        
        -- Draw enemy type info
        local enemy_type = "Normal"
        local text_color = color_white(255)
        
        if enemy:is_boss() then
            enemy_type = "Boss"
            text_color = color_red(255)
        elseif enemy:is_elite() then
            enemy_type = "Elite"
            text_color = color_purple(255)
        elseif enemy:is_champion() then
            enemy_type = "Champion"
            text_color = color_orange(255)
        end
        
        graphics.text_2d(enemy_type, vec2.new(screen_pos:x() - 20, screen_pos:y() - 35), 12, text_color)
    end
end

function enhanced_debug.log_spell_cast(spell_name, target_info, hits)
    console.print(string.format("Rouge Plugin: Casted %s hitting ~%d enemies", spell_name, hits or 0))
    
    if target_info then
        console.print(string.format("Target: %s, Distance: %.2f", 
            target_info.name or "Unknown", 
            target_info.distance or 0))
    end
end

return enhanced_debug 