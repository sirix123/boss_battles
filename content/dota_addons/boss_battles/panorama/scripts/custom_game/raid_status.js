"use strict";

CustomNetTables.SubscribeNetTableListener( "boss_frame", bossFrameUpdate ); // update the boss frame (mana and hp)
GameEvents.Subscribe( "hide_boss_frame", hideBossFrame ); // hide the boss frames (mana and hp)

GameEvents.Subscribe( "hide_boss_mana_frame", hideBossManaFrame ); // hide boss mana bar
GameEvents.Subscribe( "show_boss_mana_frame", showBossManaFrame ); // show boss mana bar

GameEvents.Subscribe( "hide_boss_hp_frame", hideBossHpFrame ); // hide boss health bar
GameEvents.Subscribe( "show_boss_hp_frame", showBossHpFrame ); // show boss health bar

GameEvents.Subscribe( "change_boss_name", changeBossName ); // hide boss health bar

// some global inits
let show_mana_bar = true
let show_health_bar = true
let boss_name = ""

/* Boss Frame UI */
function bossFrameUpdate( table_name, key, data )
{
    //$.Msg("bossFrameUpdate called")
    //$.Msg("table_name = ", table_name)
    //$.Msg("key = ", key)
    //$.Msg("data = ", data)

    //$.Msg("show_mana_bar ",show_mana_bar)
    //$.Msg("show_health_bar ",show_health_bar)
    //$.Msg("boss_name ",boss_name)

    //remove any existing children:
    var bossFrameContainer = $("#BossFrameContainer")
    bossFrameContainer.RemoveAndDeleteChildren()

    //Draw the boss frame. 
    if (key != "hide" )
    {
        if (bossFrameContainer)
        {

            bossFrameContainer.style.visibility = 'visible';

            var containerPanel = $.CreatePanel("Panel", bossFrameContainer, data);
            containerPanel.BLoadLayoutSnippet("BossFrame");

            // set boss name 
            var bossLabel = containerPanel.FindChildInLayoutFile("BossNameLabel");
            bossLabel.text = boss_name;

            // grab the health bar and mana
            let healthBar = containerPanel.FindChildInLayoutFile("BossHealthContainer");
            let manaBar = containerPanel.FindChildInLayoutFile("BossManaContainer");

            //update hp bar 
            if ( show_health_bar != false ) {
                healthBar.style.visibility = 'visible';
                var bossHealthLabel = $("#BossHealthLabel")
                var bossHealthProgressLeft = $("#BossHealthProgressLeft")
                var bossHealthProgressRight = $("#BossHealthProgressRight")
                bossHealthProgressLeft.style.width = data["hpPercent"]+"%"
                var hpGone = 100 - data["hpPercent"]
                bossHealthProgressRight.style.width = hpGone+"%"
                bossHealthLabel.text = data["hpPercent"] + "%"
            } else if ( show_health_bar == false) {
                //healthBar.RemoveAndDeleteChildren()
                healthBar.style.visibility = 'collapse';
            }

            //update mana bar
            if ( show_mana_bar != false ) {
                manaBar.style.visibility = 'visible';
                var bossManaLabel = $("#BossManaLabel")
                var bossManaProgressLeft = $("#BossManaProgressLeft")
                var bossManaProgressRight = $("#BossManaProgressRight")
                bossManaProgressLeft.style.width = data["mpPercent"]+"%"
                var mpGone = 100 - data["mpPercent"]
                bossManaProgressRight.style.width = mpGone+"%"
                bossManaLabel.text = data["mpPercent"]+"%"
            } else if ( show_mana_bar == false) {
                //manaBar.RemoveAndDeleteChildren()
                manaBar.style.visibility = 'collapse';
            }

            //update status/buff/debuffs bar
            //TODO: actually get this data into a table..
        }
    }
    else {
        $.Msg("hide the frames")
        bossFrameContainer.style.visibility = 'collapse';
    } //Don't draw. effectively hiding/removing the ui
}


function hideBossFrame( table_name, key, data )
{
    var bossFrameContainer = $("#BossFrameContainer")
    bossFrameContainer.style.visibility = 'collapse';
}

function hideBossManaFrame( table_name, key, data )
{
    show_mana_bar = false
}

function showBossManaFrame( table_name, key, data )
{
    show_mana_bar = true
}

