"use strict";

GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "begin_hero_select", StartModeSelect );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );

function OnPickingDone( ) {
    //$('#HeroModeSelectorContainer').DeleteAsync( 0.0 );
    //$('#ToolTip').DeleteAsync( 0.0 );
}

//(function () {
function StartModeSelect(){

	var rootPanel = $("#HeroModeSelectorContainer");
	rootPanel.RemoveClass("hidden");

	let modeSelectorContainer = $("#HeroModeSelectorContainer"); // mode selector handler
	let normalModeButton = modeSelectorContainer.FindChildInLayoutFile("NormalModeButton") 
	let soloModeButton = modeSelectorContainer.FindChildInLayoutFile("SoloModeButton")
	let hardModeButton = modeSelectorContainer.FindChildInLayoutFile("HardModeButton") 
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
			tooltipText.text = "Please select a mode.\n\n\
If you do not select a mode it will default to Solo mode.\n\n\
Only the lobby host sees this selection."
		});

		modeLabel.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("modeLabel-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		 
		soloModeButton.SetPanelEvent( 'onmouseover', function () {
			//$.Msg("soloModeButton-hover-on")
			toolTipContainer.style.visibility = 'visible';
			var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = 
			"In Solo mode lives reset to 3 after every boss.\n\n\
If you wipe on a boss you stay on the same boss.\n\n\
The damage from all boss abilities and attacks are reduced by 75% (most minions as well). Also, some bosses have 1 or more mechanics removed.\n\n\
Boss HP is also reduced by 75% (most minions as well).\n\n\
If you complete the game (kill all bosses) your game session will be posted on the Leaderboard."
		});

		soloModeButton.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("soloModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		
		soloModeButton.SetPanelEvent( 'onactivate', function () {
			//$.Msg("soloModeButton")
            GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "soloMode" } );
			soloModeButton.AddClass( "disabled" );
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			soloModeButton.ClearPanelEvent( 'onactivate' )
			hardModeButton.AddClass( "disabled" );
			hardModeButton.ClearPanelEvent( 'onactivate' )
			EnterGame()
		});

		// nomral mode button
		normalModeButton.SetPanelEvent( 'onmouseover', function () {
			//$.Msg("normalModeButton-hover-on")
            toolTipContainer.style.visibility = 'visible';
            var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "In Normal Mode lives reset to 3 after every boss.\n\n\
If you wipe on a boss you stay on the same boss.\n\n\
If you complete the game (kill all bosses) your game session will be posted on the Leaderboard."
		});

		normalModeButton.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("normalModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});

		normalModeButton.SetPanelEvent( 'onactivate', function () {
			//$.Msg("normalModeButton")
			GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "normalMode" } );
			soloModeButton.AddClass( "disabled" );
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			soloModeButton.ClearPanelEvent( 'onactivate' )
			hardModeButton.AddClass( "disabled" );
			hardModeButton.ClearPanelEvent( 'onactivate' )
			EnterGame()
        });

		// easy mode button
		hardModeButton.SetPanelEvent( 'onmouseover', function () {
			//$.Msg("hardModeButton-hover-on")
			toolTipContainer.style.visibility = 'visible';
			var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
			tooltipText.text = "In Hard mode lives don't reset, you have 3 lives.\n\n\
If you wipe on a boss you reset back to the first boss.\n\n\
If you complete the game (kill all bosses) your game session will be posted on the Leaderboard."
		});

		hardModeButton.SetPanelEvent( 'onmouseout', function () {
			//$.Msg("hardModeButton-hover-off")
			toolTipContainer.style.visibility = 'collapse';
		});
		
		hardModeButton.SetPanelEvent( 'onactivate', function () {
			//$.Msg("hardModeButton")
			GameEvents.SendCustomGameEventToServer( "mode_selected", { mode: "hardMode" } );
			soloModeButton.AddClass( "disabled" );
			soloModeButton.ClearPanelEvent( 'onactivate' )
			normalModeButton.AddClass( "disabled" );
			normalModeButton.ClearPanelEvent( 'onactivate' )
			hardModeButton.AddClass( "disabled" );
			hardModeButton.ClearPanelEvent( 'onactivate' )
			EnterGame()
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
		soloModeButton.style.visibility = 'collapse';
		modeLabel.style.visibility = 'collapse';
		toolTipContainer.style.visibility = 'collapse';

	}
}
//})();

function EnterGame() {
	$('#HeroModeSelectorContainer').DeleteAsync( 0.0 );
}

// by default set the root panel as hidden
(function () {
	var rootPanel = $("#HeroModeSelectorContainer");
	rootPanel.SetHasClass("hidden", true);
})();