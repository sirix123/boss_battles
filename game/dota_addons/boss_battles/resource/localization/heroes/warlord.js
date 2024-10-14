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
    // Variables
    var bladeMasteryColour = "<b><font color=\"#6f92fc\">Blade Mastery</font></b>";
    var sunderColour = "<b><font color=\"#ffffff\">Sunder</font></b>";
    var fightingSpiritColour = "<b><font color=\"#6f92fc\">Fighting Spirit</font></b>";
    var bladeVortexColour = "<b><font color=\"#ffffff\">Blade Vortex</font></b>";
    var inspireColour = "<b><font color=\"#ffffff\">Inspire</font></b>";
    var barricadeColour = "<b><font color=\"#ffffff\">Barricade</font></b>";
    // modifiers
    Modifiers.push({
        modifier_classname: "m2_sword_slam_debuff",
        name: "Blade Mastery",
        description: "The damage of Sunder is increased.",
    });
    Modifiers.push({
        modifier_classname: "warlord_modifier_shouts",
        name: "Fighting Spirit",
        description: "Regenerates %dMODIFIER_PROPERTY_MANA_REGEN_CONSTANT% mana per second and %dMODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT% health per second.",
    });
    Modifiers.push({
        modifier_classname: "e_warlord_shout_modifier",
        name: "Endurance",
        description: "Absorbs incoming damage.",
    });
    Modifiers.push({
        modifier_classname: "q_conq_shout_modifier",
        name: "Conquerer Shout",
        description: "Your vortex is generating you mana and has increased damage.",
    });
    Abilities.push({
        ability_classname: "m1_sword_slash",
        name: "Sweeping Blade",
        description: "Blademaster performs a wide sweeping cut to deal damage to all enemies infront of him.",
        //lore: `Blademaster's sword techniques are unparalleled for cutting down swathes of enemies.`,
        notes: [],
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "MANA GAIN:",
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
        name: "Sunder",
        description: "Blademaster slams down his sword, dealing damage based on his total mana to all enemies infront of him. Hitting an enemy with ".concat(sunderColour, " grants a stack of ").concat(bladeMasteryColour, ", up to three times."),
        //lore: `What doesn't kill his opponents only makes him stronger.`,
        ability_specials: [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "MANA GAIN:",
                percentage: true
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
            {
                ability_special: "dmg_per_mana_point",
                text: "DAMAGE PER MANA:",
            },
            {
                ability_special: "dps_stance_m2_stack_duration",
                text: "BUFF DURATION:",
            },
            {
                ability_special: "dmg_per_debuff_stack",
                text: "BLADE MASTERY DAMAGE:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_conq_shout",
        name: "Inspire",
        description: "Blademaster inspires his allies near him and his ".concat(bladeVortexColour, ". ").concat(inspireColour, " also generates one stack of ").concat(fightingSpiritColour, ".\n        Fighting Spirit regenerates 5 health per second and 2 mana per second.\n        Fighting Spirit can stack up to three times.\n        "),
        //lore: `Blademaster's military experience allows him to inspire his allies to push forward against overwhelming odds.`,
        // notes:
        // [
        //     `Fighting Spirit regenerates 5 health per second and 2 mana per second.`,
        //     `Fighting Spirit can stack up to three times.`,
        // ],
        ability_specials: [
            {
                ability_special: "vortex_dmg_inc",
                text: "DAMAGE:",
                percentage: true,
            },
            {
                ability_special: "duration",
                text: "DURATION:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "e_warlord_shout",
        name: "Barricade",
        description: "Blademaster defends his allies near him and his ".concat(bladeVortexColour, ", granting them a shield. ").concat(barricadeColour, " also generates one stack of ").concat(fightingSpiritColour, ". \n        Fighting Spirit regenerates 5 health per second and 2 mana per second.\n        Fighting Spirit can stack up to three times.\n        "),
        //lore: `The long and bitter war against the Templars revealed the importance of proper defence.`,
        // notes:
        // [
        //     `Fighting Spirit regenerates 5 health per second and 2 mana per second.`,
        //     `Fighting Spirit can stack up to three times.`,
        // ],
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "bubble_amount",
                text: "SHIELD:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_blade_vortex",
        name: "Blade Vortex",
        description: "Blademaster conjures whirling blades that chases the target, dealing damage and granting him mana over time until it expires.",
        //lore:  `An ancient technique that has been passed down for generations.`,
        ability_specials: [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
            {
                ability_special: "base_dmg",
                text: "DAMAGE:"
            },
            {
                ability_special: "mana_gain_percent_bonus",
                text: "MANA GAIN:",
                percentage: true
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_chain_hook",
        name: "Chain Hook",
        description: "Blademaster throws a hook out that attaches to an friendly or enemy target, pulling himself towards it.",
        lore: "Every fighter needs a trick up his sleeve.",
        notes: [
            "Blademaster is not invulnerable during the movement.",
            "Friendly and enemy targets include structures or summons."
        ],
        ability_specials: []
    });
    Abilities.push({
        ability_classname: "warlord_passive",
        name: "Blade Mastery",
        description: 'Blademaster basic attack has cleave and grants mana on hit.',
        notes: [],
        ability_specials: [
            {
                ability_special: "mana_gain_percent",
                text: "MANA GAIN:",
                percentage: true
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}
exports.GenerateLocalizationData = GenerateLocalizationData;
