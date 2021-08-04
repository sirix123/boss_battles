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
        description: "You will mark a location on the floor at the end of the duration."
    });
    Modifiers.push({
        modifier_classname: "biting_frost_modifier_debuff",
        name: "Icebite",
        description: "Taking stacking damage per second that is dealt to all nearby targets. Can be cleansed by fire."
    });
    Modifiers.push({
        modifier_classname: "fire_ele_melt_debuff",
        name: "Melted armor",
        description: "Your armour is reduced, increasing damage taken."
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
