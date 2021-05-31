"use strict";

// events
GameEvents.Subscribe( "game_complete", OnGameComplete );

/* Event Handlers
=========================================================================*/
/* OnGameComplete */
function OnGameComplete( data ) {

	$.Msg("create post screen")
    var rootPanel = $("#PostPanelContainer");
	rootPanel.RemoveClass("hidden");

    $('#PostPanelContainer').style.visibility = 'visible';


}

/* Button handler
=========================================================================*/
function PostPanelCloseButtonPressed(){
	var rootPanel = $("#PostPanelContainer");
	rootPanel.SetHasClass("hidden", true);
}

// hidden by default
(function () {
	var rootPanel = $("#PostPanelContainer");
	rootPanel.SetHasClass("hidden", true);
})();