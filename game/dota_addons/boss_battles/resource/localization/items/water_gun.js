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
    Abilities.push({
        ability_classname: "item_water_gun",
        name: "Water Gun",
        description: "Who left this water gun here...",
        notes: [
            "Shooting the water gun will remove oil and fire.",
            "Charges slowly replenish overtime.",
            "Cleaning fire and oil grants you a stacking outgoing damage buff.",
        ],
    });
    Modifiers.push({
        modifier_classname: "water_gun_dmg_buff",
        name: "Living water.",
        description: "All of your outgoing damage is increased by {".concat("MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE" /* LocalizationModifierProperty.TOTALDAMAGEOUTGOING_PERCENTAGE */, "}%.")
    });
    Modifiers.push({
        modifier_classname: "water_gun_dmg_debuff",
        name: "Your water gun has overheated",
        description: "You're on fire."
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
