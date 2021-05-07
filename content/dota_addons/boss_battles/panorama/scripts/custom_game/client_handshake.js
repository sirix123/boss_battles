"use strict";

GameEvents.Subscribe( "player_reconnect", OnReconnect );

function OnReconnect( data ) {
	$.Msg("client handshake reconnect")
    GameEvents.SendCustomGameEventToServer( "client_handshake_reconnect", { PlayerID: Players.GetLocalPlayer() } );
}

(function () {

    $.Msg("client handshake started")

    GameEvents.SendCustomGameEventToServer( "client_handshake", { PlayerID: Players.GetLocalPlayer() } );	

})();