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
        modifier_classname: "modifier_sticky_bomb",
        name: "Sticky Bomb",
        description: `Damage dealt by the bomb is spread evenly across all targets.`
    });

    Modifiers.push({
        modifier_classname: "modifier_electric_vortex",
        name: "Stasis pull",
        description: `You are being pulled towards the trap.`
    });

    Modifiers.push({
        modifier_classname: "blast_off_fog_modifier",
        name: "Blast off smoke",
        description: `Your vision is heavily reduced.`
    });

    Modifiers.push({
        modifier_classname: "generic_cube_bomb_modifier",
        name: "Deadly looking cube",
        description: `You must find the location marked to dispell this.`
    });


    // Return data to compiler
    return localization_info;
}
