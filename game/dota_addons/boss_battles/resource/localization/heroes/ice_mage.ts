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
        description: `Current number of Shatter stacks.`
    });

    Modifiers.push({
        modifier_classname: "bonechill_modifier",
        name: "Bonechill",
        description: `Regenerates {${LocalizationModifierProperty.MANA_REGEN_CONSTANT}} per second.`
    });

    Modifiers.push({
        modifier_classname: "q_iceblock_modifier",
        name: "Ice Block",
        description: `Regenerates {${LocalizationModifierProperty.HEALTH_REGEN_PERCENTAGE}}% of max health per second.`
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_iceshot",
        name: "Frost Bolt",
        description: `Ice mage fires an icy projectile that deals damage and ${chillscolour}, generating one stack of ${shatterColour} on hit.`,
        ability_specials:
        [
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
                percentage: true
            },
        ]
    });

    Abilities.push({
        ability_classname: "m2_icelance",
        name: "Ice Lance",
        description: `Ice mage launches {max_proj} long range frozen projectiles that deal damage and explode upon impact, dealing additional damage based on the number of ${shatterColour} stacks. If ${icelanceColour} consumes 3 ${shatterColour} stacks this way, it grants ${boneChill}.`,
        notes:
        [
            `Consumes all ${shatterColour} stacks.`,
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
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "q_iceblock",
        name: "Ice Block",
        description: `Freezes an ally in a block of ice, rendering them unable to move while reducing their damage taken and healing them for a percentage of their max health per second.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
			
			{
                ability_special: "ADD DMG REDUCTION% HERE",
                text: "DAMAGE REDUCTION:",
				percentage: true,
            },
    
            {
                ability_special: "health_regen_percent",
                text: "MAX HEAL PER SECOND:",
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
        description: `Ice mage summons a violent blizzard at the target location dealing damage and ${chillscolour} all enemies. Enemies affected by ${blizzard} for 2 seconds are frozen in place.`,
        notes:
        [
            `Bosses cannot be frozen.`,
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE PER SECOND:"
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
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });

    Abilities.push({
        ability_classname: "r_frostbomb",
        name: "Frost Strike",
        description: `Ice mage conjures a sphere of frost above target location. After a delay the sphere hits the ground and explodes, dealing damage over time to all enemies. ${froststrikeColour} can consume ${shatterColour} and ${boneChill} to empower its duration and damage.`,
        notes:
        [
            `Consumes Bonechill.`,
			`Shatter only affects the damage over time debuff.`
        ],
        ability_specials:
        [
            {
                ability_special: "delay",
                text: "DELAY:"
            },

            {
                ability_special: "radius",
                text: "RADIUS:",
            },

            {
                ability_special: "fb_bse_dmg",
                text: "DAMAGE PER SECOND:",
            },

            {
                ability_special: "fb_dmg_per_shatter_stack",
                text: "BONUS DAMAGE PER SHATTER:",
            },

            {
                ability_special: "fb_base_duration",
                text: "DURATION:",
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

    Abilities.push({
        ability_classname: "space_frostblink",
        name: "Blink",
        description: `Ice mage teleports forward and ${chillscolour} enemies at the start and end location.`,
        ability_specials:
        [
            {
                ability_special: "mana_gain_percent",
                text: "ENERGY GAIN:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "ice_mage_passive",
        name: "Cold Blood",
        description: `Ice mage passively generates ${shatterColour} stacks through her abilities and can grant her ${boneChill} by consuming them. Additionally, certain abilities will also ${chillcolour} enemies on hit.`,
        notes:
        [
            `${shatterColour} Modifies ${icelanceColour} and ${froststrikeColour}.`,
            `${chillcolour} does not affect bosses.`,
			`${chillcolour} applies to both movement and attack speed.`,
        ],
        ability_specials:
        [
            {
                ability_special: "ADD SHATTER STACKS",
                text: "MAX SHATTER:"
            },
			
            {
                ability_special: "bone_chill_duration",
                text: "BONECHILL DURATION:",
            },

            {
                ability_special: "mana_regen",
                text: "BONECHILL ENERGY PER SECOND:",
            },

            {
                ability_special: "chill_duration",
                text: "CHILL DURATION:"
            },
    
            {
                ability_special: "ms_slow",
                text: "CHILL SLOW:",
                percentage: true
            },
        ]
    });


    // Return data to compiler
    return localization_info;
}
