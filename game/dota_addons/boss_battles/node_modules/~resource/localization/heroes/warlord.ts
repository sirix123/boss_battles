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
    const bladefuryColour = `<b><font color=\"#ffffff\">Blade Fury</font></b>`

    // modifiers
    Modifiers.push({
        modifier_classname: "m2_sword_slam_debuff",
        name: "Weakness",
        description: `Increases the damage of your Sword Slams.`,
    });

    Modifiers.push({
        modifier_classname: "e_warlord_shout_modifier",
        name: "Warlord Shout",
        description: `Provides a shield that will abosrbs damage.`,
    });

    Modifiers.push({
        modifier_classname: "q_conq_shout_modifier",
        name: "Conquerer Shout",
        description: `Invulnerable and regenerating rage.`,
    });

    Abilities.push({
        ability_classname: "m1_sword_slash",
        name: "Sword Slash",
        description: `Slash the enemy with your sword, generating energy.`,
        notes:
        [

        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },

            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },
    
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "m2_sword_slam",
        name: "Sword Slam",
        description: `Slam the sword in a line with your sword, dealing damage to all enemies caught in its path. Applies a buff to the Warlord increasing the damage delt by Sword Slam.`,
        notes:
        [
            `Max stacks of the debuff is {max_stacks}`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },

            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },
    
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },

            {
                ability_special: "dmg_per_mana_point",
                text: "DAMAGE PER ENERGY:",
            },

            {
                ability_special: "dps_stance_m2_stack_duration",
                text: "BUFF DURATION:",
            },

            {
                ability_special: "dmg_per_debuff_stack",
                text: "DAMAGE PER DEBUFF:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "q_conq_shout",
        name: "Conquerer Shout",
        description: `Increase the damage of your Blade Vortex(s).`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "base_dmg",
                text: "DAMAGE:"
            },

            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "e_warlord_shout",
        name: "Warlord Shout",
        description: `Shout a battle cry that applies a shield to all targets in range of you and your Blade Vortex(s).`,
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
                ability_special: "bubble_amount",
                text: "SHIELD:"
            },

        ]
    });

    Abilities.push({
        ability_classname: "r_blade_vortex",
        name: "Blade Vortex",
        description: `Place a Blade Vortex on the ground that deals damage and channels your shouts.`,
        notes:
        [  
            'Shouts will increase the duration of the vortex.'
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "base_dmg",
                text: "DAMAGE:"
            },

            {
                ability_special: "shout_duration_increase",
                text: "PER SHOUT VORTEX DURATION INCREASE:"
            },

            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_chain_hook",
        name: "Chain Hook",
        description: `Hook to a friendly or enemy target.`,
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
