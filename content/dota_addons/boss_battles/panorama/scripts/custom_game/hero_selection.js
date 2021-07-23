"use strict";

//Subscribe to events
GameEvents.Subscribe( "begin_hero_select", StartHeroSelect );
GameEvents.Subscribe( "picking_done", OnPickingDone );
GameEvents.Subscribe( "picking_time_update", OnTimeUpdate );
GameEvents.Subscribe( "picking_player_pick", OnPlayerPicked );
GameEvents.Subscribe( "picking_player_selected", OnPlayerSelected );
GameEvents.Subscribe( "player_reconnect", OnPickingDone );
GameEvents.Subscribe( "reset_picks_for_players", OnResetPicksForPlayers );


/* Event Handlers
=========================================================================*/

/* reset player picks */
function OnResetPicksForPlayers( data ) {
	//$.Msg("OnResetPicksForPlayers")

	// players that had duplicated heroes picked run this function
	// so only these players will see the pick reset the other players will see the new picks etc as that is server based
	// so. we need to clear the ped, re-enable the buttons, 
		// BUT we can't... re-enable the buttons etc for picked heroes...
		// how? add the duplicate hero back to the hero... then loop through that list and reenable the heroes in that list

	// lua table massage
	let heroes_duplicates = []
	for (let i = 1; data.hero_duplicates[i] !== undefined; i++) {
		heroes_duplicates.push(data.hero_duplicates[i]);
	}

	// remove duplicates from that table and push them to the existing hero list
	let uniqueSet = new Set(heroes_duplicates);
	let backToArray = [...uniqueSet];
	for (let i = 0; backToArray[i] !== undefined; i++) {
		heroes.push(backToArray[i]);
	}

	// reset the hero selection ( all portraits and reset buttons back to hero select state )
	for (let i=0; i < heroes.length; i++){
		for (let [key, value] of Object.entries(heroFramePanels)) {
			if (heroes[i] == value.id){
				var heroFrame = value;
				let heroPickButton = heroFrame.FindChildInLayoutFile("HeroPickHeroBtn");
				let heroPickButtonText = heroFrame.FindChildInLayoutFile("HeroPickHeroBtnTxt");
				var heroPortait = heroFrame.FindChildInLayoutFile("HeroPortrait");
				var heroImage = heroFrame.FindChildInLayoutFile("HeroImage")
				heroPortait.RemoveClass( "taken" );
				heroPickButtonText.text = "";
				heroPickButton.AddClass( "PickHeroBtn" );
				heroPickButton.AddClass( "disabled" );

				//let PickListRowOneContainer = $("#HeroOptions");

				// enable the hero portriats button again
				heroImage.SetPanelEvent( 'onactivate', function () {
					SelectHero( heroes[i], heroPickButton )
				});
				
			}
		}
	}


}

/* Wait for the server to tell us when to start hero select */
function StartHeroSelect( data ) {
	$.Msg("got start event from server to open the hero select screen")
	DisplayHeroSelect( data )
	DisplayWASDToolTip()
}

/* Picking phase is done, allow the player to enter the game */
function OnPickingDone( data ) {

	$.Msg("hero select ending / reconnected deleting panels")

	$('#wasdcontainer').DeleteAsync( 0.0 );
	$('#herocompContainer').DeleteAsync( 0.0 );
    $('#ToolTip').DeleteAsync( 0.0 );
	EnterGame()
}

/* Visual timer update */
function OnTimeUpdate( data ) {
	$("#TimerTxt").text = data.time;
}

