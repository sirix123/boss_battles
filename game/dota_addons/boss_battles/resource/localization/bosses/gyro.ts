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
        modifier_classname: "fire_cross_grenade_debuff",
        name: "Shield",
        description: `You have a shield that absorbs damage.`
    });

    Modifiers.push({
        modifier_classname: "fire_puddle_modifier",
        name: "Sticky fire",
        description: `You're on fire.`
    });

    Modifiers.push({
        modifier_classname: "oil_puddle_slow_modifier",
        name: "Oil",
        description: `You're slowed by oil.`
    });

    Modifiers.push({
        modifier_classname: "modifier_gyro_barrage_debuff",
        name: "Barrage",
        description: `Barrage damage reduced depending on how many players are nearby.`
    });

    Modifiers.push({
        modifier_classname: "gyro_rocket_modifier",
        name: "Homing missile",
        description: `A missile is following you! You notice that the missile follows the closest target...`
    });


    // Return data to compiler
    return localization_info;
}
