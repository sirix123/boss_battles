"use strict";

// events
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );

/* Event Handlers
=========================================================================*/
/* After picking is done spawn the help button */
function OnPickingDone( data ) {

	//$.Msg("create help button")
    var rootPanel = $("#HelpPanel");
	rootPanel.RemoveClass("hidden");

    $('#HelpPanel').style.visibility = 'visible';

    let helpButtonRoot = $("#HelpButton");
    let helpButtonPanel = $.CreatePanel("Panel", helpButtonRoot, 0);
    helpButtonPanel.BLoadLayoutSnippet("HelpButtonContainer");

}

/* Button Event Handlers
=========================================================================*/
function OnHelpButtonPressed(){
    //$.Msg("help button pressed")

    $('#HelpButtonBtn').style.visibility = 'collapse';
    $('#HelpToolTip').style.visibility = 'visible';

    let helpButtonRoot = $("#HelpToolTip");
    let helpTooltip = $.CreatePanel("Panel", helpButtonRoot, 0);
    helpTooltip.BLoadLayoutSnippet("HelpButtonToolTip");
}

function OnToolTipCloseButtonPressed(){
    //$.Msg("OnToolTipCloseButtonPressed ")

    $('#HelpToolTip').style.visibility = 'collapse';

    let helpButtonRoot = $("#HelpButton");
    let helpButtonPanel = $.CreatePanel("Panel", helpButtonRoot, 0);
    helpButtonPanel.BLoadLayoutSnippet("HelpButtonContainer");
}

(function () {
	var rootPanel = $("#HelpPanel");
	rootPanel.SetHasClass("hidden", true);
})();