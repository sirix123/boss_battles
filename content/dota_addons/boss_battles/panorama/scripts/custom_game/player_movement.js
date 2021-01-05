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

// MOVEMENT: 
function OnPressW(){
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "down", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "down" });
    }
}
    

function OnReleaseW(){
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "up", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w",  keyState: "up" });
    }
}

function OnPressD() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "right", keyPressed: "d", keyState: "down", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "down" });
    }
}

function OnReleaseD() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "right", keyPressed: "d", keyState: "up", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "up" });
    }
}

function OnPressS() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "down", keyPressed: "s", keyState: "down", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "down" });
    }
}

function OnReleaseS() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "down", keyPressed: "s", keyState: "up", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "up" });
    }
}

function OnPressA() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "left", keyPressed: "a", keyState: "down", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "down" });
    }
}

function OnReleaseA() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var time = Game.Time()

    if (LAG_SIM == true ){
        SendCustomGameEventWithLag("MoveUnit",{ entityIndex: heroIndex, direction: "left", keyPressed: "a", keyState: "up", time: time })
    }else{
        GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "up" });
    }
    
}

// handles keyboard hotkeys / called by hero selection
function Init()
{

    $.Msg("init movement controls")

    Game.AddCommand( "+W", OnPressW, "", 0 );
    Game.AddCommand( "-W", OnReleaseW, "", 0 );   

    Game.AddCommand( "+A", OnPressA, "", 0 );
    Game.AddCommand( "-A", OnReleaseA, "", 0 );   
    
    Game.AddCommand( "+S", OnPressS, "", 0 );
    Game.AddCommand( "-S", OnReleaseS, "", 0 ); 

    Game.AddCommand( "+D", OnPressD, "", 0 );
    Game.AddCommand( "-D", OnReleaseD, "", 0 );
}