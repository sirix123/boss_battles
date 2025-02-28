r_infest = class({})
LinkLuaModifier("r_infest_modifier", "player/rat/modifier/r_infest_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("r_infest_modifier_damage", "player/rat/modifier/r_infest_modifier_damage", LUA_MODIFIER_MOTION_NONE)


function r_infest:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function r_infest:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function r_infest:OnSpellStart()
    if IsServer() then

        self:GetCaster():EmitSound("Hero_Bristleback.ViscousGoo.Cast")

        -- init
        self.caster = self:GetCaster()

        local projectile =
        {
            Target 				= self:GetCursorTarget(),
            Source 				= self.caster,
            Ability 			= self,
            EffectName 			= "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf",
            iMoveSpeed 			= 1500,
            vSourceLoc			= self.caster:GetAbsOrigin(),
            bDrawsOnMinimap		= false,
            bDodgeable			= true,
            bIsAttack 			= false,
            bVisibleToEnemies	= true,
            bReplaceExisting 	= false,
            flExpireTime 		= GameRules:GetGameTime() + 10,
            bProvidesVision 	= false,
            iVisionRadius 		= 0,
            iVisionTeamNumber 	= self.caster:GetTeamNumber()
        }

        ProjectileManager:CreateTrackingProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------

function r_infest:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and hTarget:IsAlive() and not hTarget:IsMagicImmune() then

		hTarget:EmitSound("Hero_Bristleback.ViscousGoo.Target")

        local duration = self:GetSpecialValueFor( "duration" )

        hTarget:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "r_infest_modifier", -- modifier name
            {
                duration = duration,
                dot_duration = self:GetSpecialValueFor( "dot_duration" ),
            } -- kv
        )

        local particle = "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_nasal_goo_impact.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, hTarget:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, hTarget:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 3, hTarget:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

	end
end
