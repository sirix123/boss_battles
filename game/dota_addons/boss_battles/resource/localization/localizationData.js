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
    // modifiers
    Modifiers.push({
        modifier_classname: "modifier_greater_power",
        name: "Greater Power",
        description: "Increases your base damage by {" + "MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" /* PREATTACK_BONUS_DAMAGE */ + "} and your move speed by {" + "MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" /* MOVESPEED_BONUS_PERCENTAGE */ + "}%."
    });
    // abilities
    Abilities.push({
        ability_classname: "aghanims_shard_explosion",
        name: "Shard Explosion",
        description: "Fires a shard at the target point which deals ${damage} damage to all enemies on impact.",
        lore: "Aghanims' signature move, firing shards of arcane energy.",
        scepter_description: "Increases damage by ${scepter_damage} and explosion range by ${scepter_aoe_bonus}.",
        shard_description: "Decreases cooldown of the ability by ${shard_cd_pct}%.",
        notes: [
            "The projectile moves at ${projectile_speed} speed.",
            "Despite the visual effect, all enemies in range immediately take damage upon impact.",
            "Can be disjointed."
        ],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE"
            },
            {
                ability_special: "radius",
                text: "EXPLOSION RADIUS"
            },
            {
                ability_special: "scepter_cd_reduction",
                text: "COOLDOWN REDUCTION",
                percentage: true
            }
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
