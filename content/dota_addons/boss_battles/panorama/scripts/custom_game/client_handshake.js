"use strict";

(function () {

    $.Msg("client handshake started")

    GameEvents.SendCustomGameEventToServer( "client_handshake", { } );	

})();