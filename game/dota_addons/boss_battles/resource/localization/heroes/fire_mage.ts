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
    const remnantColour = `<b><font color=\"#ffffff\">Fire Remnant</font></b>`
    const incinerateColour = `<b><font color=\"#ffffff\">Incinerate</font></b>`

    // modifiers
    Modifiers.push({
        modifier_classname: "m1_beam_fire_rage",
        name: "Fiery Spirit",
        description: `Current number of Fiery Spirit stacks.`
    });

    Modifiers.push({
        modifier_classname: "q_fire_bubble_modifier",
        name: "Flame Barrier",
        description: `Absorbs incoming damage and damages nearby enemies.`
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_beam",
        name: "Incinerate",
        description: `Lina concentrates her fiery energy into a beam that damages all enemies it touches. ${incinerateColour} damage and mana gain increases over time, stacking up to three times. ${remnantColour} replicates this ability.`,
        notes:
        [
            `Only gains stacks if a enemy is hit by Incinerate.`,
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "BASE DAMAGE:"
            },

            {
                ability_special: "mana_gain_percent",
                text: "BASE MANA GAIN:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "m2_meteor",
        name: "Flash Fire",
        description: `Lina charges a target area with an intense fire that damages all enemies in the area and applies a debuff that amplifies damage taken.`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },

            {
                ability_special: "fire_weakness_duration",
                text: "DEBUFF DURATION:"
            },

            {
                ability_special: "fire_weakness_dmg_increase",
                text: "DEBUFF DAMAGE INCREASE:",
                percentage: true,
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "q_fire_bubble",
        name: "Flame Barrier",
        description: `Lina shields an ally with a fiery aura that absorbs incoming damage and damages nearby enemies.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "bubble_amount",
                text: "DAMAGE ABSORB:",
            },

            {
                ability_special: "burn_amount",
                text: "AURA DAMAGE:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "e_fireball",
        name: "Firestorm",
        description: `Lina unleashes a barrage of fireballs infront of her, damaging the first enemy hit. ${remnantColour} replicates this ability.`,
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },

            {
                ability_special: "AbilityChannelTime",
                text: "CHANNEL DURATION:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "r_remnant",
        name: "Fire Remnant",
        description: `Lina creates a replica of her fiery spirit that will attack nearby enemies.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "space_dive",
        name: "Flame Dash",
        description: `Lina surges forwards, travelling a short distance.`,
    });


    // Return data to compiler
    return localization_info;
}
