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
    Modifiers.push({
        modifier_classname: "soul_crystals",
        name: "soul crystal",
        description: "yuve got a soul crystal."
    });
    Modifiers.push({
        modifier_classname: "space_disperse_modifier",
        name: "space_disperse_modifier",
        description: "invul running faster."
    });
    // abilities
    Abilities.push({
        ability_classname: "pugna_basic_attack",
        name: "Pugna basic",
        description: "Shoot your glizzy.",
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
            {
                ability_special: "mana_gain_percent",
                text: "ENERGY GAIN:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "pugna_m2",
        name: "Boomerang",
        description: "Lienar proj at 3 crystal stacks bounces/double casts.",
        notes: [],
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE EACH:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "soul_drain",
        name: "Soul drain",
        description: "Drains soul of enemy.",
        ability_specials: [
            {
                ability_special: "mana",
                text: "mana:"
            },
            {
                ability_special: "dmg",
                text: "dmg:",
            },
            {
                ability_special: "drain_tick_rate",
                text: "drain_tick_rate:",
            },
            {
                ability_special: "max_ticks",
                text: "max_ticks:",
            },
            {
                ability_special: "duration_buff_soul_crystal",
                text: "duration_buff_soul_crystal:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "e_magic_circle_pugna",
        name: "circle",
        description: "place cirlce on ground deals dmg",
        notes: [],
        ability_specials: [
            {
                ability_special: "radius",
                text: "radius:"
            },
            {
                ability_special: "duration",
                text: "duration:"
            },
            {
                ability_special: "dmg",
                text: "dmg:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_infest_pugna",
        name: "Infest",
        description: "Spit on target. All damage done during the duration is then dealt as a dot (damage / dot duration)",
        notes: [],
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "dot_duration",
                text: "DOT DURATION:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_disperse",
        name: "space_disperse",
        description: "go invul and move faster.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "movespeed_bonus_pct",
                text: "movespeed_bonus_pct:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "pugna_passive",
        name: "Pugna Passive",
        description: "Soul drain grants a soul crystal. Max 3 crystals. Each crystal grants 5% increased outgoing damage. Crystals have individual durations.",
        notes: [],
        ability_specials: []
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
