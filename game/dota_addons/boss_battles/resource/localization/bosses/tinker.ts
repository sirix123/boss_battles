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

    // modifiers
    Modifiers.push({
        modifier_classname: "phase_2_crystal_spawn_modifier",
        name: "Crystal Growth",
        description: `You will mark a location on the floor at the end of the duration.`
    });

    Modifiers.push({
        modifier_classname: "biting_frost_modifier_debuff",
        name: "Icebite",
        description: `Taking stacking damage per second that is dealt to all nearby targets. Can be cleansed by fire.`
    });

    Modifiers.push({
        modifier_classname: "fire_ele_melt_debuff",
        name: "Melted armor",
        description: `Your armour is reduced, increasing damage taken.`
    });

    Modifiers.push({
        modifier_classname: "modifier_generic_silenced",
        name: "Silenced",
        description: `You cannot cast any abilities.`
    });

    

    // Return data to compiler
    return localization_info;
}
