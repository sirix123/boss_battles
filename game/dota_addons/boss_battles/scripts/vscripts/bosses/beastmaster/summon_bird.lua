
summon_bird = class({})

--------------------------------------------------------------------------------

function summon_bird:OnSpellStart()
    if IsServer() then

        EmitSoundOn("lone_druid_lone_druid_spawn_01", self:GetCaster())
        
        local vRandomOffset = Vector( RandomInt( -100, 100 ), RandomInt( -100, 100 ), 0 )
        local vSpawnArea = self:GetCaster():GetAbsOrigin() + vRandomOffset
        local hBird = CreateUnitByName("npc_beastmaster_bird", vSpawnArea, true, nil, nil, DOTA_TEAM_BADGUYS)
    
        -- find a random space and spawn the bear
        FindClearSpaceForUnit( hBird, vSpawnArea, true )

        -- spawn bear effects
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_summon_wolves_cast.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        ParticleManager:ReleaseParticleIndex(  ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, hBird ) )
    
    end
end
