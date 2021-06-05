r_explosive_arrow = class({})
LinkLuaModifier( "r_explosive_arrow_modifier", "player/ranger/modifiers/r_explosive_arrow_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "r_explosive_arrow_thinker_indicator", "player/ranger/modifiers/r_explosive_arrow_thinker_indicator", LUA_MODIFIER_MOTION_NONE )


function r_explosive_arrow:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.8)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(), --self:GetDuration()
        })

        return true
    end
end
---------------------------------------------------------------------------
function r_explosive_arrow:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

---------------------------------------------------------------------------

function r_explosive_arrow:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_explosive_arrow:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        local caster = self:GetCaster()
		local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)

		caster:FindAbilityByName("m1_trackingshot"):SetActivated(false)
        caster:FindAbilityByName("m2_serratedarrow"):SetActivated(false)
        caster:FindAbilityByName("q_healing_arrow_v2"):SetActivated(false)
        caster:FindAbilityByName("e_whirling_winds"):SetActivated(false)
        caster:FindAbilityByName("space_sprint"):SetActivated(false)

        -- load data
	    local duration = self:GetDuration()

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "r_explosive_arrow_modifier", -- modifier name
            {
                duration = duration,
                pos_x = point.x,
                pos_y = point.y,
            } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------

function r_explosive_arrow:OnProjectileHit( target, location )
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
function r_explosive_arrow:PlayEffects( loc )
	-- Get Resources
	--local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced_explosion.vpcf"

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