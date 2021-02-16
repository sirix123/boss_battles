import { AbilityLocalization, Language, LocalizationData, ModifierLocalization, StandardLocalization } from "~generator/localizationInterfaces";

export function GenerateLocalizationData(): LocalizationData
{
    // This section can be safely ignored, as it is only logic.
    //#region Localization logic
    // Arrays
    const Abilities: Array<AbilityLocalization> = new Array<AbilityLocalization>();
    const Modifiers: Array<ModifierLocalization> = new Array<ModifierLocalization>();
    const StandardTooltips: Array<StandardLocalization> = new Array<StandardLocalization>();    

    // Create object of arrays
    const localization_info: LocalizationData =
    {
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
        description: `Increases your base damage by {${LocalizationModifierProperty.PREATTACK_BONUS_DAMAGE}} and your move speed by {${LocalizationModifierProperty.MOVESPEED_BONUS_PERCENTAGE}}%.`
    });

    // abilities
    Abilities.push({
        ability_classname: "aghanims_shard_explosion",
        name: "Shard Explosion",
        description: "Fires a shard at the target point which deals ${damage} damage to all enemies on impact.",
        lore: "Aghanims' signature move, firing shards of arcane energy.",
        scepter_description: "Increases damage by ${scepter_damage} and explosion range by ${scepter_aoe_bonus}.",
        shard_description: "Decreases cooldown of the ability by ${shard_cd_pct}%.",
        notes:
        [
            "The projectile moves at ${projectile_speed} speed.",
            "Despite the visual effect, all enemies in range immediately take damage upon impact.",
            "Can be disjointed."
        ],
    
        ability_specials:
        [
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
