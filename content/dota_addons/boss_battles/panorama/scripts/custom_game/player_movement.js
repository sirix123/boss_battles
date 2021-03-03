"use strict";

GameEvents.Subscribe( "picking_done", Init );

let LAG_SIM = false

var pingaverage = 1500;
var pingdelta = 750;
function SendCustomGameEventWithLag( e, data ) {
    // Calculate delay
    var time = pingaverage/2;
    var delta = Math.random() * pingdelta - pingdelta/2;
    time = (time + delta)/1000;
    if (time<0) time=0;

    // delayed send
    $.Schedule( time, function() {
        GameEvents.SendCustomGameEventToServer( e, data );
    });
}

//var time = Game.Time()
//GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "down" });

let hotkeys = [
    "W",
    "S",
    "A",
    "D",
];

//function Init() {
(function() {
    for(var i in hotkeys) {
        Game.CreateCustomKeyBind(hotkeys[i], "+" + hotkeys[i]);
        
        (function(i) {
            Game.AddCommand( "+" + hotkeys[i], function() {
                OnHotkeyDownEvent(hotkeys[i]);
            }, "", 0 );
            Game.AddCommand( "-" + hotkeys[i], function() {
                OnHotkeyUpEvent(hotkeys[i]);
            }, "", 0 );
        })(i);
    }
//}
})();

function OnHotkeyDownEvent( key ) {
    var query_data = {
        'heroEnt': Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
        'command': key,
        'type': '+',
    }
    GameEvents.SendCustomGameEventToServer( "MoveUnit", query_data );
    //SendCustomGameEventWithLag( "MoveUnit", query_data )
}

function OnHotkeyUpEvent( key ) {
    var query_data = {
        'heroEnt': Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
        'command': key,
        'type': '-',
    }
    GameEvents.SendCustomGameEventToServer( "MoveUnit", query_data );
    //SendCustomGameEventWithLag( "MoveUnit", query_data )
}
