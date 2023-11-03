"use strict";

//soon to be Previous ability casting methods:
let previous_ability = null
function AbilityToCast(abilityNumber, showEffects){
    var playerId = Players.GetLocalPlayer();
    var playerHero = Players.GetPlayerHeroEntityIndex( playerId );
    var abilityIndex = Entities.GetAbility( playerHero, abilityNumber )
   
    if (playerHero == -1){
        $.Msg("[custom_hotkeys_players] no hero assigned");
        return
    }

    if (!abilityIndex){
        $.Msg("[custom_hotkeys_players] no ability found");
        return
    }

    // if the ability is not ready (cd/no mana) don't try and cast it...
    if ( Abilities.AbilityReady( abilityIndex ) == false ) 
    {
        $.Msg("[custom_hotkeys_players] spell not ready, cooldown or mana?");
        return
    }

    // if the ability coming in is already being cast just dont do anything (except if m1)
    if ( abilityIndex ){
        if ( Abilities.IsInAbilityPhase(abilityIndex) && abilityNumber !== 0){
            $.Msg("[custom_hotkeys_players] ability that isn't m1 is being cast twice");
            return
        }    
    }

    Abilities.ExecuteAbility( abilityIndex, playerHero, false );
}

function EmptyCallBack(){

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

// INIT
let hotkeys = [
    "Q",
    "W",
    "E",
    "R",
    "T",
    "1",
    "L",
    "Space",
];

(function () 
{
    $.Msg("init all custom mouse and movement controls")

    var random_string = makeid(10);

    for(var i in hotkeys) {
        Game.CreateCustomKeyBind(hotkeys[i], "+" + hotkeys[i] + random_string);
    }

    Game.AddCommand( "+Q" + random_string, function(){ AbilityToCast(0) }, "", 0 );
    Game.AddCommand( "-Q" + random_string, EmptyCallBack, "", 0 );   

    Game.AddCommand( "+W" + random_string, function(){ AbilityToCast(1) }, "", 0 );
    Game.AddCommand( "-W" + random_string, EmptyCallBack, "", 0 );   

    Game.AddCommand( "+E" + random_string, function(){ AbilityToCast(2) }, "", 0 );
    Game.AddCommand( "-E" + random_string, EmptyCallBack, "", 0 );   

    Game.AddCommand( "+R" + random_string, function(){ AbilityToCast(3) }, "", 0 );
    Game.AddCommand( "-R" + random_string, EmptyCallBack, "", 0 );   

    Game.AddCommand( "+T" + random_string, function(){ AbilityToCast(4) }, "", 0 );
    Game.AddCommand( "-T" + random_string, EmptyCallBack, "", 0 );   

    Game.AddCommand( "+1" + random_string, function(){ UseItem(0) }, "", 0 );
    Game.AddCommand( "-1" + random_string, EmptyCallBack, "", 0 );   

    Game.AddCommand( "+L" + random_string, ShowScoreboard, "", 0 );
    Game.AddCommand( "-L" + random_string, HideScoreboard, "", 0 );

    Game.AddCommand( "+Space" + random_string, function(){ AbilityToCast(5, true) }, "", 0 );
    Game.AddCommand( "-Space" + random_string, EmptyCallBack, "", 0 );

})();

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

function EmptyCallBack(){

}

// SCOREBOARD
function ShowScoreboard()
{
    //Call test_scoreboard.js function: showScoreboardUI() by going to lua then back to js.
    //Send even back to lua. Which should have registered a listener for showScoreboardUIEvent
    GameEvents.SendCustomGameEventToServer("showScoreboardUIEvent", {});
    //GameEvents.SendCustomGameEventToServer("getScoreboardDataEvent", {});
}

function HideScoreboard()
{
    //Send even back to lua. Which should have registered a listener for hideScoreboardUIEvent
    GameEvents.SendCustomGameEventToServer("hideScoreboardUIEvent", {});
}
