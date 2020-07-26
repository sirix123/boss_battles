hookshot = class({})
LinkLuaModifier("clock_hookshot_modifier", "bosses/clock/modifiers/clock_hookshot_modifier", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "stunned_modifier", "player/generic/stunned_modifier", LUA_MODIFIER_MOTION_NONE )

function hookshot:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RATTLETRAP_HOOKSHOT_START, 1.2)
        --ACT_DOTA_RATTLETRAP_HOOKSHOT_START ACT_DOTA_ATTACK

        return true
    end
end
---------------------------------------------------------------------------

function hookshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Fire")

        -- find cloest enemy unit
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            origin,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies == nil then
            return
        end

        EmitSoundOn("rattletrap_ratt_ability_hook_02", caster)

        self.point = enemies[1]:GetAbsOrigin()

        local direction = (self.point - origin):Normalized()
        direction.z = 0

        self.speed = self:GetSpecialValueFor( "speed" )
        local distance = (self.point - origin):Length2D()--1000
        self.duration = (distance/self.speed) *2
        local position = self:GetCaster():GetAbsOrigin() + direction * distance

        local particle = "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf"
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
        -- CP0 starting point
        ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon", origin, true)
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
            iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_BOTH,
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

function hookshot:OnProjectileHit(hTarget, vLocation)
    if IsServer() then
        if hTarget then

            hTarget:EmitSound("Hero_Rattletrap.Hookshot.Impact")

            -- add modifier to clock to move him to target (this modifier should be destroyed once clock has hit the target (trigger push back))
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "clock_hookshot_modifier",
                {
                    duration = self.duration,
                    target = hTarget:GetEntityIndex(),
                    latch_radius = self.latch_radius,
                    speed = self.speed
                })

        end
    end
end
