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
        modifier_classname: "modifier_sticky_bomb",
        name: "Sticky Bomb",
        description: "Damage dealt by the bomb is spread evenly across all targets."
    });
    Modifiers.push({
        modifier_classname: "modifier_electric_vortex",
        name: "Stasis pull",
        description: "You are being pulled towards the trap."
    });
    Modifiers.push({
        modifier_classname: "blast_off_fog_modifier",
        name: "Blast off smoke",
        description: "Your vision is heavily reduced."
    });
    Modifiers.push({
        modifier_classname: "generic_cube_bomb_modifier",
        name: "Deadly looking cube",
        description: "You must find the location marked to dispell this."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
