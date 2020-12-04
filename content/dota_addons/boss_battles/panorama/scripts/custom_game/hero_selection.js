"use strict";

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
function SelectHero( heroName, containerPanel ) {

	// only do this for heroes that haven't been picked...
	if ( heroes.includes(heroName) == true ) {
		
		//$.Msg("hero is in the list ",heroName)

		// loop over the stored hero panels and disable all the buttons
		let PickListRowOneContainer = $("#PickListRowOne");
		for (let i=0; i < PickListRowOneContainer.GetChildCount(); i++){
			var heroFrame = heroFramePanels[i];
			let heroPickButton = heroFrame.FindChildInLayoutFile("HeroPickHeroBtn");
			let heroPickButtonText = heroFrame.FindChildInLayoutFile("HeroPickHeroBtnTxt");
			heroPickButton.AddClass( "disabled" );
			heroPickButtonText.text = "";
			heroPickButton.ClearPanelEvent( 'onactivate' )
		}

		// enable and show the pick hero button.. beneath the right hero...
		var heroPickButtonSelected = containerPanel.FindChildInLayoutFile("HeroPickHeroBtn");
		var heroPickButtonTextSelected = containerPanel.FindChildInLayoutFile("HeroPickHeroBtnTxt");
		heroPickButtonSelected.RemoveClass( "disabled" );
		heroPickButtonTextSelected.text = "Pick Hero";
		heroPickButtonSelected.SetPanelEvent( 'onactivate', function () {
			PickHero( heroName );
				});

		// replace greyed out ped in the scene of hero selected
		// each player has a slot?
		// on button push create a scenee in a slot that doesn't have a slot
		// create entitiys info player starts on the map/scene and load the hero model? play spawn animation then idle?
		//opacity-mask: url(\'s2r://panorama/images/masks/softedge_box_png.vtex\');
				
	}
}

/* Clicks the bbutton picks the hero the player as selected */
function PickHero( heroName ) {
	//Send the pick to the server
	GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName } );

	// create scenee snippet in the ped container, show in full colour (remove background image??/)
	// leave the ped snippet there but remove the backaround overlay
	
}

/* A player has picked a hero, tell the player's panel a hero was picked, */
function PlayerPicked( player, hero ) {

	// loop ovr all the hero frame panels and check it against the hero name from lua
	for (let i=0; i < heroes.length; i++){
		var heroFrame = heroFramePanels[i];

		// if the names match disable that portrait
		if ( heroFrame.id == hero ) {
			
			// find the portait image and grey out
			var heroPortait = heroFrame.FindChildInLayoutFile("HeroPortrait");
			heroPortait.AddClass( "taken" );

			// find the button and disable, remove event and remove text
			let heroPickButton = heroFrame.FindChildInLayoutFile("HeroPickHeroBtn");
			let heroPickButtonText = heroFrame.FindChildInLayoutFile("HeroPickHeroBtnTxt");
			heroPickButton.AddClass( "disabled" );
			heroPickButtonText.text = "Hero Picked";
			heroPickButton.ClearPanelEvent( 'onactivate' )

			// remove hero from the heroes array
			heroes.splice(i, 1);
			
		}
	}

	if ( player == Players.GetLocalPlayer() ) {
	
		// disable all buttons and hero selects 
		let PickListRowOneContainer = $("#PickListRowOne");
		for (let i=0; i < PickListRowOneContainer.GetChildCount(); i++){
			var heroFrame = heroFramePanels[i];

			let heroPickButton = heroFrame.FindChildInLayoutFile("HeroPickHeroBtn");
			let heroPickButtonText = heroFrame.FindChildInLayoutFile("HeroPickHeroBtnTxt");
			heroPickButton.AddClass( "disabled" );
			heroPickButtonText.text = "";
			heroPickButton.ClearPanelEvent( 'onactivate' )

			var heroPortait = heroFrame.FindChildInLayoutFile("HeroPortrait");
			heroPortait.AddClass( "taken" );

			var heroImage = heroFrame.FindChildInLayoutFile("HeroImage")
			heroImage.ClearPanelEvent( 'onactivate' )
		}
	}

	// create ped of hero in the scene
	var pedHeroImage = heroPedPanels[0].FindChildInLayoutFile("HeroPed");
	pedHeroImage.BLoadLayoutFromString('<root><Panel><DOTAScenePanel style="width: 100%; height: 100%; " unit="'+hero+'"/></Panel></root>', false, false );
	pedHeroImage.AddClass( "PedSceneHero" );
}

/* Enter the game by removing the picking screen, called when the player */
function EnterGame() {
	$('#PickingScreen').DeleteAsync( 0.0 );
}

/* Initialisation - runs when the element is created
=========================================================================*/
// used later to store the hero panels created
let heroFramePanels = {};

// used later to display the peds in the map
let heroPedPanels = {};

// hero list
let heroes = 
[
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_medusa",
];

(function () {

	//Set panel visibility
	$('#PickListRowOne').style.visibility = 'visible';

	// IF DEBUG MODE show TA KUNKA and WIP heroes, if not don't show those heroes TBD

	// container for the ped on the scene
	let PedRowContainer = $("#PedList");

	// 4 = total number of players, create a ped for each one
	for (let i=0; i < 4; i++){
		let pedContainerPanel = $.CreatePanel("Panel", PedRowContainer, 0);
		pedContainerPanel.BLoadLayoutSnippet("PedFrames");

		heroPedPanels[i] = pedContainerPanel
	}

	// container for hero portraits
	let PickListRowOneContainer = $("#PickListRowOne");

	// for each hero in the list draw a portrait and a grey button
	for (let i=0; i < heroes.length; i++){

		// craete container
		let containerPanel = $.CreatePanel("Panel", PickListRowOneContainer, heroes[i]);
		containerPanel.BLoadLayoutSnippet("HeroOptions");

		// show the button but grey it out
		let heroPickButton = containerPanel.FindChildInLayoutFile("HeroPickHeroBtn");
		heroPickButton.AddClass( "PickHeroBtn" );
		heroPickButton.AddClass( "disabled" );

		// create hero portrait
		var heroImage = containerPanel.FindChildInLayoutFile("HeroImage")
		heroImage.heroname = heroes[i];

		// add an on activate (click) for the hero portrait
		// need to store this as a variable using let for some js reason 
		let hero = heroes[i]
		heroImage.SetPanelEvent( 'onactivate', function () {
			SelectHero( hero, containerPanel )
		});

		//store this panel to update it later.
		heroFramePanels[i] = containerPanel
	}

})();