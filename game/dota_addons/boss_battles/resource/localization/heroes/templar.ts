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


    // abilities
    Abilities.push({
        ability_classname: "templar_passive",
        name: "Mind over matter",
        description: `If you have enough mana the incoming damage will be reduced by x%.`,
        ability_specials:
        [
            {
                ability_special: "mind_over_matter",
                text: "DAMAGE TAKEN FROM MANA:",
                percentage: true,
            },

        ]
    });


    // Return data to compiler
    return localization_info;
}
