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


    Modifiers.push({
        modifier_classname: "soul_crystals",
        name: "Soul Crystals",
        description: `Current amount of soul crystals.`
    });

    Modifiers.push({
        modifier_classname: "space_disperse_modifier",
        name: "Wraithwalk",
        description: `Increased movement speed and invulnerability.`
    });

    // abilities
    Abilities.push({
        ability_classname: "pugna_basic_attack",
        name: "Shadow Bolt",
        description: `Pugna fires a bolt of necrotic energy towards a target.`,
        ability_specials:
        [
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
        ability_classname: "pugna_m2",
        name: "Wrathfire Blast",
        description: `Pugna launches a bolt of chaotic energy towards a target. At maximum soul crystals, Wraithfire Blast will bounce towards an additional target.`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "soul_drain",
        name: "Soul Drain",
        description: `Pugna drains the soul of a target enemy, restoring mana and dealing damage.`,
        ability_specials:
        [
            {
                ability_special: "mana",
                text: "MANA PER SECOND:"
            },

            {
                ability_special: "dmg",
                text: "DAMAGE PER SECOND:",
            },

            {
                ability_special: "drain_tick_rate",
                text: "drain_tick_rate:",
            },

            {
                ability_special: "max_ticks",
                text: "max_ticks:",
            },

            {
                ability_special: "duration_buff_soul_crystal",
                text: "duration_buff_soul_crystal:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "e_magic_circle_pugna",
        name: "circle",
        description: `place cirlce on ground deals dmg`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "radius",
                text: "radius:"
            },

            {
                ability_special: "duration",
                text: "duration:"
            },
    
            {
                ability_special: "dmg",
                text: "dmg:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "r_infest_pugna",
        name: "Infest",
        description: `Spit on target. All damage done during the duration is then dealt as a dot (damage / dot duration)`,
        notes:
        [

        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "dot_duration",
                text: "DOT DURATION:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "space_disperse",
        name: "space_disperse",
        description: `go invul and move faster.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "movespeed_bonus_pct",
                text: "movespeed_bonus_pct:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "pugna_passive",
        name: "Pugna Passive",
        description: `Soul drain grants a soul crystal. Max 3 crystals. Each crystal grants 5% increased outgoing damage. Crystals have individual durations.`,
        notes:
        [

        ],
        ability_specials:
        [

        ]
    });


    // Return data to compiler
    return localization_info;
}
