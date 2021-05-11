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
    const bloodBrotherColour = `<b><font color=\"#60f6ce\">Blood Pact</font></b>`
	const bloodMagicColour = `<b><font color=\"#f33939\">Blood Magic</font></b>`
    // modifiers
    Modifiers.push({
        modifier_classname: "m2_qop_stacks",
        name: "Blood Magic",
        description: `Blood Light manacost has increased (STACK COUNT HERE) times.`
    });
    Modifiers.push({
        modifier_classname: "e_qop_shield_modifier",
        name: "Blood Ward",
        description: `Absorbing (REMAINING SHIELD) damage.`
    });
    Modifiers.push({
        modifier_classname: "ally_buff_heal",
        name: "Blood Brother",
        description: `Recieving healing based on Akasha's damage.`
    });
    // abilities
    Abilities.push({
        ability_classname: "m1_qop_basic_attack",
        name: "Dagger Toss",
        description: `Akasha throws a bloody dagger that deals damage to an enemy`,
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
        ]
    });
    Abilities.push({
        ability_classname: "m2_qop_direct_heal",
        name: "Blood Light",
        description: `Akasha bathes an ally in blood. Subsequent casts will apply ${bloodMagicColour} to Akasha, doubling the manacost. Healing an ally in this way applies ${bloodBrotherColour}. `,
        ability_specials:
        [
            {
                ability_special: "base_heal",
                text: "HEAL:"
            },
            {
                ability_special: "duration_main_buff",
                text: "BUFF DURATION:",
            },
            {
                ability_special: "duration_debuff",
                text: "DEBUFF DURATION:",
            },
            {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "q_pen",
        name: "Exsanguinate",
        description: `Akasha drains the blood out of an enemy, healing herself and dealing damage. If used on an ally, heals them instead.`,
		notes:
        [
            `Exsanguinate deals damage once per second`,
        ],
        ability_specials:
        [
            {
                ability_special: "max_ticks",
                text: "TICKS:",
            },
            {
                ability_special: "dmg",
                text: "DAMAGE:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "e_qop_shield",
        name: "Blood Ward",
        description: `Akasha casts a Blood Ward on the target and consumes all stacks of ${bloodMagicColour}, empowering it. If cast on an ally, Blood Ward absorbs incoming damage. If cast on an enemy, Blood Ward stores a portion of incoming damage for a duration, dealing that damage on expiration.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },
            {
                ability_special: "base_bubble",
                text: "SHIELD:",
            },
			{
                ability_special: "dmg_multiplier",
                text: "DAMAGE PER STACK:",
				percentage: true,
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_delayed_aoe_heal",
        name: "Demonic Rune",
        description: `Akasha marks the target area with a powerful rune, dealing damage until it explodes. Upon exploding, the rune grants Akasha mana.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },
            {
                ability_special: "dmg",
                text: "DAMAGE:",
            },
            {
                ability_special: "mana",
                text: "MANA GAIN:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_leap_of_grip",
        name: "Deathgrip",
        description: `Akasha pulls an ally towards herself. Has two charges that recover over time.`,
		notes:
        [
            `Deathgrip can pull allies while stunned but not rooted.`,
			`Deathgrip has two charges.`
        ],
        ability_specials:
        [
            {
                ability_special: "speed",
                text: "PULL SPEED:",
            },		
		    {
                ability_special: "AbilityCastPoint",
                text: "CAST POINT:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "qop_passive",
        name: "Living Blood",
        description: `If Akasha deals damage to an enemy while herself or an ally is affected by ${bloodBrotherColour}, a portion of that damage will heal them.`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "ADD HEALING PERCENT HERE",
                text: "HEAL:", 
				percentage: true,
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}