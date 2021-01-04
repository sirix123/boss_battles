"use strict";

GameEvents.Subscribe( "picking_done", Init );

//Globals:
var nextAbility = null;
var currentAbility = null;

//Try to add to currentAbility or nextAbility, if both are taken then return false.
function TryAddAbilityToQueue(abilityIndex)
{
    if (currentAbility === null) {
        currentAbility = abilityIndex;
        return true;
    }
    else if (nextAbility === null) {
        nextAbility = abilityIndex;
        return true;
    }
    return false;
}

function ForceAddAbilityToQueue(abilityIndex) {
    //Either add this ability as the currentAbility, or force it to be the next ability
    if (currentAbility === null) {
        currentAbility = abilityIndex;
        return;
    }
    nextAbility = abilityIndex;
}

//Call this function to start the ability queue. Ability queue
function ProcessAbilityQueue()
{
    var delay = 0.08;
    $.Schedule(delay, function abilityQueueTick(){
        if (currentAbility != null) {
            CastAbility(currentAbility);
            currentAbility = null;
        }
        if (nextAbility != null) {
            currentAbility = nextAbility;
            nextAbility = null;
        }   
        // end of mini game loop. Restart this function. 
        $.Schedule(delay, abilityQueueTick);
    })
}

function CastAbility(currentAbility)
{
    //CAST IT:
    AbilityToCast(currentAbility, true);
}


//soon to be Previous ability casting methods:
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

    // if the ability is not ready (cd/no mana) don't try and cast it...
    if ( Abilities.AbilityReady( abilityIndex ) == false ) 
    {
        $.Msg("[custom_hotkeys_players] spell not ready, cooldown or mana?")
        return
    }


    //Abilities.ExecuteAbility( abilityIndex, playerHero, quickCast );
    if(!Abilities.IsInAbilityPhase(abilityIndex) && Abilities.IsActivated(abilityIndex))
    {
        var mouse_position_screen = GameUI.GetCursorPosition();
        var mouse_position = Game.ScreenXYToWorld(mouse_position_screen[0], mouse_position_screen[1])
        var abilityBehavior = Abilities.GetBehavior(abilityIndex)

        if( ( abilityBehavior == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT ) || ( abilityBehavior ==  DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_HIDDEN ) || ( abilityBehavior ==  DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES ) )
        {
            if (abilityIndex == 0 || abilityIndex == 1)
            {
                var order = 
                {
                    OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION,
                    TargetIndex : playerHero,
                    Position : mouse_position,
                    QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_ALWAYS,
                    ShowEffects : showEffects,
                    AbilityIndex : abilityIndex,
                };
                Game.PrepareUnitOrders(order);
            }
            else 
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
        }

        if(abilityBehavior == ( DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT ))
        {
            var max_range = Abilities.GetCastRange(abilityIndex);
            var player_origin = Entities.GetAbsOrigin(playerHero)
            var dist = Game.Length2D(mouse_position, player_origin)

            if (dist > max_range)
            {
                GameUI.SendCustomHUDError( "Out Of Range","General.CastFail_InvalidTarget_Mechanical"  )
                return 
            }

            var order = 
            {
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION,
                TargetIndex : playerHero,
                Position : mouse_position,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : showEffects,
                AbilityIndex : abilityIndex,
            };
            //Game.PrepareUnitOrders(order);

            Abilities.ExecuteAbility( abilityIndex, playerHero, false )
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
            var mouse_position_screen = GameUI.GetCursorPosition();
            var cursor_targets = GameUI.FindScreenEntities(mouse_position_screen)
            var target = []

            for ( var entity of cursor_targets )
            {
                if ( !entity.accurateCollision )
                    continue
                target = entity.entityIndex
            }

            // if targeting nothing (the ground) display this error message
            if (target.length == 0)
            {
                GameUI.SendCustomHUDError( "No Target","General.CastFail_InvalidTarget_Mechanical"  )
                return
            }

            // if we have a target.. populate some variables 
            if (target.length != 0)
            {
                var max_range = Abilities.GetCastRange(abilityIndex);
                var target_origin = Entities.GetAbsOrigin(target)
                var player_origin = Entities.GetAbsOrigin(playerHero)
                var dist = Game.Length2D(target_origin, player_origin)

                // if we are outside the range of the spell display error message
                if (dist > max_range)
                {
                    // need two if statements here... if target outside of range is friendly dispaly out of range if enemy dispaly wrong team error message

                    //"General.CastFail_InvalidTarget_Mechanical" = "sounds/ui/ui_general_deny.vsnd"
                    //https://github.com/SteamDatabase/GameTracking-Dota2/blob/master/game/dota/pak01_dir/soundevents/game_sounds_ui_imported.vsndevts
                    GameUI.SendCustomHUDError( "Out Of Range","General.CastFail_InvalidTarget_Mechanical"  ) 
                    
                    //Players.GetTeam( integer iPlayerID )
                    //$.Msg("playerID: ",Players.GetTeam( target ))
                }
            }

            if (target.length != 0 && dist < max_range)
            {
                var order = 
                {
                    OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET,                       
                    TargetIndex : target,
                    QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                    ShowEffects : showEffects,
                    AbilityIndex : abilityIndex,
                };
                Game.PrepareUnitOrders(order);
            }
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

function UseItem(itemSlot)
{
    var playerId = Players.GetLocalPlayer();
    var heroIndex = Players.GetPlayerHeroEntityIndex(playerId);

    var abilityIndex = Entities.GetItemInSlot(heroIndex, itemSlot);

    if(heroIndex == -1){
        $.Msg("[Custom Bindings] Invalid hero: The hero hasn't been asigned yet");
        return;
    }
    if(!abilityIndex){
        $.Msg("[Custom Bindings] Invalid ability: The ability doesn't exist");
        return;
    }
    if(!Abilities.IsInAbilityPhase(abilityIndex)){
        //var mouse_position_screen = GameUI.GetCursorPosition();
        //var mouse_position = Game.ScreenXYToWorld(mouse_position_screen[0], mouse_position_screen[1])

        Abilities.ExecuteAbility( abilityIndex, heroIndex, false )
        /*
        var abilityBehavior = Abilities.GetBehavior(abilityIndex)
        if(abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT){
            var order = {
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_POSITION,
                TargetIndex : heroIndex,
                Position : mouse_position,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : true,
                AbilityIndex : abilityIndex,
            };
            Game.PrepareUnitOrders(order);
        }
        if(abilityBehavior & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET){
            var order = {
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET,
                TargetIndex : heroIndex,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : true,
                AbilityIndex : abilityIndex,
            };
            Game.PrepareUnitOrders(order);
        }*/
    }
}


// MOVEMENT: 
function OnPressW(){
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w", keyState: "down" });
}

function OnReleaseW(){
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up", keyPressed: "w",  keyState: "up" });
}

function OnPressD() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "down" });
}

