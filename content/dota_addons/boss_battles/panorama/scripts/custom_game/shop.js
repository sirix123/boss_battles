"use strict";

// events
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );

/* Event Handlers
=========================================================================*/
/* After picking is done spawn the shop button */
function OnPickingDone( data ) {

	//$.Msg("create help button")
    var rootPanel = $("#ShopButtonPanel");
	rootPanel.RemoveClass("hidden");

    $('#ShopButtonPanel').style.visibility = 'visible';

}

/* Button Event Handlers
=========================================================================*/
function OnShopButtonPressed(){

    //$('#ShopButton').style.visibility = 'collapse';
    //$('#HelpToolTip').style.visibility = 'visible';

    //let helpButtonRoot = $("#HelpToolTip");
    //let helpTooltip = $.CreatePanel("Panel", helpButtonRoot, 0);
    //helpTooltip.BLoadLayoutSnippet("HelpButtonToolTip");
}


/* runs when client loads files
=========================================================================*/
(function () {
	var rootPanel = $("#ShopButtonPanel");
	rootPanel.SetHasClass("hidden", true);
})();