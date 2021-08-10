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

    Modifiers.push({
        modifier_classname: "priest_inner_fire_modifier",
        name: "priest_inner_fire_modifier",
        description: `priest_inner_fire_modifier youre getting 50% of heal amount from nerif, also get armor and inc dmg, your m1s also give nerif mana`
    });

    Modifiers.push({
        modifier_classname: "space_angel_mode_modifier",
        name: "space_angel_mode_modifier ",
        description: `youre god`
    });

    // abilities
    Abilities.push({
        ability_classname: "priest_basic",
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
        ability_classname: "priest_flash_heal",
        name: "priest_flash_heal",
        description: `priest_flash_heal. unit target`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "heal_amount",
                text: "heal_amount:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "priest_holy_nova",
        name: "priest_holy_nova",
        description: `priest_holy_nova basically holynova from wow effects allies and enemies`,
        ability_specials:
        [
            {
                ability_special: "heal_amount",
                text: "heal_amount:"
            },

            {
                ability_special: "dmg",
                text: "dmg",
            },

            {
                ability_special: "radius",
                text: "radius",
            },

            {
                ability_special: "speed",
                text: "speed:",
            },

            {
                ability_special: "distance_multi",
                text: "distance_multi:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "priest_inner_fire",
        name: "priest_inner_fire",
        description: `priest_inner_fire mark a friendly target, that target gets healed for 50% of heals on other targets, also incs their dmg and armor, also whenever that target attacks with their basic attack you get mana`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "healing_reduce_target",
                text: "healing_reduce_target"
            },

            {
                ability_special: "duration",
                text: "duration:"
            },
    
            {
                ability_special: "armor_inc",
                text: "armor_inc:",
            },

            {
                ability_special: "dmg_inc",
                text: "dmg_inc:",
            },

            {
                ability_special: "mana_gain_amount_per_attack",
                text: "mana_gain_amount_per_attack:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "priest_holy_fire",
        name: "priest_holy_fire",
        description: `priest_holy_fire delayed bomb boom does dot`,
        notes:
        [

        ],
        ability_specials:
        [
            {
                ability_special: "dmg_dot",
                text: "dmg_dot:"
            },

            {
                ability_special: "delay",
                text: "delay:",
            },

            {
                ability_special: "dmg_explode",
                text: "dmg_explode:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "space_angel_mode",
        name: "space_angel_mode",
        description: `space_angel_mode become god, reduce castpoints all spells, reduced mana cost all spells, reduced cooldown all spells`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "reduce_cps",
                text: "reduce_cps:",
                percentage: true,
            },

            {
                ability_special: "reduce_cps",
                text: "reduce_cps:",
                percentage: true,
            },

            {
                ability_special: "reduce_cooldowns",
                text: "reduce_cooldowns:",
                percentage: true,
            },

            {
                ability_special: "reduce_mana_cost",
                text: "reduce_mana_cost:",
                percentage: true,
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
