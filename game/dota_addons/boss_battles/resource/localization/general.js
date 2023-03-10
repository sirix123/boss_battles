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
    // Enter localization data below! 
    StandardTooltips.push({
        classname: "addon_game_name",
        name: "Boss Battles"
    });
    Modifiers.push({
        modifier_classname: "modifier_grace_period",
        name: "Grace Period",
        description: "You've just respawned, you're invulnerable."
    });
    Modifiers.push({
        modifier_classname: "modifier_generic_stunned",
        name: "Stunned",
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
