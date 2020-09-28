/* Boss Frame UI */

function bossFrameUpdate( table_name, key, data )
{
    //$.Msg("bossFrameUpdate( table_name, key, data )")
    // $.Msg("table_name = ", table_name)
    //$.Msg("key = ", key)
    // $.Msg("data = ", data)
    
    var bossFrameContainer = $("#BossFrameContainer")
    if (key === "hide")
    {
        bossFrameContainer.style.visibility = "collapse";
        var hpRightPanel = $("#BossFrameHpPanelRight")

        if (hpRightPanel)
        hpRightPanel.style.visibility = "collapse";

        for (i = 0; i < bossFrameContainer.GetChildCount(); i++  )
        {
            var child = bossFrameContainer.GetChild(i)
            child.DeleteAsync(0);
        }
        return;
    }
    else if (bossFrameContainer.style.visibility === "collapse")
        bossFrameContainer.style.visibility = "visible";

    if (bossFrameContainer)
    {
        for (i = 0; i < bossFrameContainer.GetChildCount(); i++  )
        {
            var child = bossFrameContainer.GetChild(i)
            child.DeleteAsync(0);
        }

        var containerPanel = $.CreatePanel("Panel", bossFrameContainer, data);
        containerPanel.BLoadLayoutSnippet("BossFrame");

        var hpPanelLeft = containerPanel.FindChildInLayoutFile("BossFrameHpPanelLeft")
        var hpPanelRight = containerPanel.FindChildInLayoutFile("BossFrameHpPanelRight")
        hpPanelLeft.style.width = data["hpPercent"]+"%"
        var hpGone = 100 - data["hpPercent"]
        hpPanelRight.style.width = hpGone+"%"

        //TODO: the same thing as above for mp 
        //Need to create the panels in xml and css first        
        var mpPanelLeft = containerPanel.FindChildInLayoutFile("BossFrameMpPanelLeft")
        var mpPanelRight = containerPanel.FindChildInLayoutFile("BossFrameMpPanelRight")
        mpPanelLeft.style.width = data["mpPercent"]+"%"
        var mpGone = 100 - data["mpPercent"]
        mpPanelRight.style.width = mpGone+"%"


        var hpLabel = containerPanel.FindChildInLayoutFile("BossFrameHpLabel")
        var mpLabel = containerPanel.FindChildInLayoutFile("BossFrameMpLabel")
        var castbarLabel = containerPanel.FindChildInLayoutFile("BossFrameCastbarLabel")

        hpLabel.text = data["hpPercent"] + "%"
        mpLabel.text = data["mpPercent"]+"%"

        // playerName.text = data[row].hero
        // dps.text = data[row].dps
        // for (var row in data)
        // {
        // }
    }
}

CustomNetTables.SubscribeNetTableListener( "boss_frame", bossFrameUpdate );

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
