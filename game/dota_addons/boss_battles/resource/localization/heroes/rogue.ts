import { AbilityLocalization, LocalizationData, ModifierLocalization, StandardLocalization } from "~generator/localizationInterfaces";

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

    // modifiers
    Modifiers.push({
        modifier_classname: "q_smoke_bomb_modifier",
        name: "Evasive",
        description: `Increased movement speed and invulnerability.`,
    });
    Modifiers.push({
        modifier_classname: "m2_energy_buff",
        name: "Adrenaline",
        description: `Regenerates %dMODIFIER_PROPERTY_MANA_REGEN_CONSTANT% energy per second.`,
    });
    Modifiers.push({
        modifier_classname: "space_shadowstep_caster_modifier",
        name: "Shadow Dagger",
        description: `Shadowstep.`,
    });
    Modifiers.push({
        modifier_classname: "e_swallow_potion_modifier",
        name: "Envenom",
        description: `Current Envenom stacks.`,
    });
    Modifiers.push({
        modifier_classname: "e_swallow_potion_modifier_ability",
        name: "Envenom",
        description: `Your next attack is embued with venom.`,
    });
    Modifiers.push({
        modifier_classname: "m2_combo_breaker_modifier",
        name: "Assassinate",
        description: `Your next attack strikes with precision.`,
    });

    // abilities
    Abilities.push({
        ability_classname: "m1_combo_hit_1_2",
        name: "Lacerate",
        description: `Rogue delivers a quick slash to all enemies in front of her that deals damage and inflicts a bleed to all targets. Bleeds dealt by this ability are amplified by <b><font color=\"#6f92fc\">Envenom</font></b>.`,
        //lore: `Death by a thousand cuts.`,
        ability_specials:
        [
            {
                ability_special: "damage",
                text: "DAMAGE:"
            },
            {
                ability_special: "dmg_dot_base",
                text: "BLEED DAMAGE:"
            },
            {
                ability_special: "bleed_duration",
                text: "DURATION:"
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
        ]
    });
   //Abilities.push({
        //ability_classname: "m1_combo_hit_3",
        //name: "Lacerate",
        //description: `Rogue ends with a deadly attack that deals damage and inflicts a bleed to all targets. Bleeds dealt by this ability are amplified by <b><font color=\"#6f92fc\">Envenom</font></b>.`,
        //notes:
        //[
            //`At the end of the attack this ability will change back into Slash.`,
        //],
        //ability_specials:
        //[
            //{
                //ability_special: "damage",
                //text: "DAMAGE:"
            //},
            //{
                //ability_special: "AbilityCastPoint",
                //text: "CAST POINT:"
            //},
            //{
                //ability_special: "dmg_dot_base",
                //text: "BLEED DAMAGE:"
            //},
        //]
    //});
    Abilities.push({
        ability_classname: "m2_combo_breaker",
        name: "Assassinate",
        description: `Rogue assassinates the targets with a strike that consumes the bleeds from <font color=\"#9af9e0\">Lacerate</font> and <font color=\"#9af9e0\">Rupture</font>, dealing damage based on their remaing duration. Additionally it will consume 3 stacks of <font color=\"#9af9e0\">Envenom</font> and grants <font color=\"#6f92fc\">Adrenaline</font>.`,
        //lore: `A technique taught by the sisterhood to ensure a quick and clean kill.`,
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
                text: "ADRENALINE ENERGY PER SECOND:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_smoke_bomb",
        name: "Smoke Bomb",
        description: `Rogue instantly disappears in a cloud of smoke, briefly granting invulnerability and increased movement speed.`,
        //lore: `A simple yet effective tool to escape combat.`,
        notes:
        [
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
        description: `Rogue cuts all enemies infront of her with an envenomed blade, applying a debuff that increases the damage they take from all bleeds and gives rogue a stack of <font color=\"#9af9e0\">Envenom</font>`,
        //lore: `A secret mixture of the deadliest toxins known to man.`,
        notes:
        [
            "In solo mode if the Rogue has max stacks of <font color=\"#9af9e0\">Envenom</font> they will be healed %heal_tick% per second."
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
				ability_special: "bonus_bleed_percent",
                text: "ENVENOM BONUS DAMAGE:",
				percentage: true
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_rupture",
        name: "Rupture",
        description: `Rogue throws a dagger that pierces through all enemies and applies a bleed. Bleeds dealt by this ability are amplified by <b><font color=\"#6f92fc\">Envenom</font></b>.`,
        //lore: ``,
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
​
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:"
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_shadowstep",
        name: "Shadowstep",
        description: `Rogue marks the ground with a shadowy dagger that can be teleported to.`,
        notes:
        [
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
        description: `Jump to dagger's location and place a dagger from the starting location.`,
        notes:
        [
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
        ],
        ability_specials:
        [
        ]
    });
    Abilities.push({
        ability_classname: "rogue_passive",
        name: "Lacerate",
        description: 'Rogue basic attack has cleave and applies a bleed to all enemies in front of her. Bleeds dealt by this ability are amplified by <b><font color=\"#6f92fc\">Envenom</font></b>.',
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "bleed_duration",
                text: "BLEED DURATION:"
            },
			
            {
                ability_special: "dmg_dot_base",
                text: "BLEED DAMAGE:",
            },

            {
                ability_special: "damage_interval",
                text: "INTERVAL:",
            },

            {
                ability_special: "bonus_bleed_percent",
                text: "BONUS BLEED DAMAGE",
                percentage: true
            },
        ]
    });


    // Return data to compiler
    return localization_info;
}
