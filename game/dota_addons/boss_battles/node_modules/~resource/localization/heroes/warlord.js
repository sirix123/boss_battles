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
    var shatterColour = "<b><font color=\"#9af9e0\">Shatter</font></b>";
    // modifiers
    Modifiers.push({
        modifier_classname: "e_spawn_ward_buff",
        name: "Warcry",
        description: "Reduces damage taken by {" + "MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE" /* INCOMING_DAMAGE_PERCENTAGE */ + "}% and provides {" + "MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT" /* HEALTH_REGEN_CONSTANT */ + "} health regen to everyone inside the shouts radius.",
    });
    Abilities.push({
        ability_classname: "m1_sword_slash",
        name: "Sword Slash",
        description: "Slash the enemy with your sword, generating energy.",
        notes: [],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "m2_sword_slam",
        name: "Sword Slam",
        description: "Slam the sword in a line with your sword, dealing damage to all enemies caught in its path. Applies a buff to the caster increasing the damage delt by Sword Slam.",
        notes: [],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
