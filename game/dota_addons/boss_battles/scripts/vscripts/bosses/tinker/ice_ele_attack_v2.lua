ice_ele_attack_v2 = class({})
LinkLuaModifier( "circle_target_iceshot", "bosses/tinker/modifiers/circle_target_iceshot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ice_ele_attack_v2_modifier", "bosses/tinker/modifiers/ice_ele_attack_v2_modifier", LUA_MODIFIER_MOTION_NONE )

function ice_ele_attack_v2:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_IDLE_RARE, 2.0)
        return true
    end
end

function ice_ele_attack_v2:OnSpellStart()
	if IsServer() then

		self:GetCaster():RemoveGesture(ACT_DOTA_IDLE_RARE)

		-- load data
		local duration = self:GetDuration()

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local caster = self:GetCaster()

		-- add modifier
		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"ice_ele_attack_v2_modifier", -- modifier name
			{
				duration = duration,
				pos_x = vPos.x,
				pos_y = vPos.y,
			} -- kv
		)

	end
end

--------------------------------------------------------------------------------

function ice_ele_attack_v2:OnProjectileHit( target, location )
	if not target then return end

	local damage = self:GetSpecialValueFor( "damage" )
	local radius = self:GetSpecialValueFor( "radius" )

	local damageTable = {
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end

	-- play effects
	self:PlayEffects( target:GetOrigin() )
end

--------------------------------------------------------------------------------
function ice_ele_attack_v2:PlayEffects( loc )
	-- Get Resources
	--local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/tinker/ice_snapfire_lizard_blobs_arced_explosion.vpcf"

	-- Create Particle
	--local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	--ParticleManager:SetParticleControl( effect_cast, 3, loc )
	--ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, self:GetCaster() )
end