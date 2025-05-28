# Rogue-DeathTrap Smoke Enhanced

## Major Enhancements

1. **Advanced Targeting System:**
   - Improved target selection with weighted scoring based on enemy types
   - Target caching to reduce performance impact
   - Multiple targeting modes (ranged, melee, cursor-based)
   - Better enemy prioritization for AoE abilities

2. **Enhanced Menu System:**
   - Comprehensive settings panel for fine-tuning all aspects
   - Debug visualization options for targeting and range indicators
   - Organized spell categories (equipped vs. inactive)
   - Custom enemy weighting options

3. **Optimized Spell Prioritization:**
   - Structured spell priority system based on effectiveness
   - Smarter casting logic for situational spells
   - Better buff and debuff tracking
   - Improved resource management

4. **Performance Improvements:**
   - Cached targeting to reduce CPU usage
   - Configurable targeting refresh rate
   - Optimized spell evaluation logic

5. **Momentum Management:**
   - Smart stacking of Momentum buff for maximum damage output
   - Automatic Dash and Shadow Step usage for Momentum generation
   - Priority-based spell casting that respects Momentum mechanics

6. **Enhanced Visualization:**
   - Debug mode with visual indicators for targeting
   - Range indicators for abilities
   - Target highlighting based on priority

7. **Customizable Enemy Scoring:**
   - Configurable weights for different enemy types
   - Special handling for elites, champions, and bosses
   - Bonus scoring for vulnerable enemies

## Recent Changes

### Latest Updates (Last Updated: 2025-05-27)

1. **Boss Enemy Exception Added:**
   - Added logic to bypass minimum enemy count threshold when a boss is present
   - Ensures optimal spell usage during boss fights even with strict minimum enemy count settings
   - Implemented consistently across all spell files (Death Trap, Poison Trap, etc.)
   - Works alongside existing keybind override functionality

2. **Fixed Minimum Enemy Count Threshold:**
   - Resolved the issue where spells would ignore the minimum enemy count setting when elite/champion enemies were present
   - Implemented consistent enemy count checking across all spells (Death Trap, Poison Trap, Caltrop, Dance of Knives, Rain of Arrows, Penetrating Shot)
   - Added debugging output for easier verification of enemy counting
   - Maintained keybind override functionality for manual casting regardless of enemy count

3. **Enhanced Error Handling:**
   - Improved error checking for evade spell registration
   - Added robust error handling with pcall to prevent crashes
   - Enhanced error reporting for easier troubleshooting
   - Better parameter validation for all spell functions

4. **Targeting System Refinements:**
   - Fixed edge cases in target evaluation logic
   - Improved filtering of invalid targets
   - Better handling of targeting when minimum enemy count isn't met
   - More consistent application of enemy count threshold across all spells

5. **Performance Optimization:**
   - Reduced unnecessary spell evaluations
   - Implemented early returns when minimum enemy count isn't met
   - More efficient enemy counting with cached results
   - Better resource management during spell evaluation

1. **Advanced Enemy Targeting:**
   - Added weighted targeting system with enemy cluster detection
   - Improved targeting for multi-enemy situations
   - Better prioritization of dangerous enemies

2. **Enhanced Spell Management:**
   - Improved channeled spell handling for Dance of Knives
   - Dynamic position updating during channel
   - Automatic pause when in dangerous areas

3. **Auto-Play Intelligence:**
   - Added awareness of auto-play objectives
   - Script adapts behavior based on current objective (combat, looting, travel)
   - Improved mobility during travel objectives

4. **Loot Management:**
   - Automatic pickup of potions during combat when needed
   - Collection of high-value items (gold, obols) in close proximity
   - Integration with health potion tracking

5. **Terrain Navigation:**
   - Added walkability checks before casting positional abilities
   - Automatic detection of inaccessible areas
   - Finding alternative cast positions when primary target is unwalkable

6. **Boss Ability Recognition:**
   - Added detection for common dangerous boss abilities
   - Registered specific evade patterns for Butcher and Ashava abilities
   - Improved avoidance of circular and rectangular danger zones

7. **Error Resilience:**
   - Added robust error handling for spell registration
   - Graceful handling of API changes
   - Detailed error reporting for easier troubleshooting

### Previous Update (Last Updated: 2023-07-11)

1. **Improved Evade Functionality:**
   - Fixed momentum stacking with more robust evade implementation
   - Added fallback mechanisms when target is nil or invalid
   - Enhanced error handling to prevent casting failures
   - Improved feedback via console messages for tracking stacking progress

2. **Debug Enhancements:**
   - Added comprehensive debug output for evade spell
   - Enabled debug by default for easier troubleshooting
   - Added menu option to toggle debug information

3. **Quality of Life Improvements:**
   - Added confirmation messages for momentum stacking
   - Added completion notification when momentum stacking is finished
   - Better safety checks for spell casting
   - Re-added Dash ability to rotation for improved mobility

4. **Targeting Improvements:**
   - Added minimum enemy distance setting to maintain safer positioning
   - Removed boss-specific targeting priority for more consistent rotation
   - Improved target selection based on minimum distance requirements

## Usage Guide

1. **Basic Setup:**
   - Enable the plugin and select your preferred mode (Melee or Ranged)
   - Adjust the Dash Cooldown setting based on your preferences

2. **Advanced Configuration:**
   - Fine-tune targeting settings in the Settings panel
   - Customize enemy weights for your preferred playstyle
   - Enable debug visualization options to better understand targeting

3. **Spell Customization:**
   - All spells can be individually configured in the Equipped Spells menu
   - Disable or adjust specific abilities as needed
   - Inactive spells are accessible in a separate menu for quick enabling

4. **Playstyle Adaptation:**
   - The script will automatically adapt to your equipped spells
   - Customize the script behavior based on your preferred build

## Compared to Previous Version

This enhanced version maintains all the functionality of the original Death_Trap - Smoke script while adding:
   - More robust targeting with better performance
   - Enhanced spell prioritization
   - Comprehensive customization options
   - Better visualization and debugging tools
   - Improved overall consistency and effectiveness