function hideBossHpFrame( table_name, key, data )
{
    show_health_bar = false
}

function showBossHpFrame( table_name, key, data )
{
    show_health_bar = true
}

function changeBossName( data )
{
    boss_name = data.bossName
}
/* END Boss Frame UI */


/* Player UI Frames */
let playerFramePanels = {};

function createPlayerFrames(data)
{
    let playersFrameContainer = $("#PlayersFrameContainer")

    let playerFrame = $.CreatePanel("Panel", playersFrameContainer, data["PlayerID"]);
    playerFrame.BLoadLayoutSnippet("PlayerFrame");

    var heroImage = playerFrame.FindChildInLayoutFile('HeroImage');
    heroImage.heroname = data["HeroData"].hero_name 

    heroImage.SetImage('file://{images}/heroes/selection/' + data["HeroData"].hero_name  + '.png');
    heroImage.style.backgroundImage = 'url("file://{images}/heroes/' + data["HeroData"].hero_name  + '.png")';
    heroImage.style.backgroundSize = "100% 100%";

    var pNameLabel = playerFrame.FindChildTraverse("PlayerNameLabel")
    pNameLabel.text = data["HeroData"].playerName

    playerFramePanels[data["PlayerID"]] = playerFrame;
}

function updatePlayerFrames(data)
{

    let playersFrameContainer = $("#PlayersFrameContainer")

    for (let i=0; i < playersFrameContainer.GetChildCount(); i++)
    {
        var playerFrame = playerFramePanels[i]

        if ( data["PlayerID"] == playerFrame.id ) 
        {
            // sent from server
            var pLivesLabel = playerFrame.FindChildTraverse("PlayerLivesLabel")
            pLivesLabel.text = data["HeroData"].playerLives

            // client side api
            var hero = Players.GetPlayerHeroEntityIndex( data["PlayerID"] )
            var health = Entities.GetHealth( hero )
            var healthMax = Entities.GetMaxHealth( hero )
            var mana = Entities.GetMana( hero )
            var manaMax = Entities.GetMaxMana( hero )

            let percent_health = Math.round( ( health / healthMax ) * 100 )
            let percent_mana = Math.round( ( mana / manaMax ) * 100 )

            var pHealthLabel = playerFrame.FindChildTraverse("PlayerHealthLabel")
            pHealthLabel.text = percent_health + "%"

            var pHealthLeft = playerFrame.FindChildTraverse("PlayerHealthProgressLeft")
            pHealthLeft.style.width = percent_health + "%"
            var hpGone = 100 - percent_health

            var pHealthRight = playerFrame.FindChildTraverse("PlayerHealthProgressRight")
            pHealthRight.style.width = hpGone+"%"

            if ( mana == 0 )
            {
                percent_mana = 0
            }
            else
            {
                var pManaLabel = playerFrame.FindChildTraverse("PlayerManaLabel")
                pManaLabel.text = percent_mana+"%"

                var pManaLeft = playerFrame.FindChildTraverse("PlayerManaProgressLeft")
                pManaLeft.style.width = percent_mana+"%"
                var mpGone = 100 - percent_mana

                var pManaRight = playerFrame.FindChildTraverse("PlayerManaProgressRight")
                pManaRight.style.width = mpGone+"%"
            }
        }
    }
}

//this isnt used because the hero portaits dont exist for portraits
function changePortraits( data ){
    let playersFrameContainer = $("#PlayersFrameContainer")

    for (let i=0; i < playersFrameContainer.GetChildCount(); i++)
    {
        var playerFrame = playerFramePanels[i]

        if ( data.player_id == playerFrame.id ) 
        {
            var heroImage = playerFrame.FindChildInLayoutFile('HeroImage');
            heroImage.heroname = data.hero_portrait
            
            heroImage.SetImage('file://{images}/heroes/selection/' + data.hero_portrait + '.png');
            heroImage.style.backgroundImage = 'url("file://{images}/heroes/' + data.hero_portrait + '.png")';
            heroImage.style.backgroundSize = "100% 100%";
        }
    }
}

GameEvents.Subscribe( "create_player_frame", createPlayerFrames );
GameEvents.Subscribe( "update_player_frame", updatePlayerFrames );
GameEvents.Subscribe( "update_player_frame_cosmetic_equipped", changePortraits );

