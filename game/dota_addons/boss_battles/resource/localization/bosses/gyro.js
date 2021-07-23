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
        description: "You have a shield that absorbs damage."
    });
    Modifiers.push({
        modifier_classname: "fire_puddle_modifier",
        name: "Sticky fire",
        description: "You're on fire."
    });
    Modifiers.push({
        modifier_classname: "oil_puddle_slow_modifier",
        name: "Oil",
        description: "You're slowed by oil."
    });
    Modifiers.push({
        modifier_classname: "modifier_gyro_barrage_debuff",
        name: "Barrage",
        description: "Barrage damage reduced depending on how many players are nearby."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