/* A player has picked a hero */
function OnPlayerPicked( data ) {
	$.Msg("OnPlayerPicked ",data)
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
		$.Msg("containerPanel ",containerPanel)
		//var heroPickButtonSelected = containerPanel.FindChildInLayoutFile("HeroPickHeroBtn");
		var heroPickButtonTextSelected = containerPanel.FindChildInLayoutFile("HeroPickHeroBtnTxt");
		containerPanel.RemoveClass( "disabled" );
		heroPickButtonTextSelected.text = "Pick Hero";
		containerPanel.SetPanelEvent( 'onactivate', function () {
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

	//$.Msg("player ",player)
	//$.Msg("hero ",hero)

	// when a player selects the portait, create a greyscale ped at the bottom for all clients (called from lua)
	var pedHeroImage = heroPedPanels[player].FindChildInLayoutFile("HeroPed");
	pedHeroImage.BLoadLayoutFromString('<root><Panel><DOTAScenePanel style="width: 100%; height: 100%; " unit="'+hero+'" particleonly="false" /></Panel></root>', true, false );
	pedHeroImage.AddClass("PedSceneHeroSelected")

	// add the players name to the bottom of the pedestal
	var pedHeroPlayerText = heroPedPanels[player].FindChildInLayoutFile("PlayerNamePedTxt");
	pedHeroPlayerText.text = Players.GetPlayerName( player );
	pedHeroPlayerText.AddClass( "PlayerNamePedTxt" );

	// match dota hero name to boss battles hero name
	if ( hero == "npc_dota_hero_crystal_maiden" 	) 	{ hero = "Rylai"; }
	if ( hero == "npc_dota_hero_phantom_assassin" 	) 	{ hero = "Nightblade"; }
	if ( hero == "npc_dota_hero_juggernaut" 		) 	{ hero = "Blademaster"; }
	if ( hero == "npc_dota_hero_windrunner" 		) 	{ hero = "Windrunner"; }
	if ( hero == "npc_dota_hero_lina" 				) 	{ hero = "Lina"; }
	if ( hero == "npc_dota_hero_omniknight" 		) 	{ hero = "Nocens"; }
	if ( hero == "npc_dota_hero_grimstroke" 		) 	{ hero = "Zeeke"; }
	if ( hero == "npc_dota_hero_queenofpain" 		) 	{ hero = "Akasha"; }
	if ( hero == "npc_dota_hero_hoodwink" 			) 	{ hero = "Rat"; }
	if ( hero == "npc_dota_hero_huskar" 			) 	{ hero = "Templar"; }
	if ( hero == "npc_dota_hero_pugna" 				) 	{ hero = "Pugna"; }
	

	// add the players name to the bottom of the pedestal
	var pedHeroHeroText = heroPedPanels[player].FindChildInLayoutFile("HeroNamePedTxt");
	pedHeroHeroText.text = hero;
	pedHeroHeroText.AddClass( "HeroNamePedTxt" );
	
}

/* Clicks the bbutton picks the hero the player as selected */
function PickHero( heroName ) {
	//Send the pick to the server
	$.Msg("PickHero heroName ",heroName);
	GameEvents.SendCustomGameEventToServer( "hero_picked", { HeroName: heroName } );	
}

/* A player has picked a hero, tell the player's panel a hero was picked, */
function PlayerPicked( player, hero ) {

	// loop ovr all the hero frame panels and check it against the hero name from lua
	for (let i=0; i < heroes.length; i++){
		let heroFrame = heroFramePanels[i];

		// if the names match disable that portrait
		//$.Msg("heroFrame.id, ",heroFrame.id)
		if (heroFrame !== undefined ){
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
				//$.Msg("heroes ",heroes)
				
			}
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
let heroes = [];

// container for the ped on the scene
let PedRowContainer = $("#PedList");

//(function () {
function DisplayHeroSelect( data ){

	//let heroes = [];
	for (let i = 1; data.hero_list[i] !== undefined; i++) {
		heroes.push(data.hero_list[i]);
    }

	//Set panel visibility
	var rootPanel = $("#PickingScreen");
	rootPanel.RemoveClass("hidden");
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
		//heroImage.SetImage('file://{images}/heroes/selection/' + heroes[i] + '.png');
		//heroImage.style.backgroundImage = 'url("file://{images}/heroes/' + heroes[i]  + '.png")';

		// add an on activate (click) for the hero portrait
		// need to store this as a variable using let for some js reason 
		let hero = heroes[i]
		heroImage.SetPanelEvent( 'onactivate', function () {
			//$.Msg("heroImage.SetPanelEvent ",hero)
			SelectHero( hero, heroPickButton )
		});

		//store this panel to update it later.
		heroFramePanels[i] = containerPanel
	}
}
//})();

function DisplayWASDToolTip(){
	let wasdContainer = $("#wasdcontainer");
	let wasdLabel = wasdContainer.FindChildInLayoutFile("wasdcontainerLabelContainer");

	let toolTipContainer = $("#ToolTip");
	toolTipContainer.style.visibility = 'collapse';

	wasdLabel.SetPanelEvent( 'onmouseover', function () {
		toolTipContainer.style.visibility = 'visible';
		var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
		tooltipText.text = "Very rarely when you intially spawn or if you lag a movement key might get 'stuck' down. To fix this type !reset in chat."
	});

	wasdLabel.SetPanelEvent( 'onmouseout', function () {
		toolTipContainer.style.visibility = 'collapse';
	});

	let herocompContainer = $("#herocompContainer");
	let herocompLabel = herocompContainer.FindChildInLayoutFile("herocompContainerLabelContainer");

	herocompLabel.SetPanelEvent( 'onmouseover', function () {
		toolTipContainer.style.visibility = 'visible';
		var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt")
		tooltipText.text = 
		"If this is your first time playing Boss Battles.\n\n\
It is recommended that your team comprises of one damage dealer, two hybrids and one support.\n\n\
Rylai, Blademaster, Windrunner are hybrids.\n\n\
Lina, Nightblade and Templar are damage dealers.\n\n\
Nocens and Akasha are supports.\n\n\
The info panel on the left handside of the screen (shown once hero selection is finished) has some helpful gameplay tips.";
	});

	herocompLabel.SetPanelEvent( 'onmouseout', function () {
		toolTipContainer.style.visibility = 'collapse';
	});

}

// by default set the root panel as hidden
(function () {
	var rootPanel = $("#PickingScreen");
	rootPanel.SetHasClass("hidden", true);
})();