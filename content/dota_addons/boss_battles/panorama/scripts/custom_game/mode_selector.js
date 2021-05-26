"use strict";

GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "begin_hero_select", StartModeSelect );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );

function OnPickingDone( ) {
    $('#HeroModeSelectorContainer').DeleteAsync( 0.0 );
    $('#ToolTip').DeleteAsync( 0.0 );
}

//(function () {
function StartModeSelect(){

	var rootPanel = $("#HeroModeSelectorContainer");
	rootPanel.RemoveClass("hidden");

	let modeSelectorContainer = $("#HeroModeSelectorContainer"); // mode selector handler
	let normalModeButton = modeSelectorContainer.FindChildInLayoutFile("NormalModeButton") // nomral mode button
	let storyModeButton = modeSelectorContainer.FindChildInLayoutFile("StoryModeButton") // story mode button
	//let hardmodeModeButton = modeSelectorContainer.FindChildInLayoutFile("HardModeButton") // hard mode button
    let modeLabel = modeSelectorContainer.FindChildInLayoutFile("SelectorLabelContainer") // mode label / container
	
	// find the tooltip panel and hide it
	let toolTipContainer = $("#ToolTip");
	toolTipContainer.style.visibility = 'collapse';

	//$.Msg("Players.GetLocalPlayer() ",Players.GetLocalPlayer())
	if ( Players.GetLocalPlayer() == 0 ){

		// mode label / container
		modeLabel.SetPanelEvent( 'onmouseover', function () {
			//$.Msg("modeLabel-hover-on")
            toolTipContainer.style.visibility = 'visible';
            var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "Please select a mode, if you do not select a mode it will default to Normal mode."
		});

		modeLabel.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("modeLabel-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		 
		// story mode button
		storyModeButton.SetPanelEvent( 'onmouseover', function () {
			//$.Msg("storyModeButton-hover-on")
			toolTipContainer.style.visibility = 'visible';
			var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "In Normal mode lives reset to 3 after every boss. If you wipe on a boss you stay on the same boss. In Story mode the chat command !start boss *boss name* will change the next boss to whatever boss you type. If you complete the game (kill Tinker) your game session will be posted on the Leaderboard."
		});

		storyModeButton.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("storyModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		
		storyModeButton.SetPanelEvent( 'onactivate', function () {
			//$.Msg("storyModeButton")
            GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "storyMode" } );
			storyModeButton.AddClass( "disabled" );
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			storyModeButton.ClearPanelEvent( 'onactivate' )
		});

		// nomral mode button
		normalModeButton.SetPanelEvent( 'onmouseover', function () {
			//$.Msg("normalModeButton-hover-on")
            toolTipContainer.style.visibility = 'visible';
            var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "In Hard mode every boss kill grants all players 1 life. If you wipe on a boss you reset back to the first boss. If you complete the game (kill Tinker) your game session will be posted on the Leaderboard. Note the !start boss command does not work in Hard mode."
		});

		normalModeButton.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("normalModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});

		normalModeButton.SetPanelEvent( 'onactivate', function () {
			//$.Msg("normalModeButton")
			GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "normalMode" } );
			storyModeButton.AddClass( "disabled" );
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			storyModeButton.ClearPanelEvent( 'onactivate' )
        });
        
		// hard mode button
		/*
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
		*/

	}else{

		modeSelectorContainer.style.visibility = 'collapse';
		normalModeButton.style.visibility = 'collapse';
		storyModeButton.style.visibility = 'collapse';
		modeLabel.style.visibility = 'collapse';
		toolTipContainer.style.visibility = 'collapse';

	}
}
//})();

// by default set the root panel as hidden
(function () {
	var rootPanel = $("#HeroModeSelectorContainer");
	rootPanel.SetHasClass("hidden", true);
})();