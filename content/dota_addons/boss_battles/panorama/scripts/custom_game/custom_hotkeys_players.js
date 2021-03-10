"use strict";

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

    //$.Msg("we trtying to cast spells?")
    
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
    var ability = Entities.GetAbilityByName( heroIndex, abilityName);

    if (!ability) {
        $.Msg("custom_hotkeys_players.js cannot find abilityName = " + abilityName);
    }
    else {
        $.Msg("custom_hotkeys_players.js found abilityName = " + abilityName) ;  
    }
    Abilities.ExecuteAbility( ability, heroIndex, true );
}

// ITEM CONTROLLER
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
        Abilities.ExecuteAbility( abilityIndex, heroIndex, false )
    }
}


// MOUSE CONTROLLER
function OnLeftButtonPressed()
{
    TryAddAbilityToQueue(0);

    var playerEntity = Players.GetLocalPlayer();

    if ( Players.GetPlayerSelectedHero( playerEntity ) != "npc_dota_hero_lina" ){
        $.Schedule(0.3, function tic(){
            //only continue timer if mouse still down
            if (GameUI.IsMouseDown(0))
            {
                TryAddAbilityToQueue(0);
                $.Schedule(0.3, tic);
            }
        })
    }
}

function OnRightButtonPressed()
{
    ForceAddAbilityToQueue(1);
}


GameUI.SetMouseCallback( function( eventName, arg ){
	var nMouseButton = arg;
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE ){
        return false;
    }

    if ( eventName === "pressed" )
	{
		if ( nMouseButton === 0 )
		{
            OnLeftButtonPressed();
            var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
            var playerId = Players.GetLocalPlayer()
            GameEvents.SendCustomGameEventToServer("left_mouse_release", {heroIndex: heroIndex, playerId: playerId, pos: false});

            return true;
		}

		if ( nMouseButton === 1 )
		{
			OnRightButtonPressed();
			return true;
        }
    }
    if (eventName === "released"){
        if ( nMouseButton === 0 )
		{
            var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
            var playerId = Players.GetLocalPlayer()
			GameEvents.SendCustomGameEventToServer("left_mouse_release", {heroIndex: heroIndex, playerId: playerId, pos: true});
			return true;
        }

        if ( nMouseButton === 1 )
		{
			EmptyCallBack();
			return true;
        }
    }
	if ( eventName === "doublepressed" ){ 
        return true
    }

    if ( eventName === "wheeled" ) // GameUI.AcceptWheeling
    {
        if ( arg < 0 )
        {
            return false	
        }
        else if ( arg > 0 )
        {
            return false		
        }
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

	GameEvents.SendCustomGameEventToServer("MousePosition", {
        playerID: Players.GetLocalPlayer(), 
        x: mouse_position[0], 
        y: mouse_position[1],
        z: mouse_position[2],
        entityIndex: heroIndex,
    });
}

function MouseInit(){
    $.Schedule( 0.03, function tic(){
        GetMouseCastPosition()
        $.Schedule(0.03, tic);
    } );
}

// INIT
let hotkeys = [
    "Q",
    "E",
    "R",
    "1",
    "L",
    "Space",
];

(function () 
{
    //$.Msg("init all custom mouse and movement controls")

    MouseInit()

    ProcessAbilityQueue();

    for(var i in hotkeys) {
        $.Msg("hotkey = ", hotkeys[i])
        Game.CreateCustomKeyBind(hotkeys[i], "+" + hotkeys[i]);
    }

    Game.AddCommand( "+Q", function(){ ForceAddAbilityToQueue(2) }, "", 0 );
    Game.AddCommand( "-Q", EmptyCallBack, "", 0 );   

    Game.AddCommand( "+E", function(){ ForceAddAbilityToQueue(3) }, "", 0 );
    Game.AddCommand( "-E", EmptyCallBack, "", 0 );   

    Game.AddCommand( "+R", function(){ ForceAddAbilityToQueue(4) }, "", 0 );
    Game.AddCommand( "-R", EmptyCallBack, "", 0 );   

    Game.AddCommand( "+1", function(){ UseItem(0) }, "", 0 );
    Game.AddCommand( "-1", EmptyCallBack, "", 0 );   

    Game.AddCommand( "+L", ShowScoreboard, "", 0 );
    Game.AddCommand( "-L", HideScoreboard, "", 0 );

    Game.AddCommand( "+Space", function(){ AbilityToCast(5, true) }, "", 0 );
    Game.AddCommand( "-Space", EmptyCallBack, "", 0 );

})();

function EmptyCallBack(){

}

// SCOREBOARD
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
