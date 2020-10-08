/* Boss Frame UI */

function bossFrameUpdate( table_name, key, data )
{
    //$.Msg("bossFrameUpdate called")
    //$.Msg("table_name = ", table_name)
    //$.Msg("key = ", key)
    // $.Msg("data = ", data)
    
    var bossFrameContainer = $("#BossFrameContainer")
    //remove any existing children:
    bossFrameContainer.RemoveAndDeleteChildren()

    //Draw the boss frame. 
    if (key != "hide" )
    {
        if (bossFrameContainer)
        {
            var containerPanel = $.CreatePanel("Panel", bossFrameContainer, data);
            containerPanel.BLoadLayoutSnippet("BossFrame");

            //update hp bar 
            var bossHealthLabel = $("#BossHealthLabel")
            var bossHealthProgressLeft = $("#BossHealthProgressLeft")
            var bossHealthProgressRight = $("#BossHealthProgressRight")
            bossHealthProgressLeft.style.width = data["hpPercent"]+"%"
            var hpGone = 100 - data["hpPercent"]
            bossHealthProgressRight.style.width = hpGone+"%"
            bossHealthLabel.text = data["hpPercent"] + "%"

            //update mana bar
            var bossManaLabel = $("#BossManaLabel")
            var bossManaProgressLeft = $("#BossManaProgressLeft")
            var bossManaProgressRight = $("#BossManaProgressRight")
            bossManaProgressLeft.style.width = data["mpPercent"]+"%"
            var mpGone = 100 - data["mpPercent"]
            bossManaProgressRight.style.width = mpGone+"%"
            bossManaLabel.text = data["mpPercent"]+"%"

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

CustomNetTables.SubscribeNetTableListener( "boss_frame", bossFrameUpdate );
CustomNetTables.SubscribeNetTableListener( "hide_boss_frame", hideBossFrame );

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
