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
    const bloodBrotherColour = `<b><font color=\"#ffffff\">Blood Brother</font></b>`
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
        ability_classname: "m1_qop_basic_attack",
        name: "Throw Dagger",
        description: `Paladin swings his mighty hammer at his foes, dealing damage in an area infront of him.`,
        ability_specials:
        [
            {
                ability_special: "dmg",
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
        ability_classname: "m2_qop_direct_heal",
        name: "Blood Light",
        description: `QOP directly heals her target. If cast in quick succession will double in cost up to 3 times. Healing in this way applies ${bloodBrotherColour} to the target`,
        ability_specials:
        [
            {
                ability_special: "base_heal",
                text: "HEAL:"
            },

            {
                ability_special: "duration_main_buff",
                text: "BUFF:",
            },

            {
                ability_special: "duration_debuff",
                text: "DEBUFF:",
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
        ability_classname: "q_pen",
        name: "Pen",
        description: `Also gives the target if friendly the ${bloodBrotherColour} buff`,
        ability_specials:
        [
            {
                ability_special: "max_ticks",
                text: "MAX TICKS:",
            },
    ​
            {
                ability_special: "dmg",
                text: "DAMAGE:",
            },
        ]
    });
    ​
    Abilities.push({
        ability_classname: "e_qop_shield",
        name: "Blood Light",
        description: `Give your ally a shield. Also consumes all stacks from m2. If consuming stacks buffs the bubble amount. Casting on enemies gives them a debuff that tracks dmg taken during the buffs duration. At the end of the duration damage is dealt based on the damage received during the debuff. Multipler affected by buff stacks.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },
    ​
            {
                ability_special: "base_bubble",
                text: "BUBBLE AMOUNT:",
            },

            {
                ability_special: "dmg_multiplier",
                text: "MULTIPLIER:",
            },
        ]
    });
    ​
    Abilities.push({
        ability_classname: "r_delayed_aoe_heal",
        name: "Zealotry BANG",
        description: `After 5 seconds the ground explodes giving the caster mana. While the circle is up it ticks damage.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },
            
            {
                ability_special: "dmg",
                text: "DAMAGE:",
            },

            {
                ability_special: "mana",
                text: "MANA GAIN:",
            },
    ​
        ]
    });
    ​
    Abilities.push({
        ability_classname: "space_leap_of_grip",
        name: "Leap",
        description: `Pulls ally towards caster.`,
        ability_specials:
        [
        ]
    });

    Abilities.push({
        ability_classname: "qop_passive",
        name: "Living Blood",
        description: `If ally affected by buff when qop deals damage a portion of it heals allies affected by buff`,
        notes:
        [

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
