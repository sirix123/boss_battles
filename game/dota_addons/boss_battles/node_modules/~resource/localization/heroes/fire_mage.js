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
        ability_classname: "m1_beam",
        name: "Fire Beam",
        description: "Channel a fire beam to destroy your enemies. Mana and damage ramps up over 3seconds.",
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent",
                text: "MANA:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "m2_meteor",
        name: "Flash Flame",
        description: "After a short delay nuke all enemies in the area and apply fire weakness.",
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "fire_weakness_duration",
                text: "FIRE WEAKNESS DURATION:"
            },
            {
                ability_special: "fire_weakness_dmg_increase",
                text: "FIRE WEAKNESS DAMAGE INCREASE:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_fire_bubble",
        name: "Bubble",
        description: "Bubble a player blocking damage and burning units around them.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "bubble_amount",
                text: "BUBBLE AMOUNT:",
            },
            {
                ability_special: "burn_amount",
                text: "DAMAGE:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "e_fireball",
        name: "Fire ball",
        description: "channel a firestorm and shoot fireballs rapidly.",
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_remnant",
        name: "Fire remnant",
        description: "Summon a fire remnant that copies your spells.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
