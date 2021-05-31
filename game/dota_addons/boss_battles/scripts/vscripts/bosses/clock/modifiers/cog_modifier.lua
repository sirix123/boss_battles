cog_modifier = class({})

function cog_modifier:IsHidden()
	return false
end

function cog_modifier:IsDebuff()
	return false
end

function cog_modifier:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function cog_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- create particle between caster and parent
        local particle_cast = "particles/clock/clock_stormspirit_electric_vortex.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self.caster )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self.caster:GetAbsOrigin() )
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            1,
            self:GetParent(),
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )

        --[[ buff particle
        self:AddParticle(
            self.effect_cast,
            true, -- bDestroyImmediately
            false, -- bStatusEffect
            -1, -- iPriority
            false, -- bHeroEffect
            false -- bOverheadEffect
        )]]

        self:StartIntervalThink(0.5)

	end
end
---------------------------------------------------------------------------

function cog_modifier:OnIntervalThink()
    if IsServer() then

        local units = FindUnitsInLine(
			self.caster:GetTeamNumber(),
			self.caster:GetAbsOrigin(),
			self.parent:GetAbsOrigin(),
			nil,
			100,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE)

        for _, unit in pairs(units) do
            --print("unitname ", unit:GetUnitName())
            self.damageTable = {
                victim = unit,
                attacker = self.parent,
                damage = 200,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self:GetAbility(),
            }

            ApplyDamage(self.damageTable)

        end

    end
end
---------------------------------------------------------------------------


function cog_modifier:OnDestroy( kv )
    if IsServer() then

        self:OnIntervalThink(-1)

        if self.effect_cast ~= nil then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

	end
end
---------------------------------------------------------------------------
