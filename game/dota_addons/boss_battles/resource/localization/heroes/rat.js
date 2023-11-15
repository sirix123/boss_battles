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
    Modifiers.push({
        modifier_classname: "space_burrow_v2_modifier",
        name: "Burrow",
        description: "Cannot use the tunnel again."
    });
    Modifiers.push({
        modifier_classname: "rat_stacks",
        name: "Rat stack",
        description: "Attack speed increased and cast point reduction."
    });
    Modifiers.push({
        modifier_classname: "stim_pack_buff",
        name: "Juiced",
        description: "Rat can move and shoot."
    });
    Modifiers.push({
        modifier_classname: "stim_pack_debuff",
        name: "Withdrawl",
        description: "Slowed."
    });
    Modifiers.push({
        modifier_classname: "rat_passive",
        name: "Rat passive"
    });
    Modifiers.push({
        modifier_classname: "rat_passive_modifier",
        name: "Rat passive"
    });
    // abilities
    Abilities.push({
        ability_classname: "rat_basic_attack",
        name: "Rat basic",
        description: "Shoot your glizzy.",
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
            {
                ability_special: "mana_gain_percent",
                text: "ENERGY GAIN:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "rat_m2",
        name: "Boomerang",
        description: "Fire a boomerang at the target will bounce to another target if you have 5 rat stacks.",
        notes: [],
        ability_specials: [
            {
                ability_special: "dmg",
                text: "DAMAGE EACH:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_eat_cheese",
        name: "Eat cheese",
        description: "Eat cheese restoring 100hp.",
        ability_specials: []
    });
    Abilities.push({
        ability_classname: "e_stim_pack",
        name: "Pickle Juice",
        description: "Drink some pickle juice. Allows you attack while moving and reduces Boomerang cast point. Gives 5 rat stacks. Rat stacks do not get removed during movement. At the end of the duration get a debuff that slows you.",
        notes: [],
        ability_specials: [
            {
                ability_special: "buff_duration",
                text: "DURATION:"
            },
            {
                ability_special: "duration_debuff",
                text: "DURATION:"
            },
            {
                ability_special: "ms_slow",
                text: "SLOW:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_infest",
        name: "Infest",
        description: "Spit on target. All damage done during the duration is then dealt as a dot (damage / dot duration)",
        notes: [],
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "dot_duration",
                text: "DOT DURATION:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_burrow_v2",
        name: "Burrow",
        description: "Tunnel underground. Connects two points that your allies can use to teleport around. Has a cooldown.",
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "rat_passive",
        name: "Rat Passive",
        description: "Standing still generates rat stacks, moving consumes rat stacks.",
        notes: [],
        ability_specials: [
            {
                ability_special: "attack_speed_per_stack",
                text: "ATTACK SPEED PER STACK:"
            },
            {
                ability_special: "rat_stack_generate_time",
                text: "RAT STACK GENERATE TIME:"
            },
            {
                ability_special: "rat_stack_max",
                text: "RAT STACK MAX:"
            },
            {
                ability_special: "mana_gain_percent",
                text: "MANA ON HIT:"
            }
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
