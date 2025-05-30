local my_utility = require("my_utility/my_utility")

local enhanced_evade = {}

-- Define spell IDs
local shadow_step_spell_id = 420327
local dash_spell_id = 420268

function enhanced_evade.setup_evade(cooldown_seconds)
    -- First check if evade module exists
    if not evade then
        console.print("Rogue Plugin: Evade module not available")
        return false
    end
    
    -- Try to register a circular spell with evade
    local evade_initialized = false
    pcall(function()
        -- Use a unique ID for our test spell registration
        evade.register_circular_spell(0xDEADBEEF, 5.0, 0.5)
        evade_initialized = true
    end)
    
    if not evade_initialized then
        console.print("Rogue Plugin: Failed to initialize evade module - missing or incompatible evade module")
        return false
    end
    
    -- Set evade cooldown with error handling
    local cooldown_set = false
    pcall(function()
        evade.set_evade_cooldown(cooldown_seconds or 6)
        cooldown_set = true
    end)
    
    if not cooldown_set then
        console.print("Rogue Plugin: Warning - couldn't set evade cooldown")
    else
        console.print("Rogue Plugin: Evade module initialized successfully")
    end
    
    return true
end

function enhanced_evade.enhanced_evade_logics()
    -- Attempt to get dangerous areas
    local dangerous_areas = {}
    pcall(function()
        dangerous_areas = evade.get_dangerous_areas()
    end)
    
    if #dangerous_areas > 0 then
        local player_pos = get_player_position()
        
        -- Check if shadow step is available
        if utility.is_spell_ready(shadow_step_spell_id) then
            -- Find safe positions to shadow step to
            local safe_positions = {}
            local radius = 10.0
            local num_points = 12
            
            for i = 1, num_points do
                local angle = (i - 1) * (2 * math.pi / num_points)
                local x = player_pos:x() + radius * math.cos(angle)
                local y = player_pos:y() + radius * math.sin(angle)
                local test_pos = vec3.new(x, y, player_pos:z())
                
                -- Check if position is safe from all dangerous areas
                local is_safe = true
                for _, area in ipairs(dangerous_areas) do
                    if area:contains_point(test_pos) then
                        is_safe = false
                        break
                    end
                end
                
                if is_safe and utility.is_point_walkeable(test_pos) then
                    table.insert(safe_positions, test_pos)
                end
            end
            
            -- Use shadow step to teleport to safe position
            if #safe_positions > 0 then
                cast_spell.position(shadow_step_spell_id, safe_positions[1], 0.1)
                return true
            end
        end
        
        -- Try dash as a fallback
        if utility.is_spell_ready(dash_spell_id) then
            local current_time = get_time_since_inject()
            if not _G.last_dash_time or current_time - _G.last_dash_time > 5 then
                -- Find escape direction (away from danger)
                local escape_dir = vec3.new(0, 0, 0)
                for _, area in ipairs(dangerous_areas) do
                    pcall(function()
                        local area_center = area:get_center()
                        if not area_center then return end
                        
                        -- Safely calculate direction
                        local direction = nil
                        pcall(function()
                            direction = player_pos:subtract(area_center)
                            if direction and direction:length_3d() > 0 then
                                direction = direction:normalize()
                                escape_dir = escape_dir:add(direction)
                            end
                        end)
                    end)
                end
                
                if escape_dir:length_3d() > 0 then
                    escape_dir = escape_dir:normalize()
                    local dash_pos = player_pos:add(escape_dir:multiply(5.0))
                    
                    if utility.is_point_walkeable(dash_pos) then
                        if cast_spell.position(dash_spell_id, dash_pos, 0.1) then
                            _G.last_dash_time = current_time
                            return true
                        end
                    end
                end
            end
        end
        
        -- Fall back to regular evade if our skills aren't available
        local evade_successful = false
        pcall(function()
            evade_successful = evade.execute_evade()
        end)
        return evade_successful
    end
    
    return false
end

return enhanced_evade 