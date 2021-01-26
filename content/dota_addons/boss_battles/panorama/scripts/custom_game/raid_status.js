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

    //$.Msg( "data ", data )
    //$.Msg( "data playerid ", data["PlayerID"] )
    //$.Msg( "data HeroName ", data["HeroName"] )

    let playersFrameContainer = $("#PlayersFrameContainer")

    let playerData = data["HeroName"]

    let playerFrame = $.CreatePanel("Panel", playersFrameContainer, playerData["PlayerID"]);
    playerFrame.BLoadLayoutSnippet("PlayerFrame");

    var heroImage = $("#HeroImage")
    heroImage.heroname = playerData["hero_name"]

    var pLivesLabel = $("#PlayerLivesLabel")
    pLivesLabel.text = playerData["playerLives"]

    var pNameLabel = $("#PlayerNameLabel")
    pNameLabel.text = playerData["playerName"]

    var pHealthLabel = $("#PlayerHealthLabel")
    pHealthLabel.text = playerData["hpPercent"] + "%"

    var pHealthLeft = $("#PlayerHealthProgressLeft")
    pHealthLeft.style.width = playerData["hpPercent"]+"%"

    var pHealthRight = $("#PlayerHealthProgressRight")
    var hpGone = 100 - playerData["hpPercent"]
    pHealthRight.style.width = hpGone+"%"
    
    var pManaLabel = $("#PlayerManaLabel")
    pManaLabel.text = playerData["mpPercent"]+"%"

    var pManaLeft = $("#PlayerManaProgressLeft")
    pManaLeft.style.width = playerData["mpPercent"]+"%"

    var pManaRight = $("#PlayerManaProgressRight")
    var mpGone = 100 - playerData["mpPercent"]
    pManaRight.style.width = mpGone+"%"

    //store this panel to update it later.
    playerFramePanels[data["PlayerID"]] = playerFrame
}

function updatePlayerFrames(data)
{
    //$.Msg("runing updaet?")
    //$.Msg("data ",data)
    //$.Msg("playerFramePanels ",playerFramePanels)
    //$.Msg("data id ",data.data["id"])
    //$.Msg("-----------------------") 

    var pLivesLabel = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerLivesLabel")
    pLivesLabel.text = data.data["lives"]

    var pHealthLabel = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerHealthLabel")
    pHealthLabel.text = data.data["hpPercent"] + "%"

    var pHealthLeft = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerHealthProgressLeft")
    pHealthLeft.style.width = data.data["hpPercent"]+"%"
    var hpGone = 100 - data.data["hpPercent"]

    var pHealthRight = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerHealthProgressRight")
    pHealthRight.style.width = hpGone+"%"

    var pManaLabel = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerManaLabel")
    pManaLabel.text = data.data["mpPercent"]+"%"

    var pManaLeft = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerManaProgressLeft")
    pManaLeft.style.width = data.data["mpPercent"]+"%"
    var mpGone = 100 - data.data["mpPercent"]

    var pManaRight = playerFramePanels[data.data["id"]].FindChildTraverse("PlayerManaProgressRight")
    pManaRight.style.width = mpGone+"%"
}


function hidePlayerFrame( table_name, key, data )
{
    //$.Msg("hidePlayerFrame called")
    //var bossFrameContainer = $("#BossFrameContainer")
    // bossFrameContainer.RemoveAndDeleteChildren()
}

GameEvents.Subscribe( "create_player_frame", createPlayerFrames );
//GameEvents.Subscribe( "update_player_frame", updatePlayerFrames );
//CustomNetTables.SubscribeNetTableListener( "player_frame", updatePlayerFrames );
CustomNetTables.SubscribeNetTableListener( "hide_player_frame", hidePlayerFrame );

/* END Player UI Frames */

