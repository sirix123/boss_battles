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
        modifier_classname: "beastmaster_mark_modifier",
        name: "Mark",
        description: `You're being hunted.`
    });

    Modifiers.push({
        modifier_classname: "puddle_slow_modifier",
        name: "Slow",
        description: `You're being slowed by some sticky goo.`
    });

    Modifiers.push({
        modifier_classname: "modifier_beastmaster_net",
        name: "Net",
        description: `You're trapped.`
    });


    // Return data to compiler
    return localization_info;
}
