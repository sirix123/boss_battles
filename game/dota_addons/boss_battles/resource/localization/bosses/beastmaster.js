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
        modifier_classname: "beastmaster_mark_modifier",
        name: "Mark",
        description: "You're being hunted."
    });
    Modifiers.push({
        modifier_classname: "puddle_slow_modifier",
        name: "Slow",
        description: "You're being slowed by some sticky goo."
    });
    Modifiers.push({
        modifier_classname: "modifier_beastmaster_net",
        name: "Net",
        description: "You're trapped."
    });
    Modifiers.push({
        modifier_classname: "beastmaster_puddle_dot_debuff_attack_player_debuff",
        name: "Poison",
        description: "You're taking damage every second."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
