"use strict";

function WrapFunction(name) {
    return function() {
        Game[name]();
    };
}
Game.EmptyCallback = function() {};

function MyCallBack(){
    //$.Msg("your awesome message")
    //Abilities.ExecuteAbility( integer nAbilityEntIndex, integer nCasterEntIndex, boolean bIsQuickCast )
    //Players.GetLocalPlayer()
    //Players.GetPlayerHeroEntityIndex( integer iPlayerID )
    //Abilities.GetKeybind( integer nAbilityEntIndex )

    var playerId = Players.GetLocalPlayer();
    //$.Msg(playerId)
    var playerHero = Players.GetPlayerHeroEntityIndex( playerId );
    //$.Msg(playerHero)
    var abilityIndex = Entities.GetAbility( playerHero, 4 )
    //$.Msg(abilityIndex)
    
    Abilities.ExecuteAbility( abilityIndex, playerHero, false );

    // todo
    // add all abilities here - need to make sure each hero has similar abilities in similar locations?
    // change tooltip in game
    // figure out how to move the character around with wasd
    // need to link to a lua script to move the player, camera is js

}

//order, direction
function Move(){
    var playerId = Players.GetLocalPlayer();
    var heroIndex = Players.GetPlayerHeroEntityIndex(playerId);
    
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", });
    //GameEvents.SendCustomGameEventToServer(order, { entityIndex: heroIndex, direction: direction });
    $.Msg("Sent game event...")
}


function OnPressW(){
    $.Msg("Javascript: OnPressW()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "down" });
}

function OnReleaseW(){
    $.Msg("Javascript: OnReleaseW()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w",  keyState: "up" });
}

function OnPressD() {
    $.Msg("Javascript: OnPressD()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "down" });
}

function OnReleaseD() {
    $.Msg("Javascript: OnReleaseD()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "up" });
}

function OnPressS() {
    $.Msg("Javascript: OnPressS()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "down" });
}

function OnReleaseS() {
    $.Msg("Javascript: OnReleaseS()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "up" });
}

function OnPressA() {
    $.Msg("Javascript: OnPressA()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "down" });
}

function OnReleaseA() {
    $.Msg("Javascript: OnReleaseA()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "", keyPressed: "a",  keyState: "up" });
}

(function()
{
    //Tried to use WrapFunction but it doesn't work for me. No idea what it does.
    // Game.AddCommand( "+W", WrapFunction("OnPressW"), "", 0 );
    // Game.AddCommand( "-W", WrapFunction("OnReleaseW"), "", 0 );    

    //W and S work.
    //A and D do not work. Probably because they have other bindings for me, A = attack, D = ability
    Game.AddCommand( "+W", OnPressW, "", 0 );
    Game.AddCommand( "-W", OnReleaseW, "", 0 );    

    Game.AddCommand( "+D", OnPressD, "", 0 );
    Game.AddCommand( "-D", OnReleaseD, "", 0 );    

    Game.AddCommand( "+S", OnPressS, "", 0 );
    Game.AddCommand( "-S", OnReleaseS, "", 0 );    

    Game.AddCommand( "+A", OnPressA, "", 0 );
    Game.AddCommand( "-A", OnReleaseA, "", 0 );    

})();

