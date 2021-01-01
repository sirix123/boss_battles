CustomNetTables.SubscribeNetTableListener( "boss_frame", bossFrameUpdate ); // update the boss frame (mana and hp)
CustomNetTables.SubscribeNetTableListener( "hide_boss_frame", hideBossFrame ); // hide the boss frames (mana and hp)

GameEvents.Subscribe( "hide_boss_mana_frame", hideBossManaFrame ); // hide boss mana bar
GameEvents.Subscribe( "show_boss_mana_frame", showBossManaFrame ); // show boss mana bar

GameEvents.Subscribe( "hide_boss_health_frame", hideBossHpFrame ); // hide boss health bar
GameEvents.Subscribe( "show_boss_health_frame", showBossHpFrame ); // show boss health bar

GameEvents.Subscribe( "change_boss_name", changeBossName ); // hide boss health bar

// some global inits
show_mana_bar = true
show_health_bar = true
boss_name = ""

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
    //$.Msg("---------------------")
    
    //remove any existing children:
    var bossFrameContainer = $("#BossFrameContainer")
    bossFrameContainer.RemoveAndDeleteChildren()

    //Draw the boss frame. 
    if (key != "hide" )
    {
        if (bossFrameContainer)
        {
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
                var bossHealthLabel = $("#BossHealthLabel")
                var bossHealthProgressLeft = $("#BossHealthProgressLeft")
                var bossHealthProgressRight = $("#BossHealthProgressRight")
                bossHealthProgressLeft.style.width = data["hpPercent"]+"%"
                var hpGone = 100 - data["hpPercent"]
                bossHealthProgressRight.style.width = hpGone+"%"
                bossHealthLabel.text = data["hpPercent"] + "%"
            } else if ( show_health_bar == false) {
                healthBar.RemoveAndDeleteChildren()
            }

            //update mana bar
            if ( show_mana_bar != false ) {
                var bossManaLabel = $("#BossManaLabel")
                var bossManaProgressLeft = $("#BossManaProgressLeft")
                var bossManaProgressRight = $("#BossManaProgressRight")
                bossManaProgressLeft.style.width = data["mpPercent"]+"%"
                var mpGone = 100 - data["mpPercent"]
                bossManaProgressRight.style.width = mpGone+"%"
                bossManaLabel.text = data["mpPercent"]+"%"
            } else if ( show_mana_bar == false) {
                manaBar.RemoveAndDeleteChildren()
            }

            //update status/buff/debuffs bar
            //TODO: actually get this data into a table..
        }
    }
    else {
    } //Don't draw. effectively hiding/removing the ui
}


function hideBossFrame( table_name, key, data )
{
    var bossFrameContainer = $("#BossFrameContainer")
    bossFrameContainer.RemoveAndDeleteChildren()
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

var playerFramePanels = {};

function createPlayerFrames(data)
{
    var playersFrameContainer = $("#PlayersFrameContainer")
    //TODO: change to loop over playerData.
    for (var i in data)
    {
        var playerData = data[i]

        var playerFrame = $.CreatePanel("Panel", playersFrameContainer, "");
        playerFrame.BLoadLayoutSnippet("PlayerFrame");

        var heroImage = $("#HeroImage")
        heroImage.heroname = playerData["className"]

        var pLivesLabel = $("#PlayerLivesLabel")
        pLivesLabel.text = playerData["lives"]

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
        playerFramePanels[i] = playerFrame
    }
}

function updatePlayerFrames(data)
{
    var playersFrameContainer = $("#PlayersFrameContainer")
    for (var i in data)
    {
        var playerData = data[i]
        var playerFrame = playerFramePanels[i]

        var pNameLabel = playerFrame.FindChildTraverse("PlayerNameLabel")
        pNameLabel.text = playerData["playerName"]

        var pLivesLabel = $("#PlayerLivesLabel")
        pLivesLabel.text = playerData["lives"]

        var pHealthLabel = playerFrame.FindChildTraverse("PlayerHealthLabel")
        pHealthLabel.text = playerData["hpPercent"] + "%"

        var pHealthLeft = playerFrame.FindChildTraverse("PlayerHealthProgressLeft")
        pHealthLeft.style.width = playerData["hpPercent"]+"%"
        var hpGone = 100 - playerData["hpPercent"]

        var pHealthRight = playerFrame.FindChildTraverse("PlayerHealthProgressRight")
        pHealthRight.style.width = hpGone+"%"

        var pManaLabel = playerFrame.FindChildTraverse("PlayerManaLabel")
        pManaLabel.text = playerData["mpPercent"]+"%"

        var pManaLeft = playerFrame.FindChildTraverse("PlayerManaProgressLeft")
        pManaLeft.style.width = playerData["mpPercent"]+"%"
        var mpGone = 100 - playerData["mpPercent"]

        var pManaRight = playerFrame.FindChildTraverse("PlayerManaProgressRight")
        pManaRight.style.width = mpGone+"%"
    }
}



function playerFrameUpdate( table_name, key, data )
{
    //$.Msg("playerFrameUpdate called")
    //$.Msg("table_name = ", table_name)
    //$.Msg("key = ", key)
    //$.Msg("data = ", data)

    var playersFrameContainer = $("#PlayersFrameContainer")
    //create frames on the first call, then just update them.
    if (playersFrameContainer.GetChildCount() == 0)
        createPlayerFrames(data)
    else if (playersFrameContainer.GetChildCount() > 0)
        updatePlayerFrames(data)
}


function hidePlayerFrame( table_name, key, data )
{
    $.Msg("hidePlayerFrame called")
    //var bossFrameContainer = $("#BossFrameContainer")
    // bossFrameContainer.RemoveAndDeleteChildren()
}

CustomNetTables.SubscribeNetTableListener( "player_frame", playerFrameUpdate );
CustomNetTables.SubscribeNetTableListener( "hide_player_frame", hidePlayerFrame );

/* END Player UI Frames */
