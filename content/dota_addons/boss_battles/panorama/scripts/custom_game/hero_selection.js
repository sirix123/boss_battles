"use strict";
var playerPanels = {};
var canEnter = false;

//Subscribe to events
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "picking_time_update", OnTimeUpdate );
GameEvents.Subscribe( "picking_player_pick", OnPlayerPicked );

/* Event Handlers
=========================================================================*/

/* Picking phase is done, allow the player to enter the game */
function OnPickingDone( data ) {
    $("#EnterGameBtn").RemoveClass( "disabled" );
	$("#EnterGameBtnTxt").text = "Enter Game";
	canEnter = true;
}

/* Visual timer update */
function OnTimeUpdate( data ) {
	$("#TimerTxt").text = data.time;
}

/* A player has picked a hero */
function OnPlayerPicked( data ) {
	PlayerPicked( data.PlayerID, data.HeroName );
}

/* Functionality
=========================================================================*/

/* A player has picked a hero, tell the player's panel a hero was picked,
 * show the hero was taken and if the player that picked is the local player
 * swap to the hero preview screen. */
function PlayerPicked( player, hero ) {
	// player panel / hero select
	//var playerPanel = Modular.Spawn( "picking_player", $("#LeftPlayers") );
	
	//Update the player panel
	//playerPanels[player].SetHero( hero );

	//Disable the hero button
	//$('#'+hero).AddClass( "HeroOption.taken" );

}

/* Select a hero, called when a player clicks a hero panel in the layout */
function SelectHero( heroName ) {
	//Send the pick to the server
	GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName } );
}

/* Enter the game by removing the picking screen, called when the player
 * clicks a button in the layout. */
function EnterGame() {
	if ( canEnter ) {
		$('#PickingScreen').DeleteAsync( 0.0 );
	}
}

/* Initialisation - runs when the element is created
=========================================================================*/
(function () {
	//Set panel visibility
	$('#PickListRowOne').style.visibility = 'visible';
})();