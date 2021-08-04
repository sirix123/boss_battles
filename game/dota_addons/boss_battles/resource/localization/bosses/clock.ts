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

    // modifiers
    Modifiers.push({
        modifier_classname: "modifier_rooted_clock",
        name: "Rooted",
        description: `You are unable to move or use movement abilities.`
    });

    Modifiers.push({
        modifier_classname: "choking_gas_timer",
        name: "Gas",
        description: `Toxic gas is spawning underneath you.`
    });

    // Return data to compiler
    return localization_info;
}
