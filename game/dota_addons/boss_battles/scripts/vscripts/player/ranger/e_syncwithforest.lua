e_syncwithforest = class({})
LinkLuaModifier( "e_syncwithforest_modifier", "player/ranger/modifiers/e_syncwithforest_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "e_syncwithforest_modifier_enemy", "player/ranger/modifiers/e_syncwithforest_modifier_enemy", LUA_MODIFIER_MOTION_NONE )

function e_syncwithforest:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_syncwithforest:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_syncwithforest:OnSpellStart()
    if IsServer() then
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

        -- init
        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()

        local sound_cast = "windrunner_wind_ability_focusfire_02"
        EmitSoundOn( sound_cast, self.caster )

        self.projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        self.duration = self:GetSpecialValueFor( "duration" )
        self.radius = self:GetSpecialValueFor( "radius" )

        local projectile_name = "particles/ranger/ranger_sync_alchemist_smooth_criminal_unstable_concoction_projectile.vpcf"
        local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
        local projectile_start_radius = 80
        local projectile_end_radius = 80
        local projectile_vision = 400

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = PlayerManager.mouse_positions[self.caster:GetPlayerID()]
        local projectile_direction = (Vector( vTargetPos.x - self.origin.x, vTargetPos.y - self.origin.y, 0 )):Normalized()

        -- calc proj distance
        local projectile_distance = Vector( vTargetPos.x - self.origin.x, vTargetPos.y - self.origin.y, 0 ):Length2D()

        local info = {
            Source = self.caster,
            Ability = self,
            vSpawnOrigin = self.caster:GetOrigin() + Vector(0, 0, 100),
            bDeleteOnHit = false,
            EffectName = projectile_name,
            fDistance = projectile_distance,
            fStartRadius = projectile_start_radius,
            fEndRadius = projectile_end_radius,
            vVelocity = projectile_direction * projectile_speed,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            bProvidesVision = true,
            iVisionRadius = projectile_vision,
            iVisionTeamNumber = self.caster:GetTeamNumber(),
        }
        ProjectileManager:CreateLinearProjectile(info)

    end
end
---------------------------------------------------------------------------

function e_syncwithforest:OnProjectileHit( hTarget,  vLocation)
    if IsServer() then

        local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, vLocation, nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        for _, target in pairs(targets) do
            if target:GetTeam() == DOTA_TEAM_GOODGUYS then
                target:AddNewModifier(self.caster, self, "e_syncwithforest_modifier", { duration = self.duration })
            else
                target:AddNewModifier(self.caster, self, "e_syncwithforest_modifier_enemy", { duration = self.duration })
            end
        end

        -- effect neded for explode flask

        -- splash/break sound

    end
end
