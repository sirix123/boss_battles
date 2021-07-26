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
        description: "Increased movespeed.",
    });
    Modifiers.push({
        modifier_classname: "e_whirling_winds_modifier",
        name: "Tailwind",
        description: "Increased damage, movement and projectile speed. Cast points of basic attacks reduced.",
    });
    // abilities
    Abilities.push({
        ability_classname: "m1_trackingshot",
        name: "Farsight shot",
        description: "Windrunner shoots an enchanted arrow from her bow dealing damage to the target. Farsight shot does more damage with distance travelled.",
        ability_specials: [
            {
                ability_special: "base_dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "dmg_dist_multi",
                text: "DISTANCE MULTIPLIER:",
                percentage: true,
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
        description: "Windrunner charges her energy into a powerful shot, dealing damage to all enemies it pierces. Power Shot does more damage with distance travelled.",
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "dmg_dist_multi",
                text: "DISTANCE MULTIPLIER:",
                percentage: true,
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
        name: "Mending arrow",
        description: "Windrunner fires an arrow that heals all allies it hits. Mending arrow does more healing with distance travelled.",
        ability_specials: [
            {
                ability_special: "heal",
                text: "HEAL:"
            },
            {
                ability_special: "heal_dist_multi",
                text: "DISTANCE MULTIPLIER:",
                percentage: true,
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
        name: "Whirling Winds",
        description: "Windrunner summons a tailwind in an area that increases the damage, projectile and movement speed of all allies, as well as reducing the cast point of basic attacks. Windrunner benefits from the tailwind at all times.",
        ability_specials: [
            {
                ability_special: "cast_point_reduction",
                text: "CAST POINT REDUCTION:",
                percentage: true,
            },
            {
                ability_special: "proj_speed_increase",
                text: "PROJECTILE SPEED:",
                percentage: true,
            },
            {
                ability_special: "dmg_increase",
                text: "DAMAGE:",
                percentage: true,
            },
            {
                ability_special: "ms_increase",
                text: "MOVEMENT SPEED:",
                percentage: true,
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
        description: "Windrunner launches a long distance arrow that explodes on impact, dealing damage to all enemies in range.",
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_sprint",
        name: "Haste",
        description: "Windrunner channels the wind around her to temporarily increase her movespeed.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "movespeed_bonus_pct",
                text: "BONUS MOVESPEED:",
                percentage: true,
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
