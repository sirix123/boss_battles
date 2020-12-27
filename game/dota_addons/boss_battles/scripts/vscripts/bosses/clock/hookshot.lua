hookshot = class({})
LinkLuaModifier("clock_hookshot_modifier", "bosses/clock/modifiers/clock_hookshot_modifier", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "stunned_modifier", "player/generic/stunned_modifier", LUA_MODIFIER_MOTION_NONE )

--[[function hookshot:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RATTLETRAP_HOOKSHOT_START, 1.2)

        self.units = FindUnitsInRadius(
            DOTA_TEAM_BADGUYS,
            self:GetCaster():GetAbsOrigin(),
            nil,
            2500,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )

        if self.units == nil or #self.units == 0 then
            return false
        else

            self.vTargetPos = self.units[RandomInt(1, #self.units)]:GetAbsOrigin()

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            self:GetCaster():EmitSound("rattletrap_ratt_ability_hook_03")

            return true
        end
    end
end]]
---------------------------------------------------------------------------------------------------------------------------------------

function hookshot:OnAbilityPhaseStart()
    if IsServer() then

		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RATTLETRAP_HOOKSHOT_START, 1.2)

		EmitSoundOn( "rattletrap_ratt_ability_hook_03", self:GetCaster() )

		self.target = self:GetCursorTarget()
		self.vTargetPos = self.target:GetAbsOrigin()
 		if self.vTargetPos == nil then
 			return false
 		end

		self:GetCaster():SetForwardVector(self.vTargetPos)
		self:GetCaster():FaceTowards(self.vTargetPos)

        return true
    end
end
---------------------------------------------------------------------------

function hookshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_RATTLETRAP_HOOKSHOT_START)

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Fire")

        EmitSoundOn("rattletrap_ratt_ability_hook_02", caster)

        self.point = self.vTargetPos

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

function hookshot:OnProjectileHit(hTarget, vLocation)
    if IsServer() then

        EmitSoundOnLocationWithCaster(vLocation, "Hero_Rattletrap.Hookshot.Impact", self:GetCaster())
        -- add modifier to clock to move him to target (this modifier should be destroyed once clock has hit the target (trigger push back))
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "clock_hookshot_modifier",
            {
                duration = self.duration,
                target_x = vLocation.x,
                target_y = vLocation.y,
                target_z = vLocation.z,
                latch_radius = self.latch_radius,
                speed = self.speed
            })

        local targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            vLocation,
            nil,
            300,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            0,
            false
        )

        -- initial hit 
        for _, target in pairs(targets) do
            local dmgTable =
            {
                victim = target,
                attacker = self:GetCaster(),
                damage = 150,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)
        end
    end
end
