"use strict";

function MyCallBack(){
    //$.Msg("your awesome message")
    //Abilities.ExecuteAbility( integer nAbilityEntIndex, integer nCasterEntIndex, boolean bIsQuickCast )
    //Players.GetLocalPlayer()
    //Players.GetPlayerHeroEntityIndex( integer iPlayerID )
    //Abilities.GetKeybind( integer nAbilityEntIndex )

    var playerId = Players.GetLocalPlayer();
    $.Msg(playerId)
    var playerHero = Players.GetPlayerHeroEntityIndex( playerId );
    $.Msg(playerHero)
    var abilityIndex = Entities.GetAbility( playerHero, 4 )
    $.Msg(abilityIndex)
    
    Abilities.ExecuteAbility( abilityIndex, playerHero, false );

    // todo
    // add all abilities here - need to make sure each hero has similar abilities in similar locations?
    // change tooltip in game
    // figure out how to move the character around with wasd
    // need to link to a lua script to move the player, camera is js

}

function EmptyCallBack(){

}

(function()
{
    Game.AddCommand( "+CustomGameExecuteAbility1", MyCallBack, "", 0 );
    Game.AddCommand( "-CustomGameExecuteAbility1", EmptyCallBack, "", 0 );

})();

