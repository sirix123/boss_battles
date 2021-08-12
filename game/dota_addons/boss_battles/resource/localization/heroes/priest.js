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
    // variables
    var radianceColour = "<b><font color=\"#ffffff\">Radiance</font></b>";
    var apoColour = "<b><font color=\"#ffffff\">Apotheosis</font></b>";
    var redemColour = "<b><font color=\"#ffffff\">Redemption</font></b>";
    Modifiers.push({
        modifier_classname: "priest_inner_fire_modifier",
        name: "Grace",
        description: "Recieving healing from Nerif, gaining increased armour and damage."
    });
    Modifiers.push({
        modifier_classname: "space_angel_mode_modifier",
        name: "Apotheosis",
        description: "Ascended."
    });
    // abilities
    Abilities.push({
        ability_classname: "priest_basic",
        name: "Atonement",
        description: "Nerif judges his enemies, sending out a bolt of light that strikes the first target it hits",
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
        ability_classname: "priest_flash_heal",
        name: "Redemption",
        description: "Nerif reaches out to an ally, healing them.",
        notes: [],
        ability_specials: [
            {
                ability_special: "heal_amount",
                text: "HEAL:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "priest_holy_nova",
        name: "Radiance",
        description: "Nerif emits a wave of light, dealing damage to enemies and healing allies. The effect of " + radianceColour + " is reduced as the wave travels outwards.",
        notes: [
            "Radiance has a maximum radius of 450 and travels at a speed of 300 units.",
        ],
        ability_specials: [
            {
                ability_special: "heal_amount",
                text: "HEAL:"
            },
            {
                ability_special: "dmg",
                text: "DAMAGE",
            },
            {
                ability_special: "distance_multi",
                text: "DISTANCE MULTIPLIER:",
                percentage: true,
            },
        ]
    });
    Abilities.push({
        ability_classname: "priest_inner_fire",
        name: "Grace",
        description: "Nerif bestows a holy mark to an ally, allowing it to recieve half of all healing done and gaining an armour and damage bonus. Additionally, Nerif recieves mana for each enemy the target hits with a basic attack.",
        notes: [],
        ability_specials: [
            {
                ability_special: "healing_reduce_target",
                text: "HEALING AMOUNT",
                percentage: true,
            },
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "armor_inc",
                text: "ARMOUR:",
            },
            {
                ability_special: "dmg_inc",
                text: "DAMAGE BONUS:",
                percentage: true,
            },
            {
                ability_special: "mana_gain_amount_per_attack",
                text: "MANA GAIN:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "priest_holy_fire",
        name: "Condemn",
        description: "Nerif targets a targeted area, dealing damage after a short delay and damage over time to all enemies hit.",
        notes: [],
        ability_specials: [
            {
                ability_special: "dmg_explode",
                text: "INITIAL DAMAGE:"
            },
            {
                ability_special: "dmg_dot",
                text: "DAMAGE OVER TIME:",
            },
            {
                ability_special: "delay",
                text: "DELAY:",
            },
            {
                ability_special: "duration",
                text: "DURATION:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_angel_mode",
        name: "Apotheosis",
        description: "Nerif sends out a desperate prayer, becoming godlike for a brief period of time. During " + apoColour + ", Nerif's cooldowns, mana costs and cast points are reduced, as well as refreshing all charges of " + redemColour + " and increasing his movespeed.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "reduce_cps",
                text: "CASTPOINT REDUCTION:",
                percentage: true,
            },
            {
                ability_special: "reduce_cooldowns",
                text: "COOLDOWN REDUCTION:",
                percentage: true,
            },
            {
                ability_special: "reduce_mana_cost",
                text: "MANACOST REDUCTION:",
                percentage: true,
            },
            {
                ability_special: "movement_speed_buff",
                text: "MOVEMENT SPEED:",
                percentage: true,
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
