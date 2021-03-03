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
        modifier_classname: "modifier_sprint",
        name: "Sprint",
        description: "Sprinting.",
    });
    // abilities
    Abilities.push({
        ability_classname: "m1_trackingshot",
        name: "Tracking shot",
        description: "Shoot an arrow, damaging them for a base amount. Arrow does more damage if you're further away from the target.",
        ability_specials: [
            {
                ability_special: "base_dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "dmg_dist_multi",
                text: "DISTANCE MULTIPLIER:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
            {
                ability_special: "mana_gain_percent",
                text: "MANA GAIN:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "m2_serratedarrow",
        name: "Power shot",
        description: "Shoot an arrow, damaging them for a base amount. Arrow does more damage if you're further away from the target. Each enemy Power shot hits decreases the damage to the next target.",
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "dmg_dist_multi",
                text: "DISTANCE MULTIPLIER:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
            {
                ability_special: "mana_gain_percent",
                text: "MANA GAIN:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_healing_arrow_v2",
        name: "Healing arrow",
        description: "Fire an arrow at an ally. If the projectile hits it heals them. The further you are away when the arrow is cast the more healing it will do.",
        ability_specials: [
            {
                ability_special: "heal",
                text: "HEAL:"
            },
            {
                ability_special: "heal_dist_multi",
                text: "DISTANCE MULTIPLIER:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
            {
                ability_special: "mana_gain_per_hit",
                text: "MANA GAIN PER HIT:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "e_whirling_winds",
        name: "Whirling winds",
        description: "Place a tornado on the ground decreases the cast point and increasing projectile speed of basic attacks for all allies in the area.",
        ability_specials: [
            {
                ability_special: "cast_point_reduction",
                text: "CAST POINT REDUCTION:"
            },
            {
                ability_special: "proj_speed_increase",
                text: "PROJ SPEED INCREASE:"
            },
            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_explosive_arrow",
        name: "Explosive Arrow",
        description: "Fire an arrow which explodes for high damage.",
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_sprint",
        name: "Sprint",
        description: "Run fast.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "movespeed_bonus_pct",
                text: "BONUS MOVESPEED:" + "%"
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
