"use strict";

//Subscribe to events
GameEvents.Subscribe( "player_name", GrabPlayerName );

function GrabPlayerName( data ) {
	$.Msg("got start event from server to grab player name");

    var playerId =  Players.GetLocalPlayer();
    var playerName = Players.GetPlayerName( playerId );

	SendPlayerNameToServer( playerName )
}

function SendPlayerNameToServer( playerName ){
    $.Msg("SendPlayerNameToServer playerbname  " + playerName);
    GameEvents.SendCustomGameEventToServer( "player_name_listener", { PlayerName: playerName } );	
}