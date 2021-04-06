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
​
    // modifiers
    Modifiers.push({
        modifier_classname: "e_regen_aura_buff",
        name: "Divine Light",
        description: `Regenerating {${LocalizationModifierProperty.HEALTH_REGEN_CONSTANT}} health per second.`
    });
​
    Modifiers.push({
        modifier_classname: "q_armor_aura_buff",
        name: "Bolster",
        description: `Armour increased by {${LocalizationModifierProperty.PHYSICAL_ARMOR_BONUS}}.`
    });
​
    Modifiers.push({
        modifier_classname: "r_outgoing_dmg_buff",
        name: "Divine Purge",
        description: `Damage increased by {${LocalizationModifierProperty.TOTALDAMAGEOUTGOING_PERCENTAGE}}%.`
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_omni_basic_attack",
        name: "Hammer of Justice",
        description: `Paladin swings his mighty hammer at his foes, dealing damage in an area infront of him.`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
    ​
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    ​
    Abilities.push({
        ability_classname: "m2_direct_heal",
        name: "Holy Light",
        description: `Paladin calls upon the light to heal all his allies in a targeted area.`,
        ability_specials:
        [
            {
                ability_special: "heal",
                text: "HEAL:"
            },
    ​
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    ​
    Abilities.push({
        ability_classname: "q_armor_aura",
        name: "Holy Ward",
        description: `Paladin grants all of his allies a protective ward that increases their armour. If Paladin uses ${judgementColour} while using this aura, then it reduces the targeted enemies armour.`,
        ability_specials:
        [
            {
                ability_special: "armor_plus",
                text: "ARMOUR:",
            },
    ​
            {
                ability_special: "armor_minus",
                text: "ARMOUR REDUCTION:",
            },
        ]
    });
    ​
    Abilities.push({
        ability_classname: "e_regen_aura",
        name: "Divine Light",
        description: `Paladin covers his allies in a divine light that grants all allies health regeneration. If Paladin uses ${judgementColour} while using this aura, then it applies a damage over time effect to all targeted enemmies.`,
        ability_specials:
        [
            {
                ability_special: "regen_plus",
                text: "HEALTH REGENERATION PER SECOND:",
            },
    ​
            {
                ability_special: "regen_minus",
                text: "DAMAGE PER SECOND:",
            },
        ]
    });
    ​
    Abilities.push({
        ability_classname: "r_outgoing_dmg",
        name: "Zealotry",
        description: `Paladin inspires all allies with a zealous fervour, increasing their damage. If Paladin uses ${judgementColour} while using this aura, then ${judgementColour} deals additional damage.`,
        ability_specials:
        [
            {
                ability_special: "outgoing_plus",
                text: "DAMAGE AURA:",
                percentage: true,
            },
            
            {
                ability_special: "r_dmg",
                text: "JUDGEMENT DAMAGE:",
            },
    ​
        ]
    });
    ​
    Abilities.push({
        ability_classname: "space_judgement",
        name: "Judgement",
        description: `Paladin judges all enemies in a targeted area, consuming active auras to deal additional effects.`,
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "nocens_passive",
        name: "Crusader",
        description: `Paladin's devotion to the light allows him to empower his allies with auras as well as burn his enemies with his ${judgementColour}. Consuming any auras with ${judgementColour} increases its damage and deals additional effects.`,
        notes:
        [
            `Paladin may have only one active aura at a time.`,
            `Paladin auras have global range.`,
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "AURA DAMAGE:"
            },
    ​
            {
                ability_special: "debuff_duration",
                text: "DEBUFF DURATION:",
            },
            
            {
                ability_special: "aura_cooldown",
                text: "AURA COOLDOWN:",
            },
        ]
    });


    // Return data to compiler
    return localization_info;
}
