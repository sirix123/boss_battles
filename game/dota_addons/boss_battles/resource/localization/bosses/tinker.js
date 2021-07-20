"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenerateLocalizationData = void 0;
function GenerateLocalizationData() {
    // This section can be safely ignored, as it is only logic.
    //#region Localization logic
    // Arrays
    var Abilities = new Array();
    var Modifiers = new Array();
    var StandardTooltips = new Array();
    // Create object of arrays
    var localization_info = {
        AbilityArray: Abilities,
        ModifierArray: Modifiers,
        StandardArray: StandardTooltips,
    };
    //#endregion
    // modifiers
    Modifiers.push({
        modifier_classname: "phase_2_crystal_spawn_modifier",
        name: "Crystal Growth",
        description: "At the end of the duration you will spawn a crystal."
    });
    Modifiers.push({
        modifier_classname: "biting_frost_modifier_debuff",
        name: "Icebite",
        description: "Taking damage per second. Stacks. Does damage in a radius around you. Can be cleansed by fire..."
    });
    Modifiers.push({
        modifier_classname: "fire_ele_melt_debuff",
        name: "Melted armor",
        description: "Your armor is being melted."
    });
    Modifiers.push({
        modifier_classname: "modifier_generic_silenced",
        name: "Silenced",
        description: "You cannot cast any abilities."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
