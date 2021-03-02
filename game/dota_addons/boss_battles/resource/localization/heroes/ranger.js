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
    // variables
    // modifiers
    Modifiers.push({
        modifier_classname: "q_smoke_bomb_modifier",
        name: "Evasive",
        description: "Provides increased movement speed and invulnerability.",
    });
    // abilities
    Abilities.push({
        ability_classname: "m1_combo_hit_1_2",
        name: "Slash",
        description: "Short range attack that deals damage in a cone. After 2 attacks this ability changes into another ability.",
        notes: [
            "This is a chain attack, after two attacks this ability changes into Lacerate.",
        ],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
