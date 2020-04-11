
summon_quillboar = class({})

--------------------------------------------------------------------------------

function summon_quillboar:OnSpellStart()
    if IsServer() then
        local nQuilboarSpawns = 3

        EmitSoundOn("lone_druid_lone_druid_kill_13", self:GetCaster())
        
        for i = 0, nQuilboarSpawns do
            if #self:GetCaster().BEAST_MASTER_SUMMONED_QUILBOARS < self:GetCaster().MAX_QUILBOARS then
                -- give quillboar spawn area
                local vRandomOffset = Vector( RandomInt( -1000, 1000 ), RandomInt( -1000, 1000 ), 0 )

                -- spawn area needs to be central to the map? maybe use a map entity?
                -- remember to do this ^^
                -- remember to do this ^^
                -- remember to do this ^^
                -- remember to do this ^^
                -- remember to do this ^^
                local vSpawnArea = self:GetCaster():GetAbsOrigin() + vRandomOffset
                local hQuillboar = CreateUnitByName("npc_quilboar", vSpawnArea, true, self:GetCaster(), self:GetCaster(), DOTA_TEAM_BADGUYS)

                -- sets intial waypoint for the unit 
                hQuillboar:SetInitialGoalEntity( self:GetCaster():GetInitialGoalEntity() )
                table.insert( self:GetCaster().BEAST_MASTER_SUMMONED_QUILBOARS, hQuillboar )

                -- find a random space and spawn the boar inside the spawn area
                FindClearSpaceForUnit( hQuillboar, vSpawnArea, true )

                -- spawn bear effects
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
                ParticleManager:SetParticleControl( nFXIndex, 0, vSpawnArea )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
            end
        end
	end
end
