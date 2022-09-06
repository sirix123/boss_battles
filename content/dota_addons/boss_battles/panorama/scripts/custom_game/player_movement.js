"use strict";

GameEvents.Subscribe( "picking_done", Init );

var pingaverage = 500;
var pingdelta = 200;
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

let random_string = makeid(10);

function Init(  ) {

    for(var i in hotkeys) {
        let command_name = hotkeys[i] + random_string;
        Game.CreateCustomKeyBind(hotkeys[i], "+" + command_name);
    } 

    Game.AddCommand( "+W" + random_string, function() { OnHotkeyDownEvent("W");  }, "", 0 );
    Game.AddCommand( "-W" + random_string, function() { OnHotkeyUpEvent("W");    }, "", 0 );

    Game.AddCommand( "+S" + random_string, function() { OnHotkeyDownEvent("S");  }, "", 0 );
    Game.AddCommand( "-S" + random_string, function() { OnHotkeyUpEvent("S");    }, "", 0 );

    Game.AddCommand( "+A" + random_string, function() { OnHotkeyDownEvent("A");  }, "", 0 );
    Game.AddCommand( "-A" + random_string, function() { OnHotkeyUpEvent("A");    }, "", 0 );

    Game.AddCommand( "+D" + random_string, function() { OnHotkeyDownEvent("D");  }, "", 0 );
    Game.AddCommand( "-D" + random_string, function() { OnHotkeyUpEvent("D");    }, "", 0 );

}


function OnHotkeyDownEvent( key ) {
    var query_data = {
        'command': key,
        'type': '+',
        'randomString': random_string,
    }

    GameEvents.SendCustomGameEventToServer( "MoveUnit", query_data );
    //SendCustomGameEventWithLag( "MoveUnit", query_data )
}

function OnHotkeyUpEvent( key ) {
    var query_data = {
        'command': key,
        'type': '-',
        'randomString': random_string,
    }
    GameEvents.SendCustomGameEventToServer( "MoveUnit", query_data );
    //SendCustomGameEventWithLag( "MoveUnit", query_data )
}

function makeid(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
      result += characters.charAt(Math.floor(Math.random() * 
 charactersLength));
   }
   return result;
}