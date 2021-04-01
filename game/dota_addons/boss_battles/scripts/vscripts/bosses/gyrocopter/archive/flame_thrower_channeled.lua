flame_thrower = class({})
LinkLuaModifier( "turn_rate_modifier", "bosses/techies/modifiers/turn_rate_modifier", LUA_MODIFIER_MOTION_NONE )

function flame_thrower:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.4)

        self:GetCaster():AddNewModifier( nil, nil, "turn_rate_modifier", { duration = -1 })

        self.create_particle = true

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            1200,
            DOTA_TEAM_BADGUYS,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false )

        if #enemies == 0 or enemies == nil then
            return false
        else
            self.target = enemies[RandomInt(1,#enemies)]

            -- chuck a target indicator on them

            return true
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function flame_thrower:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

        self:GetCaster():RemoveModifierByName("turn_rate_modifier")

        if self.nfx ~= nil then
            ParticleManager:DestroyParticle(self.nfx,true)
        end

    end
end
---------------------------------------------------------------------------

function flame_thrower:OnChannelFinish(bInterrupted)
	if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

        if self.nfx ~= nil then
            ParticleManager:DestroyParticle(self.nfx,true)
        end

        self:GetCaster():RemoveModifierByName("turn_rate_modifier")

	end
end

function flame_thrower:OnChannelThink( flinterval )
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self.caster = self:GetCaster()

    local radius = 280

    local caster_forward = ( self.target:GetAbsOrigin() - self.caster:GetAbsOrigin() ):Normalized()
    self:GetCaster():SetForwardVector( caster_forward )
    self:GetCaster():FaceTowards( caster_forward )

    if self.create_particle == true then
        local effect = "particles/gyrocopter/gyro_shredder_flame_thrower.vpcf"
        self.nfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControlEnt(self.nfx, 3, self.caster, PATTACH_ABSORIGIN_FOLLOW, "attach_missile", self.caster:GetAbsOrigin(), false)
        self.create_particle = false
    end

    self.time = (self.time or 0) + flinterval
    if self.time < 0.3 then
        return
    else
        -- find units in cone and hurt em
        local enemies = FindUnitsInCone(
            self.caster:GetTeamNumber(),
            self.caster:GetForwardVector(),
            self.caster:GetOrigin(),
            5,
            radius,
            1550,
            nil,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            FIND_ANY_ORDER,
            false)

        for _, enemy in pairs(enemies) do

            local dmgTable = {
                victim = enemy,
                attacker = self.caster,
                damage = 50,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)
        end

		self.time = 0
	end
end

function flame_thrower:OnSpellStart()
    if IsServer() then

        if not self:IsChanneling() then return end

	end
end