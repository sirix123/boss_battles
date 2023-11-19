space_chain_hook = class({})
LinkLuaModifier("space_chain_hook_modifier", "player/warlord/modifiers/space_chain_hook_modifier", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier( "q_conq_shout_modifier", "player/warlord/modifiers/q_conq_shout_modifier", LUA_MODIFIER_MOTION_NONE )

function space_chain_hook:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function space_chain_hook:OnAbilityPhaseInterrupted()
    if IsServer() then
        caster:FindAbilityByName("m2_sword_slam"):SetActivated(true)
        caster:FindAbilityByName("q_conq_shout"):SetActivated(true)
        caster:FindAbilityByName("e_warlord_shout"):SetActivated(true)
        caster:FindAbilityByName("r_blade_vortex"):SetActivated(true)
        caster:FindAbilityByName("space_chain_hook"):SetActivated(true)

    end
end
---------------------------------------------------------------------------

function space_chain_hook:OnSpellStart()
    if IsServer() then

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        caster:FindAbilityByName("m2_sword_slam"):SetActivated(false)
        caster:FindAbilityByName("q_conq_shout"):SetActivated(false)
        caster:FindAbilityByName("e_warlord_shout"):SetActivated(false)
        caster:FindAbilityByName("r_blade_vortex"):SetActivated(false)
        caster:FindAbilityByName("space_chain_hook"):SetActivated(false)

        self:GetCaster():EmitSound("Hero_Pudge.AttackHookRetract")

        self.point = self:GetCursorTarget():GetAbsOrigin()

        local direction = (self.point - origin):Normalized()
        direction.z = 0

        self.speed = self:GetSpecialValueFor( "speed" )
        local distance = (self.point - origin):Length2D()--1000
        self.duration = (distance/self.speed) *2
        local position = self:GetCaster():GetAbsOrigin() + direction * distance

        local particle = "particles/warlord/warlord_rattletrap_hookshot.vpcf"
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
        -- CP0 starting point
        ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", origin, true)
        -- for clock attach_weapon attach_attack2 (for TA)
        -- CP1 point the hook will travel to
        ParticleManager:SetParticleControl(nfx, 1, position)
        -- CP2 speed 
        ParticleManager:SetParticleControl(nfx, 2, Vector(self.speed, 1, 1))
        -- CP3 duration
        ParticleManager:SetParticleControl(nfx, 3, Vector(self.duration, 1, 1))

        self.latch_radius = self:GetSpecialValueFor( "latch_radius" )

        local projectile = {
            Ability				= self,
            -- EffectName			= "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", -- Doesn't do anything
            vSpawnOrigin		= origin,
            fDistance			= distance,
            fStartRadius		= latch_radius,
            fEndRadius			= latch_radius,
            Source				= self:GetCaster(),
            bHasFrontalCone		= false,
            bReplaceExisting	= false,
            iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            fExpireTime 		= GameRules:GetGameTime() + 10.0,
            bDeleteOnHit		= true,
            vVelocity			= direction * self.speed * Vector(1, 1, 0),
            bProvidesVision		= false,
        }

        self.projectile = ProjectileManager:CreateLinearProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------

function space_chain_hook:OnProjectileHit(hTarget, vLocation)
    if IsServer() then

        EmitSoundOnLocationWithCaster(vLocation, "Hero_Pudge.AttackHookRetractStop", self:GetCaster())

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "space_chain_hook_modifier",
            {
                duration = self.duration,
                target_x = vLocation.x,
                target_y = vLocation.y,
                target_z = vLocation.z,
                latch_radius = self.latch_radius,
                speed = self.speed
            })


            self:GetCaster():ManaOnHit( 15 )

    end
end
