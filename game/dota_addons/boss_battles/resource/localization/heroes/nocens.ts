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
    // variables
    const judgementColour = `<b><font color=\"#ffffff\">Judgement</font></b>`

    // modifiers
    Modifiers.push({
        modifier_classname: "e_regen_aura_buff",
        name: "Divine Light",
        description: `Provides {${LocalizationModifierProperty.HEALTH_REGEN_CONSTANT}} health regen.`
    });

    Modifiers.push({
        modifier_classname: "q_armor_aura_buff",
        name: "Bolster",
        description: `Provides {${LocalizationModifierProperty.PHYSICAL_ARMOR_BONUS}} increased armor.`
    });

    Modifiers.push({
        modifier_classname: "r_outgoing_dmg_buff",
        name: "Divine Purge",
        description: `Provides {${LocalizationModifierProperty.TOTALDAMAGEOUTGOING_PERCENTAGE}}% increased outgoing damage for all spells and abilities.`
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_omni_basic_attack",
        name: "Hammer Smash",
        description: `Smash`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "m2_direct_heal",
        name: "Flash Heal",
        description: `After a short delay heal all allies in the area.`,
        ability_specials:
        [
            {
                ability_special: "heal",
                text: "HEAL:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "q_armor_aura",
        name: "Bolster",
        description: `Grant all allies armor.`,
        notes:
        [
            `When consumed by ${judgementColour} applies a minus armor debuff to enemies.`,
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "armor_plus",
                text: "ARMOUR GAIN:",
            },

            {
                ability_special: "armor_minus",
                text: "ARMOUR REDUCTION:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "e_regen_aura",
        name: "Divine Light",
        description: `Grant all allies health regen.`,
        notes:
        [
            `When consumed by ${judgementColour} applies a health degen debuff to enemies.`,
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "regen_plus",
                text: "REGEN:",
            },

            {
                ability_special: "regen_minus",
                text: "DEGEN:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "r_outgoing_dmg",
        name: "Divine Purge",
        description: `Increases damage of all abilities and spells cast by all friendly players.`,
        notes:
        [
            `When consumed by ${judgementColour} does high damage to all enemies.`,
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "outgoing_plus",
                text: "DAMAGE BONUS:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_judgement",
        name: "Judgement",
        description: `Judges all enemies in radius with holy light, does something extra if you have an aura active.`,
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },

            {
                ability_special: "bonus_dmg",
                text: "ACTIVE AURA BONUS DAMAGE:",
            },

            {
                ability_special: "r_dmg",
                text: "DIVINE PURGE BONUS DAMAGE:",
            },

            {
                ability_special: "debuff_duration",
                text: "DEBUFF DURATION:",
            },

        ]
    });


    // Return data to compiler
    return localization_info;
}
