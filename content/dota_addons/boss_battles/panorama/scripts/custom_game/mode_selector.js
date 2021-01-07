"use strict";

GameEvents.Subscribe( "picking_done", OnPickingDone );

function OnPickingDone( ) {
    $('#HeroModeSelectorContainer').DeleteAsync( 0.0 );
    $('#ToolTip').DeleteAsync( 0.0 );
}

(function () {

    /* MODE SELECTOR CODE EVENTUALLY MOVE TO ANOTHER FILE */
	let modeSelectorContainer = $("#HeroModeSelectorContainer"); // mode selector handler
	let normalModeButton = modeSelectorContainer.FindChildInLayoutFile("NormalModeButton") // nomral mode button
    let storyModeButton = modeSelectorContainer.FindChildInLayoutFile("StoryModeButton") // story mode button
    let hardmodeModeButton = modeSelectorContainer.FindChildInLayoutFile("HardModeButton") // hard mode button
    let modeLabel = modeSelectorContainer.FindChildInLayoutFile("SelectorLabelContainer") // mode label / container
	
	// find the tooltip panel and hide it
	let toolTipContainer = $("#ToolTip");
	toolTipContainer.style.visibility = 'collapse';

	//$.Msg("Players.GetLocalPlayer() ",Players.GetLocalPlayer())
	if ( Players.GetLocalPlayer() == 0 ){

		// mode label / container
		modeLabel.SetPanelEvent( 'onmouseover', function () {
			$.Msg("modeLabel-hover-on")
            toolTipContainer.style.visibility = 'visible';
            var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "Please select a mode, if you do not select a mode it will default to Story mode."
		});

		modeLabel.SetPanelEvent( 'onmouseout', function () {
			$.Msg("modeLabel-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		 
		// story mode button
		storyModeButton.SetPanelEvent( 'onmouseover', function () {
			$.Msg("storyModeButton-hover-on")
			toolTipContainer.style.visibility = 'visible';
			var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "In Story mode lives reset to 3 after every boss. If you wipe on a boss you stay on the same boss."
		});

		storyModeButton.SetPanelEvent( 'onmouseout', function () {
			$.Msg("storyModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		
		storyModeButton.SetPanelEvent( 'onactivate', function () {
			$.Msg("storyModeButton")
            GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "storyMode" } );
			storyModeButton.AddClass( "disabled" );
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			storyModeButton.ClearPanelEvent( 'onactivate' )
		});

		// nomral mode button
		normalModeButton.SetPanelEvent( 'onmouseover', function () {
			$.Msg("normalModeButton-hover-on")
            toolTipContainer.style.visibility = 'visible';
            var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "In Normal mode every boss kill grants all players 1 life. If you wipe on a boss you reset back to the first boss."
		});

		normalModeButton.SetPanelEvent( 'onmouseout', function () {
			$.Msg("normalModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});

		normalModeButton.SetPanelEvent( 'onactivate', function () {
			$.Msg("normalModeButton")
			GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "normalMode" } );
			storyModeButton.AddClass( "disabled" );
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			storyModeButton.ClearPanelEvent( 'onactivate' )
        });
        
        // hard mode button
		hardmodeModeButton.SetPanelEvent( 'onmouseover', function () {
			$.Msg("hardModeButton-hover-on")
            toolTipContainer.style.visibility = 'visible';
            var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "Hard mode is the same as Normal mode, except all bosses have at least 1 additional ability."
		});

		hardModeButton.SetPanelEvent( 'onmouseout', function () {
			$.Msg("hardModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});

		hardModeButton.SetPanelEvent( 'onactivate', function () {
			$.Msg("hardModeButton")
			GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "hardMode" } );
			hardModeButton.AddClass( "disabled" );
			hardModeButton.AddClass( "disabled" );
			hardModeButton.ClearPanelEvent( 'onactivate' )
			hardModeButton.ClearPanelEvent( 'onactivate' )
		});

	}else{

	}

})();