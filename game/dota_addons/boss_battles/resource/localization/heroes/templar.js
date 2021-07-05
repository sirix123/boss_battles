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
    // abilities
    Abilities.push({
        ability_classname: "templar_passive",
        name: "Mind over matter",
        description: "If you have enough mana the incoming damage will be reduced by x%.",
        ability_specials: [
            {
                ability_special: "mind_over_matter",
                text: "DAMAGE TAKEN FROM MANA:",
                percentage: true,
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
