generic_cube_bomb_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function generic_cube_bomb_modifier:IsHidden()
	return false
end

function generic_cube_bomb_modifier:IsDebuff()
	return true
end

function generic_cube_bomb_modifier:IsPurgable()
	return false
end

function generic_cube_bomb_modifier:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function generic_cube_bomb_modifier:OnCreated( kv )
    if not IsServer() then return end

    -- flag for diuffuse location
    self.bHasDiffuseLocation = false

    -- remove flag
    self.removed_flag = false

    -- start particle
    local particle = "particles/custom/sirix_mouse/range_finder_cone.vpcf"
    self.particleNfx = ParticleManager:CreateParticleForPlayer( particle, PATTACH_ABSORIGIN_FOLLOW , self:GetParent(), self:GetParent():GetPlayerOwner() )

    ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
    ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(70,70,0)) -- line width
    ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

    -- generic location to take this bomb
    self.random_diffuse_locations ={
        Vector(9017, 545, 130),
        Vector(9012, 1094, 130),
        Vector(9014, 1677, 130),
        Vector(9014, 2227, 130),
        Vector(9014, 2810, 130),
        Vector(9749, 2810, 130),
        Vector(10468, 2822, 130),
        Vector(11202, 2815, 130),
        Vector(11200, 2178, 130),
        Vector(11194, 1680, 130),
        Vector(11197, 1097, 130),
        Vector(11196, 494, 130),
        Vector(10696, 494, 130),
        Vector(10200, 494, 130),
        Vector(9691, 494, 130),
    }

    particle = "particles/techies/cube_techies_red.vpcf"
    --self.nFXIndex_2 = ParticleManager:CreateParticleForPlayer( particle, PATTACH_OVERHEAD_FOLLOW , self:GetParent(), self:GetParent():GetPlayerOwner() )
    self.nFXIndex_2 = ParticleManager:CreateParticle( particle, PATTACH_OVERHEAD_FOLLOW , self:GetParent())
    ParticleManager:SetParticleControlEnt( self.nFXIndex_2, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)

    self.random_location = self.random_diffuse_locations[RandomInt(1, #self.random_diffuse_locations)]

    local particleName_3 = "particles/clock/red_clock_npx_moveto_arrow.vpcf"
    self.pfx_3 = ParticleManager:CreateParticleForPlayer( particleName_3, PATTACH_WORLDORIGIN, self:GetParent(), self:GetParent():GetPlayerOwner() )
    ParticleManager:SetParticleControl( self.pfx_3, 0, self.random_location )

    self:StartIntervalThink(0.01)

end

function generic_cube_bomb_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function generic_cube_bomb_modifier:OnRemoved()
	if not IsServer() then return end
end

function generic_cube_bomb_modifier:OnDestroy()
    if not IsServer() then return end
    --print("does this run? onremove")
    --print("remove flag = ",self.removed_flag)
    --print("-------")

    if self.nFXIndex_2 then
        ParticleManager:DestroyParticle(self.nFXIndex_2,true)
    end

    if self.particleNfx then
        ParticleManager:DestroyParticle(self.particleNfx,true)
    end

    if self.pfx_3 then
        ParticleManager:DestroyParticle(self.pfx_3,true)
    end

    if self.removed_flag == true then
        local particle = "particles/techies/techies_remote_mine_detonate_embers_fizzle.vpcf"
        self.nFXIndex_1 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN , self:GetParent()  )
        ParticleManager:SetParticleControl(self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.nFXIndex_1, 1, Vector(100, 100, 500))
        ParticleManager:ReleaseParticleIndex(self.nFXIndex_1)
    end

    if self.removed_flag == false then

        EmitSoundOn("Hero_Techies.RemoteMine.Detonate", self:GetParent())

        local particle = "particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf"
        self.nFXIndex_1 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN , self:GetParent()  )
        ParticleManager:SetParticleControl(self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.nFXIndex_1, 1, Vector(300, 100, 500))
        ParticleManager:SetParticleControl(self.nFXIndex_1, 3, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(self.nFXIndex_1)

        local units = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),	-- int, your team number
            self:GetParent():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            8000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units ~= nil and #units ~= 0 then
            for _, unit in pairs(units) do
                if unit:GetUnitName() ~= self:GetParent():GetUnitName() then
                    self.speed = 600
                    local info = {
                        EffectName = "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast.vpcf",
                        Ability = self:GetAbility(),
                        iMoveSpeed = self.speed,
                        Source = self:GetParent(),
                        Target = unit,
                        bDodgeable = false,
                        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                        bProvidesVision = true,
                        iVisionTeamNumber = self:GetParent():GetTeamNumber(),
                        iVisionRadius = 300,
                    }

                    ProjectileManager:CreateTrackingProjectile( info )
                end
            end 
        end

    end
end
--------------------------------------------------------------------------------

function generic_cube_bomb_modifier:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then
            local particle_cast = "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_explosion.vpcf"
            --local sound_target = "Ability.FrostNova"

            -- Create Particle
            local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, hTarget )
            ParticleManager:SetParticleControl( effect_cast, 0, hTarget:GetAbsOrigin() )
            ParticleManager:SetParticleControl( effect_cast, 1, Vector( 150, 150, 150 ) )
            ParticleManager:SetParticleControl( effect_cast, 3, hTarget:GetAbsOrigin() )
            ParticleManager:ReleaseParticleIndex( effect_cast )

            -- Create Sound
            --EmitSoundOn( sound_target, hTarget )

            local damageInfo =
            {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = 200,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage( damageInfo )

            return true
        end
    end
end
------------------------------------------------------------------------------------------------

function generic_cube_bomb_modifier:OnIntervalThink()
    if not IsServer() then return end

    -- get diffuse location
    if self.bHasDiffuseLocation == false then
        self.target = self.random_location
        self.bHasDiffuseLocation = true
    end

    -- draw arrow to diffuse location
    self.distance = ( ( self.target - self:GetParent():GetAbsOrigin() ):Normalized() ) * 250
    self.vTargetPos = self.distance
    ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetParent():GetAbsOrigin()) -- origin
    ParticleManager:SetParticleControl(self.particleNfx , 2, self:GetParent():GetAbsOrigin() + self.distance)  -- target

    -- check if close to diffuse location
    if ( self.target - self:GetParent():GetAbsOrigin() ):Length2D() <= 150 then
        self.removed_flag = true
        self:Destroy()
    end
end

--------------------------------------------------------------------------------