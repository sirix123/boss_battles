"use strict";

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

function EmptyCallBack(){

}
//order, direction
function Move(){

    var playerId = Players.GetLocalPlayer();
    var heroIndex = Players.GetPlayerHeroEntityIndex(playerId);
    
    GameEvents.SendCustomGameEventToServer("MoveUnit", { entityIndex: heroIndex, direction: "up" });
    //GameEvents.SendCustomGameEventToServer(order, { entityIndex: heroIndex, direction: direction });
    $.Msg("Sent game event...")
}

function MoveUnit(){

}

(function()
{
    Game.AddCommand( "+S", MyCallBack, "", 0 );
    Game.AddCommand( "-S", EmptyCallBack, "", 0 );

    Game.AddCommand( "+W", Move, "", 0 );
    Game.AddCommand( "-W", EmptyCallBack, "", 0 );

    //Game.OnPressW =     function(){ Move( "MoveUnit", "up" ) }
    //Game.OnReleaseW =   function(){ Move( "StopUnit", "up" ) }

})();

