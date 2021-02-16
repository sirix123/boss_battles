green_cube_eater_modifier = class({})
-----------------------------------------------------------------------------

function green_cube_eater_modifier:RemoveOnDeath()
    return true
end

function green_cube_eater_modifier:OnCreated( kv )
    if IsServer() then
        self.thinkInterval = 2
        self:StartIntervalThink( self.thinkInterval )
    end
end
----------------------------------------------------------------------------

function green_cube_eater_modifier:OnDestroy()
	if not IsServer() then return end
end
----------------------------------------------------------------------------

function green_cube_eater_modifier:OnIntervalThink()
    if not IsServer() then return end

    local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		200,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    for _, cube in pairs(enemies) do
        if cube:GetUnitName() == "npc_rock_techies" then
            local particle = "particles/units/heroes/hero_rubick/rubick_chaos_meteor_cubes.vpcf"
            local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(nfx , 3, cube:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(nfx)
            cube:RemoveSelf()
        end
	end

end
