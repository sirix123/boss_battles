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

    // Enter localization data below! 
    StandardTooltips.push({
        classname: "addon_game_name",
        name: "Boss Battles"
    });

    Modifiers.push({
        modifier_classname: "modifier_grace_period",
        name: "Grace Period",
        description: `You've just respawned, you're invulnerable.`
    });

    Modifiers.push({
        modifier_classname: "modifier_generic_stunned",
        name: "Stunned",
    });

    


    // Return data to compiler
    return localization_info;
}