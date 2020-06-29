"use strict";

function AbilityToCast(abilityNumber, showEffects){
    var playerId = Players.GetLocalPlayer();
    var playerHero = Players.GetPlayerHeroEntityIndex( playerId );
    var abilityIndex = Entities.GetAbility( playerHero, abilityNumber )

    if (playerHero == -1){
        $.Msg("[custom_hotkeys_players] no hero assigned")
        return
    }

    if (!abilityIndex){
        $.Msg("[custom_hotkeys_players] no ability found")
        return
    }

    //Abilities.ExecuteAbility( abilityIndex, playerHero, quickCast );
    if(!Abilities.IsInAbilityPhase(abilityIndex))
    {
        var mouse_position_screen = GameUI.GetCursorPosition();
        var mouse_position = Game.ScreenXYToWorld(mouse_position_screen[0], mouse_position_screen[1])

        var abilityBehavior = Abilities.GetBehavior(abilityIndex)
        if(abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT)
        {
            var order = 
            {
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION,
                TargetIndex : playerHero,
                Position : mouse_position,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : showEffects,
                AbilityIndex : abilityIndex,
            };
            Game.PrepareUnitOrders(order);
        }
        if(abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET)
        {
            var order = 
            {
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET,                       
                TargetIndex : playerHero,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : showEffects,
                AbilityIndex : abilityIndex,
            };
            Game.PrepareUnitOrders(order);
        }
        if(abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)
        {

            Abilities.ExecuteAbility( abilityIndex, playerHero, false );

           /* $.Msg(Players.GetLocalPlayerPortraitUnit())

            var target = Players.GetLocalPlayerPortraitUnit()

            //var mouse_position_screen = GameUI.GetCursorPosition();
            //var target = GameUI.FindScreenEntities(mouse_position_screen)

            if (target == null)
            {
                $.Msg("[custom_hotkeys_players] no entity found on cursor location")
                return
            }
            
            $.Msg(GameUI.FindScreenEntities(mouse_position_screen))
            
            var order = 
            {
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET,                       
                TargetIndex : target,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : showEffects,
                AbilityIndex : abilityIndex,
            };
            Game.PrepareUnitOrders(order);*/
        }
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
    //$.Msg("Javascript: OnPressW()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "down" });
}

function OnReleaseW(){
    //$.Msg("Javascript: OnReleaseW()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w",  keyState: "up" });
}

function OnPressD() {
    //$.Msg("Javascript: OnPressD()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "down" });
}

function OnReleaseD() {
    //$.Msg("Javascript: OnReleaseD()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "up" });
}

function OnPressS() {
    //$.Msg("Javascript: OnPressS()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "down" });
}

function OnReleaseS() {
    //$.Msg("Javascript: OnReleaseS()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "up" });
}

function OnPressA() {
    //$.Msg("Javascript: OnPressA()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "down" });
}

function OnReleaseA() {
    //$.Msg("Javascript: OnReleaseA()...")
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "up" });
}

function OnLeftButtonPressed()
{
    var heroEntity = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var playerEntity = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer("customEvent_abilityCast", {heroEntity: heroEntity, playerEntity: playerEntity});

    AbilityToCast(0, true);
    $.Schedule(0.1, function tic(){
        if (GameUI.IsMouseDown(0)){
            AbilityToCast(0, false);
            $.Schedule(0.1, tic);
        }
    })
}

function OnRightButtonPressed()
{
    AbilityToCast(1, true);
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

    //$.Msg("Javascript: SetMouseCallback ")

	var nMouseButton = arg;
    
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE ){
        return false;
    }

    if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_DRAG) {
        //$.Msg("Javascript: SetMouseCallback() DRAG event ")
    }

    if ( eventName === "pressed" )
	{
		if ( nMouseButton === 0 )
		{
            OnLeftButtonPressed();
            //GetMouseCastPosition();
            //slingShotManager();

            if(GameUI.IsControlDown()){
                return false;
            }
            return true;
		}

		if ( nMouseButton === 1 )
		{
			OnRightButtonPressed();
            //PowerShotManager();
			return true;
        }
    }
    if (eventName === "released"){
        if ( nMouseButton === 1 )
		{
			EmptyCallBack();
			return true;
        }
    }
	if ( eventName === "doublepressed" ){ return true }
	return false;
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
    //$.Msg(GameUI.FindScreenEntities(mouse_position_screen))
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
    Game.AddCommand( "+Q", function(){ AbilityToCast(2, true) }, "", 0 );
    Game.AddCommand( "-Q", EmptyCallBack, "", 0 );   

    // 2
    Game.AddCommand( "+E", function(){ AbilityToCast(3, true) }, "", 0 );
    Game.AddCommand( "-E", EmptyCallBack, "", 0 );   

    // 3
    Game.AddCommand( "+R", function(){AbilityToCast(4, true) }, "", 0 );
    Game.AddCommand( "-R", EmptyCallBack, "", 0 );   


    //TESTING: Ability Powershot ability on Kunkka, press and hold SPACE to charge up, release to fire
    //Game.AddCommand( "+Space", OnPressPowerShot, "", 0 );
    //Game.AddCommand( "-Space", OnReleasePowerShot, "", 0 );

    // Spacebar Movement Ability
    Game.AddCommand( "+Space", function(){ AbilityToCast(5, true) }, "", 0 );
    Game.AddCommand( "-Space", EmptyCallBack, "", 0 );

})();   


