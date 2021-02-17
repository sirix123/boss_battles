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
    // variables
    const shatterColour = `<b><font color=\"#9af9e0\">Shatter</font></b>`
    const chillscolour = `<b><font color=\"#6f92fc\">Chills</font></b>`
    const chillcolour = `<b><font color=\"#6f92fc\">Chill</font></b>`
    const icelanceColour = `<b><font color=\"#ffffff\">Ice Lance</font></b>`
    const froststrikeColour = `<b><font color=\"#ffffff\">Frost Strike</font></b>`
    const boneChill = "<b><font color=\"#6f92fc\">Bonechill</font></b>"
    const blizzard = "<b><font color=\"#ffffff\">Blizzard</font></b>"

    // modifiers
    Modifiers.push({
        modifier_classname: "shatter_modifier",
        name: "Shatter",
    });

    Modifiers.push({
        modifier_classname: "bonechill_modifier",
        name: "Bonechill",
        description: `Provides {${LocalizationModifierProperty.MANA_REGEN_CONSTANT}} energy regen.`
    });

    Modifiers.push({
        modifier_classname: "q_iceblock_modifier",
        name: "Ice Block",
        description: `Heals you for {${LocalizationModifierProperty.HEALTH_REGEN_PERCENTAGE}}% of max health per second`
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_iceshot",
        name: "Frost Bolt",
        description: `Long range projectile that deals damage and generates one stack of ${shatterColour}. Also ${chillscolour} target slowing their movement speed and attack speed.`,
        notes:
        [
            `Max ${shatterColour} stacks: {max_shatter_stacks}.`,
            `${shatterColour} Modifies ${icelanceColour} and ${froststrikeColour}.`,
            `${chillcolour} does not affect bosses.`,
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
    
            {
                ability_special: "chill_duration",
                text: "CHILL DURATION:"
            },
    
            {
                ability_special: "ms_slow",
                text: "MOVE SPEED SLOW:",
                percentage: true
            },

            {
                ability_special: "as_slow",
                text: "ATTACK SPEED SLOW:",
                percentage: true
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },

            {
                ability_special: "mana_gain_percent",
                text: "ENERGY GAIN:",
                percentage: true
            },
        ]
    });

    Abilities.push({
        ability_classname: "m2_icelance",
        name: "Ice Lance",
        description: `Fire {max_proj} long range projectile(s) that deal damage. The projectiles have a delay between them. If ${icelanceColour} hits a target when the caster has max ${shatterColour} stacks it grants the caster ${boneChill}.`,
        notes:
        [
            `Consumes all ${shatterColour} stacks.`,
            `The first ${icelanceColour} also explodes dealing extra damage based on number of ${shatterColour} stacks.`,
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE EACH:"
            },
    
            {
                ability_special: "base_shatter_dmg",
                text: "SHATTER EXPLODE DAMAGE:"
            },
    
            {
                ability_special: "shatter_dmg_xStacks",
                text: "DAMAGE PER SHATTER:",
            },

            {
                ability_special: "shatter_radius",
                text: "SHATTER RADIUS:",
            },

            {
                ability_special: "bone_chill_duration",
                text: "BONECHILL DURATION:",
            },

            {
                ability_special: "mana_regen",
                text: "BONECHILL ENERGY REGEN:",
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "q_iceblock",
        name: "Ice Block",
        description: `Encases an ally in a block of ice freezing them solid while healing them.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
    
            {
                ability_special: "health_regen_percent",
                text: "HEALTH REGEN:",
                percentage: true,
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "e_icefall",
        name: "Blizzard",
        description: `Summon a Blizzard at target location dealing damage to all targets inside area. ${blizzard} also applies ${chillcolour} to all targets hit. If a non-boss unit stays inside ${blizzard} for 2seconds it is frozen for 5seconds.`,
        notes:
        [
            `${chillcolour} does not affect bosses.`,
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE PER TICK:"
            },

            {
                ability_special: "duration",
                text: "DURATION:"
            },
    
            {
                ability_special: "radius",
                text: "RADIUS:",
            },

            {
                ability_special: "chill_duration",
                text: "CHILL DURATION:",
            },

            {
                ability_special: "chill_duration",
                text: "CHILL DURATION:",
            },

            {
                ability_special: "ms_slow",
                text: "MOVE SPEED SLOW:",
                percentage: true
            },

            {
                ability_special: "as_slow",
                text: "ATTACK SPEED SLOW:",
                percentage: true
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "r_frostbomb",
        name: "Frost Strike",
        description: `Summon a sphere of frost above target location. After a delay the sphere hits the ground and explodes applying a damage over time debuff to all enemies.`,
        notes:
        [
            `Consumes ${boneChill}.`,
        ],
        ability_specials:
        [
            {
                ability_special: "delay",
                text: "DELAY:"
            },

            {
                ability_special: "radius",
                text: "RADIUS:"
            },
    
            {
                ability_special: "damage_interval",
                text: "DAMAGE TICK RATE:",
            },

            {
                ability_special: "fb_bse_dmg",
                text: "BASE DAMAGE:",
            },

            {
                ability_special: "fb_dmg_per_shatter_stack",
                text: "DAMAGE PER SHATTER:",
            },

            {
                ability_special: "fb_base_duration",
                text: "BASE DURATION:",
            },

            {
                ability_special: "fb_bonechill_extra_duration",
                text: "BONUS BONECHILL DURATION:",
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });


    // Return data to compiler
    return localization_info;
}
