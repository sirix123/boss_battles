
summon_bear = class({})

--------------------------------------------------------------------------------

function summon_bear:OnSpellStart()
    if IsServer() then
        local nBearSpawns = 1

        EmitSoundOn("lone_druid_lone_druid_spawn_01", self:GetCaster())
        
        for i = 0, nBearSpawns do
            if #self:GetCaster().BEAST_MASTER_SUMMONED_BEARS < self:GetCaster().MAX_BEARS then
                local vRandomOffset = Vector( RandomInt( -100, 100 ), RandomInt( -100, 100 ), 0 )
                local vSpawnArea = self:GetCaster():GetAbsOrigin() + vRandomOffset
                local hBear = CreateUnitByName("npc_beastmaster_bear", vSpawnArea, true, nil, nil, DOTA_TEAM_BADGUYS)
            
                -- sets intial waypoint for the unit 
                hBear:SetInitialGoalEntity( self:GetCaster():GetInitialGoalEntity() )
                table.insert( self:GetCaster().BEAST_MASTER_SUMMONED_BEARS, hBear )

                -- find a random space and spawn the bear
                FindClearSpaceForUnit( hBear, vSpawnArea, true )

                -- spawn bear effects
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_summon_wolves_cast.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
                ParticleManager:ReleaseParticleIndex(  ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, hBear ) )
            end
        end
	end
end
