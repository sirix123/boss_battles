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
        modifier_classname: "q_smoke_bomb_modifier",
        name: "Evasive",
        description: `Provides increased movement speed and invulnerability.`,
    });

    Modifiers.push({
        modifier_classname: "m2_energy_buff",
        name: "Adrenaline",
        description: `Provides %dMODIFIER_PROPERTY_MANA_REGEN_CONSTANT% energy regen.`,
    });

    Modifiers.push({
        modifier_classname: "space_shadowstep_caster_modifier",
        name: "Shadow Dagger",
        description: `Dagger will expire at the end of this buff.`,
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_combo_hit_1_2",
        name: "Slash",
        description: `Short range attack that deals damage in a cone. After 2 attacks this ability changes into another ability.`,
        notes:
        [
            `This is a chain attack, after two attacks this ability changes into Lacerate.`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
    
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "m1_combo_hit_3",
        name: "Lacerate",
        description: `A powerful final attack that deals damage and inflicts a bleed to all targets. Bleeds dealt by this ability are amplified by <b><font color=\"#6f92fc\">Envenom</font></b>.`,
        notes:
        [
            `At the end of the attack this ability will change back into Slash.`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
    
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },

            {
                ability_special: "dmg_dot_base",
                text: "BLEED DAMAGE:"
            },

            {
                ability_special: "bonus_bleed_percent",
                text: "ENVENOM BONUS:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "m2_combo_breaker",
        name: "Assassinate",
        description: `A powerful attack that consumes <font color=\"#9af9e0\">Lacerate</font> and <font color=\"#9af9e0\">Puncture</font> consuming the bleeds and dealing damage based on the bleeds duration remaining. If the caster has maximum stacks of <font color=\"#9af9e0\">Envenom</font> this attack consumes the stacks and gives the caster <font color=\"#6f92fc\">Adrenaline</font>.`,
        notes:
        [
            `Assassinate consumes the bleeds dealing damage based on the duration remaining times the damage per instance.`,
        ],
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
    
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },

            {
                ability_special: "duration",
                text: "ADRENALINE DURATION:"
            },

            {
                ability_special: "energy_regen_bonus",
                text: "ADRENALINE REGEN BONUS:"
            },
        ]
    });

    Abilities.push({
        ability_classname: "q_smoke_bomb",
        name: "Evasion",
        description: `Instantly disappear in a cloud of smoke granting invulnerability for a brief moment and increasing movement speed.`,
        notes:
        [
            `Assassinate consumes the bleeds dealing damage based on the duration remaining times the damage per instance.`,
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },
    
            {
                ability_special: "movespeed_bonus_pct",
                text: "MOVEMENT SPEED BONUS:"
            },

            {
                ability_special: "invul_time",
                text: "INVULNERABILITY:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },

        ]
    });

    Abilities.push({
        ability_classname: "e_swallow_potion",
        name: "Envenom",
        description: `Envenom applies a debuff to enemies hit increasing the damage they take from all bleeds. Ability also generates <b><font color=\"#ffffff\">1</font></b> stack of Envenom per enemy hit stacking up to <b><font color=\"#ffffff\">3</font></b> times. Using Assassinate at maximum Envenom stacks grants the caster Adrenaline.`,
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
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },

        ]
    });

    Abilities.push({
        ability_classname: "r_rupture",
        name: "Rupture",
        description: `Fire a dagger that pierces through enemies applying a bleed to all enemies. Bleeds dealt by this ability are amplified by <b><font color=\"#6f92fc\">Envenom</font></b>.`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "dmg",
                text: "DAMAGE:"
            },
    
            {
                ability_special: "duration",
                text: "DURATION:"
            },

            {
                ability_special: "dmg_dot_base",
                text: "BLEED DAMAGE:"
            },

            {
                ability_special: "bonus_bleed_percent",
                text: "ENVEOM BONUS:"
            },

            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_shadowstep",
        name: "Shadowstep",
        description: `Mark the ground with a special dagger.`,
        notes:
        [
            'This is a combo ability, first cast will place the dagger, second cast will teleport the player to daggers location, third cast will teleport the player back.'
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_shadowstep_teleport",
        name: "Jump",
        description: `Jump to the special daggers location and place a dagger where you left from.`,
        notes:
        [
            'This is a combo ability, first cast will place the dagger, second cast will teleport the player to daggers location, third cast will teleport the player back.'
        ],
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:"
            },

        ]
    });

    Abilities.push({
        ability_classname: "space_shadowstep_teleport_back",
        name: "Return",
        description: `Return to start location.`,
        notes:
        [
            'This is a combo ability, first cast will place the dagger, second cast will teleport the player to daggers location, third cast will teleport the player back.'
        ],
        ability_specials:
        [

        ]
    });


    // Return data to compiler
    return localization_info;
}
