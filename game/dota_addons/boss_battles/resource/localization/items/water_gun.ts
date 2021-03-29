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

    Abilities.push({
        ability_classname: "item_water_gun",
        name: "Water Gun",
        description: "Who left this water gun here...",
        notes:
        [
            `Shooting the water gun will give you 1 stack of living water.`,
            `Each stack of living water increases your outgoing damage. (Scales based on current stacks).`,
            `At 8 stacks your gun will overheat and set you on fire.`,
        ],
    });

    Modifiers.push({
        modifier_classname: "water_gun_dmg_buff",
        name: "Living water.",
        description: `All of your outgoing damage is increased by {${LocalizationModifierProperty.TOTALDAMAGEOUTGOING_PERCENTAGE}}%.`
    });

    Modifiers.push({
        modifier_classname: "water_gun_dmg_debuff",
        name: "Your water gun has overheated",
        description: `You're on fire.`
    });


    // Return data to compiler
    return localization_info;
}
