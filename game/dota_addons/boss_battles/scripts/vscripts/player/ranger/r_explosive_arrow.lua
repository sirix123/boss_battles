r_explosive_arrow = class({})
LinkLuaModifier( "r_explosive_arrow_modifier", "player/ranger/modifiers/r_explosive_arrow_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "r_explosive_arrow_thinker_indicator", "player/ranger/modifiers/r_explosive_arrow_thinker_indicator", LUA_MODIFIER_MOTION_NONE )


function r_explosive_arrow:OnAbilityPhaseStart()
    if IsServer() then

		self.point = nil
        --self.point = Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)
        self.point = Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z)

        if ( (self:GetCaster():GetAbsOrigin() - self.point):Length2D() ) > self:GetCastRange(Vector(0,0,0), nil) then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "out_of_range", { } )
            return false
        end

        local animation_sequence = nil
        if self:GetCaster():HasModifier("modifier_hero_movement") == true then
            animation_sequence = "focusfire"
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RUN, 1.0)

            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker_windrunner_focusfire",
            {
                duration = self:GetCastPoint(),
            })
        else
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.3)
        end

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
            animation_sequence = animation_sequence,
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
                pos_x = self.point.x,
                pos_y = self.point.y,
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