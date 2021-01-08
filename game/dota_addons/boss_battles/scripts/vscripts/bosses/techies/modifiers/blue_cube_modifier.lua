blue_cube_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function blue_cube_modifier:IsHidden()
	return false
end

function blue_cube_modifier:IsDebuff()
	return true
end

function blue_cube_modifier:IsPurgable()
	return false
end

function blue_cube_modifier:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function blue_cube_modifier:OnCreated( kv )
    if not IsServer() then return end

    self.original_vision_night = self:GetParent():GetBaseNightTimeVisionRange()
    self.original_vision_day = self:GetParent():GetBaseDayTimeVisionRange()

    self:GetParent():SetNightTimeVisionRange(150)
    self:GetParent():SetDayTimeVisionRange(150)

end

function blue_cube_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function blue_cube_modifier:OnRemoved()
	if not IsServer() then return end

end

function blue_cube_modifier:OnDestroy()
    if not IsServer() then return end

    self.original_vision_night = self:GetParent():SetNightTimeVisionRange(self.original_vision_night)
    self.original_vision_day = self:GetParent():SetDayTimeVisionRange(self.original_vision_day)

    EmitSoundOn("Hero_Techies.RemoteMine.Detonate", self:GetParent())

	local particle = "particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf"
	self.nFXIndex_1 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl(self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_1, 1, Vector(500, 1, 1))
	ParticleManager:SetParticleControl(self.nFXIndex_1, 3, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.nFXIndex_1)

    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        8000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        if unit:HasModifier("blue_cube_diffuse_modifier") ~= true then
            local damageInfo =
            {
                victim = unit,
                attacker = self:GetCaster(),
                damage = 300,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage( damageInfo )
        end
    end

end
--------------------------------------------------------------------------------

function blue_cube_modifier:OnIntervalThink()
    if not IsServer() then return end

end

--------------------------------------------------------------------------------
function blue_cube_modifier:GetEffectName()
	return "particles/techies/cube_techies_blue.vpcf"
end

function blue_cube_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end