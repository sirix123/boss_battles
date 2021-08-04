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
        modifier_classname: "fire_cross_grenade_debuff",
        name: "Shield",
        description: "Absorbs incoming damage."
    });
    Modifiers.push({
        modifier_classname: "fire_puddle_modifier",
        name: "Sticky fire",
        description: "You are taking damage every second."
    });
    Modifiers.push({
        modifier_classname: "oil_puddle_slow_modifier",
        name: "Oil",
        description: "Your movement speed is reduced."
    });
    Modifiers.push({
        modifier_classname: "modifier_gyro_barrage_debuff",
        name: "Barrage",
        description: "You are taking damage spread evenly across all targets."
    });
    Modifiers.push({
        modifier_classname: "gyro_rocket_modifier",
        name: "Homing missile",
        description: "You are tracked by a homing missle that will target the closest unit."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
