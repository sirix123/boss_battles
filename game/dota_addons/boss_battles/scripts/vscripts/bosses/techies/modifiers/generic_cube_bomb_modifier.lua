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
	return false
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

    ParticleManager:DestroyParticle(self.nFXIndex_2,true)
    ParticleManager:DestroyParticle(self.particleNfx,true)

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
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, unit in pairs(units) do
            if unit:HasModifier("generic_cube_bomb_modifier") ~= true then
                local damageInfo =
                {
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage = 50,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                }

                ApplyDamage( damageInfo )
            end
        end
    end
end
--------------------------------------------------------------------------------

function generic_cube_bomb_modifier:OnIntervalThink()
    if not IsServer() then return end

    -- get diffuse location
    if self.bHasDiffuseLocation == false then
        self.target = self.random_diffuse_locations[RandomInt(1, #self.random_diffuse_locations)]
        self.bHasDiffuseLocation = true
    end

    -- draw arrow to diffuse location
    self.distance = ( ( self.target - self:GetParent():GetAbsOrigin() ):Normalized() ) * 250
    self.vTargetPos = self.distance
    ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetParent():GetAbsOrigin()) -- origin
    ParticleManager:SetParticleControl(self.particleNfx , 2, self:GetParent():GetAbsOrigin() + self.distance)  -- target

    -- check if close to diffuse location
    if ( self.target - self:GetParent():GetAbsOrigin() ):Length2D() <= 50 then
        self.removed_flag = true
        self:Destroy()
    end
end

--------------------------------------------------------------------------------