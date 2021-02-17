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
    const shatterColour = `<b><font color=\"#9af9e0\">Shatter</font></b>`

    // modifiers
    Modifiers.push({
        modifier_classname: "e_spawn_ward_buff",
        name: "Warcry",
        description: `Reduces damage taken by {${LocalizationModifierProperty.INCOMING_DAMAGE_PERCENTAGE}}% and provides {${LocalizationModifierProperty.HEALTH_REGEN_CONSTANT}} health regen to everyone inside the shouts radius.`,
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
        description: `Slam the sword in a line with your sword, dealing damage to all enemies caught in its path. Applies a buff to the caster increasing the damage delt by Sword Slam.`,
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


    // Return data to compiler
    return localization_info;
}
