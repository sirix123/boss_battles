"use strict";

GameEvents.Subscribe( "display_lag_message", OnDisplayLagMessage );

function OnDisplayLagMessage( data ) {
    $('#LagMessageContainer').style.visibility = 'visible';

    $.Schedule(10, HideDisplayLagMessage);
}

function HideDisplayLagMessage( ) {
    $('#LagMessageContainer').style.visibility = 'collapse';
}

(function () {

	//let lagMessageContainer = $("#LagMessageContainer"); // lag message container
    //$('#LagMessageContainer').DeleteAsync( 0.0 );

    //let lagMessageContainer = $("#LagMessageContainer"); // lag message container
    $('#LagMessageContainer').style.visibility = 'collapse';

})();