function OnReleaseD() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "right", keyPressed: "d",  keyState: "up" });
}

function OnPressS() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "down" });
}

function OnReleaseS() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "down", keyPressed: "s",  keyState: "up" });
}

function OnPressA() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "down" });
}

function OnReleaseA() {
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "left", keyPressed: "a",  keyState: "up" });
}

function OnPressQ() {
    //TryAddAbilityToQueue(2);
    ForceAddAbilityToQueue(2);
}   

function OnPressE() {
    //TryAddAbilityToQueue(3);
    ForceAddAbilityToQueue(3);
}

function OnPressR() {
    //TryAddAbilityToQueue(4);
    ForceAddAbilityToQueue(4);
}

function OnPress1() {
    //TryAddAbilityToQueue(2);
    UseItem(0);
}   


// ABILITIES: 
function OnLeftButtonPressed()
{
    TryAddAbilityToQueue(0);

    //TODO: put this on other abilities?
    var heroEntity = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var playerEntity = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer("customEvent_abilityCast", {heroEntity: heroEntity, playerEntity: playerEntity});

    // AbilityToCast(0, true);

    // //cast this ability again if mouse is still down in 0.2 seconds
    // //start a timer
    $.Schedule(0.3, function tic(){
        //only continue timer if mouse still down
        if (GameUI.IsMouseDown(0)){
            TryAddAbilityToQueue(0);
            $.Schedule(0.3, tic);
        }
    })
}

function OnRightButtonPressed()
{
    ForceAddAbilityToQueue(1);
    //AbilityToCast(1, true);
}


