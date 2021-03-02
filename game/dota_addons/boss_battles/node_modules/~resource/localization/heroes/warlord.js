"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenerateLocalizationData = void 0;
function GenerateLocalizationData() {
    // This section can be safely ignored, as it is only logic.
    //#region Localization logic
    // Arrays
    var Abilities = new Array();
    var Modifiers = new Array();
    var StandardTooltips = new Array();
    // Create object of arrays
    var localization_info = {
        AbilityArray: Abilities,
        ModifierArray: Modifiers,
        StandardArray: StandardTooltips,
    };
    //#endregion
    // Enter localization data below!
    var bladefuryColour = "<b><font color=\"#ffffff\">Blade Fury</font></b>";
    // modifiers
    Modifiers.push({
        modifier_classname: "e_spawn_ward_buff",
        name: "Warcry",
        description: "Reduces damage taken by {" + "MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE" /* INCOMING_DAMAGE_PERCENTAGE */ + "}% and provides {" + "MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT" /* HEALTH_REGEN_CONSTANT */ + "} health regen to everyone inside the shouts radius.",
    });
    Modifiers.push({
        modifier_classname: "q_meditate_modifier",
        name: "Meditating",
        description: "Invulnerable and regenerating rage.",
    });
    Abilities.push({
        ability_classname: "m1_sword_slash",
        name: "Sword Slash",
        description: "Slash the enemy with your sword, generating energy.",
        notes: [],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "m2_sword_slam",
        name: "Sword Slam",
        description: "Slam the sword in a line with your sword, dealing damage to all enemies caught in its path. Applies a buff to the Warlord increasing the damage delt by Sword Slam.",
        notes: [
            "The debuff also increases the damage of " + bladefuryColour + ".",
            "Max stacks of the debuff is {max_stacks}",
        ],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "ENERGY GAIN:",
                percentage: true
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
            {
                ability_special: "dps_stance_m2_stack_duration",
                text: "DEBUFF DURATION:",
            },
            {
                ability_special: "dmg_per_debuff_stack",
                text: "DAMAGE PER DEBUFF:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_meditate",
        name: "Meditate",
        description: "Enter a state where you take no damage and you regenerate energy.",
        notes: [],
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "e_spawn_ward",
        name: "Warcry",
        description: "Shout a battle cry continously that reduces incoming damage and increases health regen to all nearby allies and your self.",
        notes: [],
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "dmg_reduction",
                text: "DAMAGE REDUCTION:"
            },
            {
                ability_special: "heal_amount_per_tick",
                text: "HEAL:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_sword_slam",
        name: "Blade Fury",
        description: "Blade Fury.",
        notes: [],
        ability_specials: [
            {
                ability_special: "base_dmg",
                text: "BASE DAMAGE:"
            },
            {
                ability_special: "dmg_per_mana_point",
                text: "DAMAGE PER ENERGY POINT:"
            },
            {
                ability_special: "dmg_per_debuff_stack",
                text: "DAMAGE PER DEBUFF STACK:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_chain_hook",
        name: "Chain Hook",
        description: "Hook to a friendly or enemy target.",
        notes: [],
        ability_specials: []
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
