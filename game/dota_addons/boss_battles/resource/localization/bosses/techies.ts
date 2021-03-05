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
        modifier_classname: "modifier_sticky_bomb",
        name: "Sticky Bomb",
        description: `This bomb splits damage with all surrounding players.`
    });

    Modifiers.push({
        modifier_classname: "modifier_electric_vortex",
        name: "Stasis pull",
        description: `Pulls target towards the stasis trap.`
    });

    Modifiers.push({
        modifier_classname: "blast_off_fog_modifier",
        name: "Blast off smoke",
        description: `Vision reduced from blast off smoke.`
    });

    Modifiers.push({
        modifier_classname: "generic_cube_bomb_modifier",
        name: "Deadly looking cube",
        description: `Quick find the diffuse location.`
    });


    // Return data to compiler
    return localization_info;
}
