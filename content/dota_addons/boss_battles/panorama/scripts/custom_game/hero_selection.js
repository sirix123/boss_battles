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
	EnterGame()
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

/* Select a hero, called when a player clicks a hero panel in the layout */
function SelectHero( heroName ) {
	$.Msg("hello i have selected ",heroName)

	// i think we need to keep track of the player that has hovered a hero, allocate them a pos for the ped, and replace that ped if they hover another hero.
	// what about order, I think that would make sense? maybe not? we will show the name regardles

	// something something if player selection replace ped with new select

	
	// show ped of hero
	// how do i apply styles to that panel below? (label) etc)
	var PedList = $("#PedList")
	var containerPanel = $.CreatePanel("Panel", PedList, 0);
	var ped_panel = containerPanel.BLoadLayoutFromString
		(
			'<root><Panel><DOTAScenePanel class="Ped" style="width:200px;height:200px;" light="light" unit="'+heroName+'" particleonly="false"/> <Label id="PedText" text="'+heroName+'" /></Panel></root>'
			, false, false 
		); 

	//ped_panel.AddClass("PedText")

	// apply background image to make the ped grey

	// show the pick hero button.. beneath the right hero...
	$("#PickHeroBtn").RemoveClass( "disabled" );
	$("#PickHeroBtnTxt").text = "Pick Hero";
	
}

/* Clicks the bbutton picks the hero the player as selected */
function PickHero( heroName ) {
	//Send the pick to the server
	GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName } );

	// create scenee snippet in the ped container, show in full colour (remove background image??/)
	
}

/* A player has picked a hero, tell the player's panel a hero was picked, */
function PlayerPicked( player, hero ) {

	//Disable the hero button
	$('#'+hero).AddClass( "taken" );
}

/* Enter the game by removing the picking screen, called when the player */
function EnterGame() {
	$('#PickingScreen').DeleteAsync( 0.0 );
}

/* Initialisation - runs when the element is created
=========================================================================*/
(function () {
	//Set panel visibility
	$('#PickListRowOne').style.visibility = 'visible';
})();