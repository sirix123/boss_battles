import { AbilityLocalization, LocalizationData, ModifierLocalization, StandardLocalization } from "~generator/localizationInterfaces";

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

     // variables
     const manastormColour = `<b><font color=\"#ffffff\">Manastorm</font></b>`

    Modifiers.push({
        modifier_classname: "e_sigil_of_power_modifier_buff",
        name: "Discharged",
        description: `Gaining amplified damage.`
    });

    Modifiers.push({
        modifier_classname: "q_arcane_cage_modifier_templar",
        name: "Energised",
        description: `Gaining amplified damage and regenerating %dMODIFIER_PROPERTY_MANA_REGEN_CONSTANT% mana per second.`
    });

    Modifiers.push({
        modifier_classname: "q_arcane_cage_modifier",
        name: "Energised",
        description: `Gaining amplified damage.`
    });


    Modifiers.push({
        modifier_classname: "templar_power_charge",
        name: "Power Charge",
        description: `Regenerating %dMODIFIER_PROPERTY_MANA_REGEN_CONSTANT% mana per second.`
    });

    Modifiers.push({
        modifier_classname: "arcane_surge_modifier",
        name: "Surge",
        description: `Dealing damage around templar.`
    });

    // abilities
    Abilities.push({
        ability_classname: "templar_passive",
        name: "Mind Over Matter",
        description: `A portion of incoming damage is redirected to mana instead of health. Additionally, each power charge grants mana regen, stacking up three times.`,
        ability_specials:
        [
            {
                ability_special: "mind_over_matter",
                text: "DAMAGE ABSORBED:",
                percentage: true,
            },

            {
                ability_special: "power_charge_mana_regen",
                text: "MANA REGEN PER CHARGE:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "templar_basic",
        name: "Arcane Spear",
        description: `Templar imbues his spear with powerful arcane energy at the expense of his mana, dealing damage to all enemies in front of him.`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "BASE DAMAGE:",
            },

            {
                ability_special: "percent_of_mana_cost",
                text: "MANA COST OF CURRENT MANA:",
                percentage: true,
            },

            {
                ability_special: "bonus_damage",
                text: "MANA BONUS DAMAGE:",
                percentage: true,
            },
        ]
    });

    Abilities.push({
        ability_classname: "templar_m2_leap",
        name: "Crusader Strike",
        description: `Templar leaps to the target area dealing damage to all enemies and granting him a power charge.`,
        notes:
        [
            `If Crusader Strike is used at templar's location, he instead just deals damage around him.`,
            `Templar is granted a power charge regardless if Crusader Strike hits an enemy.`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "q_arcane_cage",
        name: "Spirit Link",
        description: `Templar links his spirit to another ally, redirecting a portion of damage they take to himself. Additionally, both targets damage is amplified and templar has increased mana regeneration.`,
        notes:
        [
            `Spirit Link is broken if the target moves out of range.`,
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },

            {
                ability_special: "damage_sent_to_templar",
                text: "REDIRECTED DAMAGE:",
                percentage: true,
            },

            {
                ability_special: "outgoing_damage_bonus",
                text: "BONUS DAMAGE:",
                percentage: true,
            },

            {
                ability_special: "mana_regen",
                text: "MANA REGENERATION:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "e_sigil_of_power",
        name: "Discharge",
        description: `Templar unleashes his inner spirit in an explosion around him, dealing damage to all enemies and consuming all power charges. Additionally, all allies around templar gain bonus damage.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },

            {
                ability_special: "damage_boost_per_power_charge_consumed",
                text: "BONUS DAMAGE PER POWER CHARGE:",
                percentage: true,
            },

            {
                ability_special: "damage",
                text: "DAMAGE PER POWER CHARGE:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "r_arcane_surge",
        name: "Manastorm",
        description: `Templar invokes a storm of arcane energy around him, dealing damage to the closest enemy, stacking up to three times. Each stack of ${manastormColour} increases the damage and strike interval.`,
        notes:
        [
            `Each stack of Manastorm has an independant cooldown, and does not refresh with additional uses.`
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },

            {
                ability_special: "damage",
                text: "BASE DAMAGE:",
            },

            {
                ability_special: "stack_bonus_interval",
                text: "BONUS STRIKE INTERVAL:",
                percentage: true,
            },

            {
                ability_special: "stack_bonus_damage",
                text: "BONUS DAMAGE:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "space_evocate",
        name: "Lifetap",
        description: `Templar sacrifices his own life to fully restore his mana.`,
        notes:
        [
            `Lifetap cannot be used under 150 health.`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage_self",
                text: "SELF DAMAGE:",
            },
        ]
    });


    // Return data to compiler
    return localization_info;
}
