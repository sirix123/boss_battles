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

    // modifiers
    Modifiers.push({
        modifier_classname: "q_smoke_bomb_modifier",
        name: "Evasive",
        description: `Provides increased movement speed and invulnerability.`,
    });


    // abilities
    Abilities.push({
        ability_classname: "m1_combo_hit_1_2",
        name: "Slash",
        description: `Short range attack that deals damage in a cone. After 2 attacks this ability changes into another ability.`,
        notes:
        [
            `This is a chain attack, after two attacks this ability changes into Lacerate.`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
    
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
        ]
    });



    // Return data to compiler
    return localization_info;
}
