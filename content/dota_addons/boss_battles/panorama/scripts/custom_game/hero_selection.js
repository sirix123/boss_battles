"use strict";

//Subscribe to events
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "picking_time_update", OnTimeUpdate );
GameEvents.Subscribe( "picking_player_pick", OnPlayerPicked );
GameEvents.Subscribe( "picking_player_selected", OnPlayerSelected );

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

/* A player has selected a hero */
function OnPlayerSelected( data ) {
	PlayerSelected( data.PlayerID, data.HeroName );
}

/* Functionality
=========================================================================*/

/* Select a hero, called when a player clicks a hero panel in the layout */
function SelectHero( heroName, containerPanel ) {

	// only do this for heroes that haven't been picked...
	if ( heroes.includes(heroName) == true ) {
		
		$.Msg("hero is in the list ",heroName)

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

		// tells lua the local player has selected a hero
		GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName } );
	}else{
		$.Msg("[SelectHero - Error] hero is not in the list ",heroName)
	}
}

/* Clicks the hero portrait */
function PlayerSelected( player, hero ) {

	$.Msg("player ",player)
	$.Msg("hero ",hero)

	// when a player selects the portait, create a greyscale ped at the bottom for all clients (called from lua)
	var pedHeroImage = heroPedPanels[player].FindChildInLayoutFile("HeroPed");
	pedHeroImage.BLoadLayoutFromString('<root><Panel><DOTAScenePanel style="width: 100%; height: 100%; " unit="'+hero+'" particleonly="false" /></Panel></root>', true, false );
	pedHeroImage.AddClass("PedSceneHeroSelected")

	// add the players name to the bottom of the pedestal
	var pedHeroPlayerText = heroPedPanels[player].FindChildInLayoutFile("PlayerNamePedTxt");
	pedHeroPlayerText.text = Players.GetPlayerName( player );
	pedHeroPlayerText.AddClass( "PlayerNamePedTxt" );

	// match dota hero name to boss battles hero name
	if ( hero == "npc_dota_hero_crystal_maiden" 	) 	{ hero = "Ice Mage"; }
	if ( hero == "npc_dota_hero_phantom_assassin" 	) 	{ hero = "Cenzuo, the Nightblade"; }
	if ( hero == "npc_dota_hero_juggernaut" 		) 	{ hero = "Warlord"; }
	if ( hero == "npc_dota_hero_medusa" 			) 	{ hero = "Medusa"; }

	// add the players name to the bottom of the pedestal
	var pedHeroHeroText = heroPedPanels[player].FindChildInLayoutFile("HeroNamePedTxt");
	pedHeroHeroText.text = hero;
	pedHeroHeroText.AddClass( "HeroNamePedTxt" );
	
}

/* Clicks the bbutton picks the hero the player as selected */
function PickHero( heroName ) {
	//Send the pick to the server
	GameEvents.SendCustomGameEventToServer( "hero_picked", { HeroName: heroName } );	
}

/* A player has picked a hero, tell the player's panel a hero was picked, */
function PlayerPicked( player, hero ) {

	// loop ovr all the hero frame panels and check it against the hero name from lua
	for (let i=0; i < heroes.length; i++){
		let heroFrame = heroFramePanels[i];

		// if the names match disable that portrait
		$.Msg("heroFrame.id, ",heroFrame.id)
		if ( heroFrame.id == hero ) {
			
			// find the portait image and grey out
			var heroPortait = heroFrame.FindChildInLayoutFile("HeroPortrait");
			heroPortait.AddClass( "taken" );

			// find the portatit onactivate and disable it
			var heroImage = heroFrame.FindChildInLayoutFile("HeroImage")
			heroImage.ClearPanelEvent( 'onactivate' )

			// find the button and disable, remove event and remove text
			let heroPickButton = heroFrame.FindChildInLayoutFile("HeroPickHeroBtn");
			let heroPickButtonText = heroFrame.FindChildInLayoutFile("HeroPickHeroBtnTxt");
			heroPickButton.AddClass( "disabled" );
			heroPickButtonText.text = "";
			heroPickButton.ClearPanelEvent( 'onactivate' )

			// remove hero from the heroes array
			//heroes.splice(i, 1);
			delete heroes[i]
			$.Msg("heroes ",heroes)
			
		}
	}

	if ( player == Players.GetLocalPlayer() ) {
	
		// disable all buttons and hero selects 
		let PickListRowOneContainer = $("#PickListRowOne");
		for (let i=0; i < PickListRowOneContainer.GetChildCount(); i++){
			var heroFrame = heroFramePanels[i];

			// find the portatits onactivate and disable it
			var heroImage = heroFrame.FindChildInLayoutFile("HeroImage")
			heroImage.ClearPanelEvent( 'onactivate' )

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

	// fidn the ped scene and remove the selected class and apply the taken class
	var pedHeroImage = heroPedPanels[player].FindChildInLayoutFile("HeroPed");
	pedHeroImage.RemoveClass("PedSceneHeroSelected");
	pedHeroImage.AddClass("PedSceneHeroTaken");
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

// container for the ped on the scene
let PedRowContainer = $("#PedList");

(function () {

	// if tools mode.. load Ta and kunka
	if ( Game.IsInToolsMode() == false ) {
		$.Msg("tools ",Game.IsInToolsMode())

		for (let i=0; i < heroes.length; i++){
			$.Msg("i ",heroes[i])
			if ( heroes[i] == "npc_dota_hero_templar_assassin" ) {
				heroes.splice(i, 1);
			}

			if ( heroes[i] == "npc_dota_hero_kunkka"  ) {
				heroes.splice(i, 1);
			}
		}
	}

	//Set panel visibility
	$('#PickListRowOne').style.visibility = 'visible';

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
			$.Msg("heroImage.SetPanelEvent ",hero)
			SelectHero( hero, containerPanel )
		});

		//store this panel to update it later.
		heroFramePanels[i] = containerPanel
	}

})();
