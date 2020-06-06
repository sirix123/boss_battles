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
        Abilities.ExecuteAbility( abilityIndex, playerHero, true );
    }
}

function EmptyCallBack(){

}

function ExecuteAbilityNamed(abilityName) {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    //var abilityIndex = Entities.GetAbility( playerHero, abilityNumber )
    var ability = Entities.GetAbilityByName( heroIndex, abilityName);

    if (!ability) {
        $.Msg("custom_hotkeys_players.js cannot find abilityName = " + abilityName);
    }
    else {
        $.Msg("custom_hotkeys_players.js found abilityName = " + abilityName) ;  
    }

    //ability.state = "stateFromJS";

    Abilities.ExecuteAbility( ability, heroIndex, true );
}

//Javscript timer example:
// (function tic()
// {
//     if ( GameUI.IsMouseDown( 0 ) ){
//         AbilityToCast(0);
//         $.Schedule( 0.1, tic );
//     }
// })();

function OnPressPowerShot() {
    ExecuteAbilityNamed("powerShot")
}

function OnReleasePowerShot() {
    ExecuteAbilityNamed("powerShot")
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
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "up" });
}

function OnLeftButtonPressed()
{
    AbilityToCast(0);
    /*(function tic()
    {
        if ( GameUI.IsMouseDown( 0 ) )
        {
            $.Schedule( 1.0/30.0, tic );
            AbilityToCast(0);
        }
    })();*/
}

function OnRightButtonPressed()
{
    AbilityToCast(1);
}



//Powershot works by clicking and holding the mouse, the code calls the ability twice, once on mouse click ( isMouseDown() ) and again on release ( !isMouseDown() )

var powerShotFirstClick = true
function PowerShotManager()
{
    $.Msg("Javascript: PowerShotManager()...")
    if (powerShotFirstClick == true) {
        powerShotFirstClick = false;
        ExecuteAbilityNamed("powerShot")
    }

    (function tick()
    {
        //Mouse button down
        if ( GameUI.IsMouseDown( 1 ) )
            $.Schedule( 0.1, tick );
        //Mouse lifted        
        else 
        {
            ExecuteAbilityNamed("powerShot")
            powerShotFirstClick = true
        }
    })();

}


//Powershot works by calling the ability twice, once at the start charging up, second time to fire the ability.
var slingShotFirstClick = true
function slingShotManager()
{
    $.Msg("Javascript: slingShotManager()...")

    if (slingShotFirstClick == true) {
        slingShotFirstClick = false;
        ExecuteAbilityNamed("slingShot")
    }

    (function tick()
    {
        if ( GameUI.IsMouseDown( 0 ) )
            $.Schedule( 0.1, tick );
        //Mouse lifted. calc the distance between click and pullback location
        else 
        {
            ExecuteAbilityNamed("slingShot")
            slingShotFirstClick = true
        }
    })();
}


GameUI.SetMouseCallback( function( eventName, arg ){

    $.Msg("Javascript: SetMouseCallback ")

	var nMouseButton = arg;
	var CONSUME_EVENT = true;
    var CONTINUE_PROCESSING_EVENT = false;
    
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE ){
        return CONTINUE_PROCESSING_EVENT;
    }

    if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_DRAG) {
        $.Msg("Javascript: SetMouseCallback() DRAG event ")
    }


    if ( eventName === "pressed" )
	{
		if ( nMouseButton === 0 )
		{
            OnLeftButtonPressed();
            //GetMouseCastPosition();
            //slingShotManager();
            
            return CONSUME_EVENT;
		}

		if ( nMouseButton === 1 )
		{
			OnRightButtonPressed();
            //PowerShotManager();
			return CONSUME_EVENT;
        }
    }
    if (eventName === "released"){
        if ( nMouseButton === 1 )
		{
			EmptyCallBack();
			return CONSUME_EVENT;
        }
    }
	if ( eventName === "doublepressed" ){ return CONSUME_EVENT }
	return CONTINUE_PROCESSING_EVENT;
});


function GetCursorPosition()
{
    var screenCursorPosition = GameUI.GetCursorPosition();
    return Game.ScreenXYToWorld(screenCursorPosition[0], screenCursorPosition[1]);
}

//this should be two functions
function GetMouseCastPosition(  )
{

    var mouse_position_screen = GameUI.GetCursorPosition();
    var mouse_position = Game.ScreenXYToWorld(mouse_position_screen[0], mouse_position_screen[1])

	GameEvents.SendCustomGameEventToServer("MousePosition", {
        playerID: Players.GetLocalPlayer(), 
        x: mouse_position[0], 
        y: mouse_position[1],
        z: mouse_position[2],
    });
}

(function tic()
	{

        $.Schedule( 1.0/30.0, tic );
        GetMouseCastPosition()

	})();

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


    //TESTING: Ability Powershot ability on Kunkka, press and hold SPACE to charge up, release to fire
    Game.AddCommand( "+Space", OnPressPowerShot, "", 0 );
    Game.AddCommand( "-Space", OnReleasePowerShot, "", 0 );

    // Spacebar Movement Ability
    // Game.AddCommand( "+Space", function(){ AbilityToCast(5) }, "", 0 );
    // Game.AddCommand( "-Space", EmptyCallBack, "", 0 );

})();   


