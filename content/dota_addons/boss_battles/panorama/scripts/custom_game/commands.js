"use strict";

GameEvents.Subscribe( "send_game_id", GameIDSent );

function GameIDSent( data ) {
    $.Msg("Game ID: ",data[1]);
}
