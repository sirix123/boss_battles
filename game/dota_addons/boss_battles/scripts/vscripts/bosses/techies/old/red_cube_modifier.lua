red_cube_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function red_cube_modifier:IsHidden()
	return false
end

function red_cube_modifier:IsDebuff()
	return true
end

function red_cube_modifier:IsPurgable()
	return false
end

function red_cube_modifier:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function red_cube_modifier:OnCreated( kv )
    if not IsServer() then return end

    self.original_vision_night = self:GetParent():GetBaseNightTimeVisionRange()
    self.original_vision_day = self:GetParent():GetBaseDayTimeVisionRange()

    self:GetParent():SetNightTimeVisionRange(1)
    self:GetParent():SetDayTimeVisionRange(1)

    self.player = _G.red_player_bomb
    print("red bomb player = ", self.player:GetUnitName())

    local particle = "particles/techies/cube_techies_red.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticleForPlayer( particle, PATTACH_OVERHEAD_FOLLOW , self:GetParent(), self.player:GetPlayerOwner() )
    ParticleManager:SetParticleControlEnt( self.nFXIndex_2, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)

    self:StartIntervalThink(1)

    --print("red bomb duration remaining: ",self:GetRemainingTime())

end

function red_cube_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function red_cube_modifier:OnRemoved()
	if not IsServer() then return end

end

function red_cube_modifier:OnDestroy()
    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.nFXIndex_2,true)

    print("red cube destroyed ")

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
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        if unit:HasModifier("red_cube_diffuse_modifier") ~= true then
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
--------------------------------------------------------------------------------

function red_cube_modifier:OnIntervalThink()
    if not IsServer() then return end

    self:GetParent():SetNightTimeVisionRange(1)
    self:GetParent():SetDayTimeVisionRange(1)
end

--------------------------------------------------------------------------------