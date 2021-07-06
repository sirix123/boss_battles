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

    Modifiers.push({
        modifier_classname: "e_sigil_of_power_modifier_buff",
        name: "sigil buff",
        description: `getting a dmg boost.`
    });

    Modifiers.push({
        modifier_classname: "e_sigil_of_power_modifier",
        name: "sigil buff mana spender",
        description: `spend mana to get a dmg boost.`
    });

    Modifiers.push({
        modifier_classname: "evocate_modifier",
        name: "evocate",
        description: `getting mana back.`
    });

    Modifiers.push({
        modifier_classname: "templar_power_charge",
        name: "power charge",
        description: `bonus movement speed.`
    });

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

            {
                ability_special: "power_charge_m1_mana_cost_reduction_per_stack",
                text: "basic attack mana cost reduction per power charge stack:",
                percentage: true,
            },

            {
                ability_special: "power_charge_ms_bonus_percent",
                text: "BONUS MS PER PC STACK:",
                percentage: true,
            },

            {
                ability_special: "space_duration_reduction_per_power_charge",
                text: "EVOCATE DURATION REDUCTION PER STACK:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "templar_basic",
        name: "basic attack",
        description: `does base damage + damage per mana point.`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "templar_m2_leap",
        name: "slam",
        description: `does damage and generates a power charge max 3`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "q_arcane_cage",
        name: "link",
        description: `link a player, 50% of damage taken goes to templar`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "duration:",
            },

            {
                ability_special: "damage_sent_to_templar",
                text: "sent damage:",
                percentage: true,
            },

            {
                ability_special: "outgoing_damage_bonus",
                text: "damage bonus for linked player:",
                percentage: true,
            },

        ]
    });

    Abilities.push({
        ability_classname: "e_sigil_of_power",
        name: "sigil of power",
        description: `place a sigil on the ground, stand in it to get a buff, the more mana you spend with this buff on, the more damage bonus you get after it ends.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "duration:",
            },

            {
                ability_special: "duration_buff",
                text: "buff duration:",
                percentage: true,
            },

        ]
    });

    Abilities.push({
        ability_classname: "r_arcane_surge",
        name: "surge",
        description: `summon a storm`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "duration:",
            },

            {
                ability_special: "interval",
                text: "base interval:",
            },

            {
                ability_special: "damage",
                text: "base damage:",
            },

            {
                ability_special: "stack_bonus_interval",
                text: "stack_bonus_interval:",
                percentage: true,
            },

            {
                ability_special: "stack_bonus_damage",
                text: "stack_bonus_damage:",
            },

            {
                ability_special: "mana_on_hit",
                text: "mana_on_hit:",
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_evocate",
        name: "evocate",
        description: `get ur mana back`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "duration:",
            },
        ]
    });


    // Return data to compiler
    return localization_info;
}
