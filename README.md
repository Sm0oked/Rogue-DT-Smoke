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

## Recent Changes (Last Updated: 2023-07-11)

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

