if GameRules == nil then
    GameRules = class({})
end

function GameRules:Init()

    -- testing custom hero select
    GameRules:GetGameModeEntity():SetCustomGameForceHero( "npc_dota_hero_wisp" )

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 0)

    GameRules:EnableCustomGameSetupAutoLaunch(false)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetHeroSelectionTime(60)
    GameRules:SetStrategyTime(0)
    GameRules:SetPreGameTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPostGameTime(5)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetHeroRespawnEnabled(true)
    GameRules:SetStartingGold( 0 )
	GameRules:SetGoldTickTime( 999999.0 )
    GameRules:SetGoldPerTick( 0 )

    GameRules:SetTreeRegrowTime(9999)

    GameRules:SetHideKillMessageHeaders(true)
    GameRules:SetUseUniversalShopMode(false)

    GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
    GameRules:GetGameModeEntity():SetDeathOverlayDisabled(true)

    GameRules:GetGameModeEntity():SetFixedRespawnTime( 3 )
    GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1800 )
    GameRules:GetGameModeEntity():SetBuybackEnabled( false )
    GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride( "" )

    GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled( true )

    GameRules:SetTimeOfDay(0.5)
    --GameRules:GetGameModeEntity():SetDaynightCycleDisabled(true)

end