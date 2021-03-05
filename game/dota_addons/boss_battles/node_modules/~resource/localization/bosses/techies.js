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
        description: "This bomb splits damage with all surrounding players."
    });
    Modifiers.push({
        modifier_classname: "modifier_electric_vortex",
        name: "Stasis pull",
        description: "Pulls target towards the stasis trap."
    });
    Modifiers.push({
        modifier_classname: "blast_off_fog_modifier",
        name: "Blast off smoke",
        description: "Vision reduced from blast off smoke."
    });
    Modifiers.push({
        modifier_classname: "generic_cube_bomb_modifier",
        name: "Deadly looking cube",
        description: "Quick find the diffuse location."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
