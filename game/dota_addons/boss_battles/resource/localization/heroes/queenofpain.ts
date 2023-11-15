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
    const bloodPactColour = `<b><font color=\"#60f6ce\">Blood Pact</font></b>`
	const bloodMagicColour = `<b><font color=\"#f33939\">Blood Magic</font></b>`
    const bloodWardColour = `<b><font color=\"#ffffff\">Blood Ward</font></b>`

    // modifiers
    Modifiers.push({
        modifier_classname: "m2_qop_stacks",
        name: "Blood Magic",
        description: `Blood Light manacost doubles per stack.`
    });
    Modifiers.push({
        modifier_classname: "e_qop_shield_modifier",
        name: "Blood Ward",
        description: `Absorbs incoming damage.`
    });
    Modifiers.push({
        modifier_classname: "ally_buff_heal",
        name: "Blood Pact",
        description: `Recieving healing based on Akasha's damage.`
    });
    // abilities
    Abilities.push({
        ability_classname: "m1_qop_basic_attack",
        name: "Shadow Strike",
        description: `Akasha throws a cursed dagger that deals damage to an enemy.`,
        //lore: `Akasha's daggers are specifically designed to draw out the blood of her enemies.`,
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
        description: `Akasha bathes an ally in blood. Subsequent casts will apply ${bloodMagicColour} to Akasha, doubling the manacost and healing. Healing an ally in this way applies ${bloodPactColour}. `,
        //lore: `The healing properties of Blood Magic are just as renowned as its destructive ones.`,
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
        //lore: `Manipulating the flow of blood of both ally and foe alike is an easy task for Akasha.`,
		notes:
        [
            `Exsanguinate deals damage once per second`,
        ],
        ability_specials:
        [
            {
                ability_special: "max_ticks",
                text: "DURATION:",
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
        description: `Akasha casts a ${bloodWardColour} on the target and consumes all stacks of ${bloodMagicColour}, empowering it. If cast on an ally, ${bloodWardColour} absorbs incoming damage. If cast on an enemy, ${bloodWardColour} stores incoming damage for a duration, dealing a portion of that damage on expiration.`,
        //lore: `A simple spell first used to protect Akasha and her allies, it has since found use in tormenting her enemies.`,
        notes:
        [
            `The base cooldown for Blood Ward on allies is one second.`,
            `The base cooldown for Blood Ward on enemies is two seconds.`,
            `The cooldown of Blood Ward doubles per stack of Blood Magic on Akasha.`
        ],
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
                text: "STORED DAMAGE:",
				percentage: true,
            },
        ]
    });
    Abilities.push({
        ability_classname: "r_delayed_aoe_heal",
        name: "Vampiric Rune",
        description: `Akasha marks the target area with a powerful rune, dealing damage and granting mana over time until it explodes.`,
        //lore: `An ancient rune passed down from Akasha's bloodline.`,
        ability_specials:
        [
            {
                ability_special: "duration",
                text: "DURATION:",
            },
            {
                ability_special: "dmg",
                text: "DAMAGE PER SECOND:",
            },
            {
                ability_special: "mana",
                text: "MANA PER SECOND:",
            },
        ]
    });
    Abilities.push({
        ability_classname: "space_leap_of_grip",
        name: "Deathgrip",
        description: `Akasha pulls an ally towards herself. Has two charges that recover over time.`,
        //lore: `A powerful blood magic spell that draws the living closer in her grip.`,
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
        description: `If Akasha deals damage to an enemy while herself or an ally is affected by ${bloodPactColour}, a portion of that damage will heal them.`,
        //lore: `Akasha's vampiric aura uses the essence of her foes to restore her allies.`,
        notes:
        [
        ],
        ability_specials:
        [
            {
                ability_special: "dmg_to_heal_reduction",
                text: "HEAL:", 
				percentage: true,
            },
        ]
    });
    // Return data to compiler
    return localization_info;
}