"use strict";

GameEvents.Subscribe( "no_target",      OnEventNoTarget );
GameEvents.Subscribe( "out_of_range",   OnEventOutOfRange );

function OnEventNoTarget( data ) {
    GameUI.SendCustomHUDError( "No Target","General.CastFail_InvalidTarget_Mechanical"  )
}

function OnEventOutOfRange( data ) {
    GameUI.SendCustomHUDError( "Out of Range","General.CastFail_InvalidTarget_Mechanical"  )
}