"use strict";

function AbilityToCast(abilityNumber){
    //$.Msg("we even trying to cast?")
    var playerId = Players.GetLocalPlayer();
    var playerHero = Players.GetPlayerHeroEntityIndex( playerId );
    var abilityIndex = Entities.GetAbility( playerHero, abilityNumber )
    
    if (playerHero == -1){
        $.Msg("[custom_hotkeys_players] no hero assigned")
    }
    else if (!abilityIndex){
        $.Msg("[custom_hotkeys_players] no ability found")
    }
    else{
        //$.Msg("[custom_hotkeys_players] casting ability", abilityIndex)
        Abilities.ExecuteAbility( abilityIndex, playerHero, false );
    }
}

function EmptyCallBack(){

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

// handles mouse hotkeys
GameUI.SetMouseCallback( function( eventName, arg ){
    var mouseButton = arg
    var CONSUME_EVENT = true;
    var CONTINUE_PROCESSING_EVENT = false;
    
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
		return CONTINUE_PROCESSING_EVENT;

    if ( eventName == "pressed" )
    {
        if ( mouseButton === 0 ) 
        { 
            AbilityToCast(0)
            $.Msg("leftclick")
            return CONSUME_EVENT;
        }
        if ( mouseButton === 1 ) 
        { 
            AbilityToCast(1)
            $.Msg("rightclick")
            return CONSUME_EVENT;
        }
    }

    if ( eventName == "released" )
    {
        $.Msg("released")
        EmptyCallBack()
    }

    if ( eventName === "doublepressed" )
	{
		return CONSUME_EVENT;
    }
    
    return CONTINUE_PROCESSING_EVENT;
});

// handles keyboard hotkeys
(function()
{

    Game.AddCommand( "+W", OnPressW, "", 0 );
    Game.AddCommand( "-W", OnReleaseW, "", 0 );   
    
    Game.AddCommand( "+A", OnPressA, "", 0 );
    Game.AddCommand( "-A", OnReleaseA, "", 0 );   
    
    Game.AddCommand( "+S", OnPressS, "", 0 );
    Game.AddCommand( "-S", OnReleaseS, "", 0 ); 

    Game.AddCommand( "+D", OnPressD, "", 0 );
    Game.AddCommand( "-D", OnReleaseD, "", 0 );

    // ability index in kv starts at 0... but says 1... dont be confused... :)
    // 1 
    Game.AddCommand( "+1", function(){ AbilityToCast(2) }, "", 0 );
    Game.AddCommand( "-1", EmptyCallBack, "", 0 );   

    // 2
    Game.AddCommand( "+2", function(){ AbilityToCast(3) }, "", 0 );
    Game.AddCommand( "-2", EmptyCallBack, "", 0 );   

    // 3
    Game.AddCommand( "+3", function(){AbilityToCast(4) }, "", 0 );
    Game.AddCommand( "-3", EmptyCallBack, "", 0 );   

    // Spacebar Movement Ability
    Game.AddCommand( "+Space", function(){ AbilityToCast(5) }, "", 0 );
    Game.AddCommand( "-Space", EmptyCallBack, "", 0 );   

})();

