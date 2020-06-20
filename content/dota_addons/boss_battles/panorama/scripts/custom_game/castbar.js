"use strict";

function AbilityCast()
{
	$.Msg("Castbar.js AbilityCast() event caught");

	//TODO: show panel for while the ability is being cast




}


// MAIN: 
(function () {
	//create a listener for some event, after that event create my castbar
	//Couldn't get this one to work:
	//GameEvents.Subscribe("dota_player_used_ability", AbilityCast);	//built-in dota2 event 
	GameEvents.Subscribe("customEvent_abilityCast", AbilityCast); //my custom event, comes from player_manager.lua
})();