/* Boss Frame UI */

function bossFrameUpdate( table_name, key, data )
{
    //$.Msg("bossFrameUpdate called")
    // $.Msg("table_name = ", table_name)
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


function heroFrameUpdate( table_name, key, data )
{
    // $.Msg("heroFrameUpdate( table_name, key, data )")
    // $.Msg("table_name = ", table_name)
    // $.Msg("key = ", key)
    // $.Msg("data = ", data)
}


CustomNetTables.SubscribeNetTableListener( "heroes", heroFrameUpdate );


/* END Player UI Frames */
