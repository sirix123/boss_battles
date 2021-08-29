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

    // Enter localization data below!
    // Variables
    const bladeMasteryColour = `<b><font color=\"#6f92fc\">Blade Mastery</font></b>`
    const sunderColour = `<b><font color=\"#ffffff\">Sunder</font></b>`
    const fightingSpiritColour = `<b><font color=\"#6f92fc\">Fighting Spirit</font></b>`
    const bladeVortexColour = `<b><font color=\"#ffffff\">Blade Vortex</font></b>`
    const inspireColour = `<b><font color=\"#ffffff\">Inspire</font></b>`
    const barricadeColour = `<b><font color=\"#ffffff\">Barricade</font></b>`

    // modifiers
    Modifiers.push({
        modifier_classname: "m2_sword_slam_debuff",
        name: "Blade Mastery",
        description: `The damage of Sword Slam is increased.`,
    });

    Modifiers.push({
        modifier_classname: "warlord_modifier_shouts",
        name: "Fighting Spirit",
        description: `Regenerates %dMODIFIER_PROPERTY_MANA_REGEN_CONSTANT% mana per second and %dMODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT% health per second.`,
    });

    Modifiers.push({
        modifier_classname: "e_warlord_shout_modifier",
        name: "Endurance",
        description: `Absorbs incoming damage.`,
    });

    Modifiers.push({
        modifier_classname: "q_conq_shout_modifier",
        name: "Conquerer Shout",
        description: `Your vortex is generating you energy and have increased damage.`,
    });

    Abilities.push({
        ability_classname: "m1_sword_slash",
        name: "Sweeping Blade",
        description: `Blademaster performs a wide sweeping cut to deal damage to all enemies infront of him.`,
        //lore: `Blademaster's sword techniques are unparalleled for cutting down swathes of enemies.`,
        notes:
        [

        ],
        ability_specials:
        [
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
        name: "Sunder",
        description: `Blademaster slams down his sword, dealing damage based on his total energy to all enemies infront of him. Hitting an enemy with ${sunderColour} grants a stack of ${bladeMasteryColour}, up to three times.`,
        //lore: `What doesn't kill his opponents only makes him stronger.`,
        ability_specials:
        [
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
                ability_special: "dmg_per_mana_point",
                text: "DAMAGE PER ENERGY:",
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
        description: `Blademaster inspires his allies near him and his ${bladeVortexColour}, increasing their damage. ${inspireColour} also generates one stack of ${fightingSpiritColour}.`,
        //lore: `Blademaster's military experience allows him to inspire his allies to push forward against overwhelming odds.`,
        notes:
        [
            `Fighting Spirit regenerates 5 health per second and 2 energy per second.`,
            `Fighting Spirit can stack up to three times.`,
        ],
        ability_specials:
        [
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
        description: `Blademaster defends his allies near him and his ${bladeVortexColour}, granting them a shield. ${barricadeColour} also generates one stack of ${fightingSpiritColour}.`,
        //lore: `The long and bitter war against the Templars revealed the importance of proper defence.`,
        notes:
        [
            `Fighting Spirit regenerates 5 health per second and 2 energy per second.`,
            `Fighting Spirit can stack up to three times.`,
        ],
        ability_specials:
        [
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
        description: `Blademaster conjures whirling blades that chases the target, dealing damage and granting him energy over time until it expires.`,
        //lore:  `An ancient technique that has been passed down for generations.`,
        ability_specials:
        [
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
                text: "ENERGY GAIN:",
                percentage: true
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_chain_hook",
        name: "Chain Hook",
        description: `Blademaster throws a hook out that attaches to an friendly or enemy target, pulling himself towards it.`,
        //lore: `Every fighter needs a trick up his sleeve.`,
        notes:
        [
            `Blademaster is not invulnerable during the movement.`,
            `Friendly and enemy targets include structures or summons.`
        ],
        ability_specials:
        [

        ]
    });


    // Return data to compiler
    return localization_info;
}