function ShowScoreboard()
{
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var playerId = Players.GetLocalPlayer()

    //Call test_scoreboard.js function: showScoreboardUI() by going to lua then back to js.
    //Send even back to lua. Which should have registered a listener for showScoreboardUIEvent
    GameEvents.SendCustomGameEventToServer("showScoreboardUIEvent", {heroIndex: heroIndex, playerId: playerId});
    //GameEvents.SendCustomGameEventToServer("getScoreboardDataEvent", {});
}

function HideScoreboard()
{
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var playerId = Players.GetLocalPlayer()
    //Send even back to lua. Which should have registered a listener for hideScoreboardUIEvent
    GameEvents.SendCustomGameEventToServer("hideScoreboardUIEvent", {heroIndex: heroIndex, playerId: playerId});
}


//Gets called every mouse event?
//not 100% sure what the return value does
GameUI.SetMouseCallback( function( eventName, arg ){
	var nMouseButton = arg;
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE ){
        return false;
    }

    //if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_DRAG) {
        //$.Msg("Javascript: SetMouseCallback() DRAG event ")
    //}

    if ( eventName === "pressed" )
	{
		if ( nMouseButton === 0 )
		{
            OnLeftButtonPressed();
            //Ctrl key is down:
            // if(GameUI.IsControlDown()){
            //     return true;
            // }
            return true;
		}

		if ( nMouseButton === 1 )
		{
			OnRightButtonPressed();
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
	if ( eventName === "doublepressed" ){ 
        return true
    }
	return false;
});


function GetCursorPosition()
{
    var screenCursorPosition = GameUI.GetCursorPosition();
    return Game.ScreenXYToWorld(screenCursorPosition[0], screenCursorPosition[1]);
}


function GetMouseCastPosition(  )
{
    var mouse_position_screen = GameUI.GetCursorPosition();
    var mouse_position = Game.ScreenXYToWorld(mouse_position_screen[0], mouse_position_screen[1]);
    var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());

    //$.Msg(GameUI.FindScreenEntities(mouse_position_screen))
	GameEvents.SendCustomGameEventToServer("MousePosition", {
        playerID: Players.GetLocalPlayer(), 
        x: mouse_position[0], 
        y: mouse_position[1],
        z: mouse_position[2],
        entityIndex: heroIndex,
    });
}

//Start a loop to constantly update mouse cast positions
function MouseInit(){
    $.Schedule( 0.03, function tic(){
        GetMouseCastPosition()
        $.Schedule(0.03, tic);
    } );
}

// handles keyboard hotkeys / called by hero selection
function Init()
{

    $.Msg("init all custom mouse and movement controls")

    MouseInit()

    ProcessAbilityQueue();

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
    //Game.AddCommand( "+Q", function(){ AbilityToCast(2, true) }, "", 0 );
    Game.AddCommand( "+Q", OnPressQ, "", 0 );
    Game.AddCommand( "-Q", EmptyCallBack, "", 0 );   

    // 2
    Game.AddCommand( "+E", OnPressE, "", 0 );
    Game.AddCommand( "-E", EmptyCallBack, "", 0 );   

    // 3
    Game.AddCommand( "+R", OnPressR, "", 0 );
    Game.AddCommand( "-R", EmptyCallBack, "", 0 );   

    // item hot keys
    Game.AddCommand( "+1", OnPress1, "", 0 );
    Game.AddCommand( "-1", EmptyCallBack, "", 0 );   

    //TESTING: SCOREBOARD 
    Game.AddCommand( "+L", ShowScoreboard, "", 0 );
    Game.AddCommand( "-L", HideScoreboard, "", 0 );

    //TESTING: Ability Powershot ability on Kunkka, press and hold SPACE to charge up, release to fire
    //Game.AddCommand( "+Space", OnPressPowerShot, "", 0 );
    //Game.AddCommand( "-Space", OnReleasePowerShot, "", 0 );

    // Spacebar Movement Ability
    Game.AddCommand( "+Space", function(){ AbilityToCast(5, true) }, "", 0 );
    Game.AddCommand( "-Space", EmptyCallBack, "", 0 );

    // get mouse position
    //GameEvents.Subscribe('mouse_position', GetMouseCastPosition);
}

(function () {
    
})();


