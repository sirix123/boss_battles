primal_cave_in = class({})

LinkLuaModifier("cone_smash_rocks_modifier", "bosses/primalbeast/modifiers/cone_smash_rocks_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "primal_circle_target_iceshot", "bosses/primalbeast/modifiers/primal_circle_target_iceshot", LUA_MODIFIER_MOTION_NONE )

function primal_cave_in:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.20)

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = self:GetCastPoint() + self:GetSpecialValueFor( "duration" ) } )

        EmitSoundOn("beastmaster_beast_attack_12", self:GetCaster())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function primal_cave_in:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)

        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx,true)
        end

    end
end
---------------------------------------------------------------------------

function primal_cave_in:OnSpellStart()
    if not IsServer() then return end

    -- self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    local caster = self:GetCaster()
    local origin = self:GetCaster():GetAbsOrigin()
    local duration = self:GetSpecialValueFor( "duration" )
    local count = 0

    local radius = 4500
    local rocks_per_wave = 12

    Timers:CreateTimer(function()
        if IsValidEntity(caster) == false then
            if self.particleNfx then
                ParticleManager:DestroyParticle(self.particleNfx,true)
            end
            return false
        end

        if count == duration then
            if self.particleNfx then
                ParticleManager:DestroyParticle(self.particleNfx,true)
            end
            return false
        end

        for i = 1, rocks_per_wave, 1 do
            local x = RandomInt(origin.x - radius, origin.x + radius)
            local y = RandomInt(origin.y - radius, origin.y + radius)
            local point = Vector(x,y,origin.z)
    
            -- spawn modifier that is the cave in thing
            CreateModifierThinker(
                caster,
                self,
                "cone_smash_rocks_modifier",
                {
                    duration = self:GetSpecialValueFor( "rock_fall_delay" ),
                    radius = self:GetSpecialValueFor( "radius" ),
                    damage = self:GetSpecialValueFor( "dmg" ),
                },
                point,
                caster:GetTeamNumber(),
                false
            )

            CreateModifierThinker(
                caster, -- player source
                self, -- ability source
                "primal_circle_target_iceshot", -- modifier name
                {
                    duration = self:GetSpecialValueFor( "rock_fall_delay" ),
                    radius = self:GetSpecialValueFor( "radius" ),
                },
                point,
                caster:GetTeamNumber(),
                false
            )

        end

        -- local random_angle = RandomInt(1,360)

        -- -- shoot projs out randomly that either net or stun
        -- local projectile = {
        --     EffectName = "particles/clock/primal_vengeful_magic_missle.vpcf",
        --     vSpawnOrigin = origin + Vector(0,0,80),
        --     fDistance = 9000,
        --     fUniqueRadius = 80,--200
        --     Source = caster,
        --     vVelocity = ( RotatePosition(Vector(0,0,0), QAngle(0,random_angle,0), Vector(1,0,0)) )  * 800,
        --     UnitBehavior = PROJECTILES_DESTROY,
        --     TreeBehavior = PROJECTILES_NOTHING,
        --     WallBehavior = PROJECTILES_DESTROY,
        --     GroundBehavior = PROJECTILES_NOTHING,
        --     fGroundOffset = 80,
        --     UnitTest = function(_self, unit)
        --         return unit:GetTeamNumber() ~= casterTeamNumber and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
        --     end,
        --     OnUnitHit = function(_self, unit)
        --         local dmgTable = {
        --             victim = unit,
        --             attacker = caster,
        --             damage = 50,
        --             damage_type = self:GetAbilityDamageType(),
        --             ability = self,
        --         }

        --         ApplyDamage(dmgTable)

        --         unit:AddNewModifier(
        --             unit, -- player source
        --             self, -- ability source
        --             "modifier_rooted", -- modifier name
        --             {
        --                 duration = 3,
        --             } -- kv
        --         )

        --         self:Effect(unit:GetAbsOrigin())
        --     end,
        --     OnFinish = function(_self, pos)
        --         self:Effect(pos)
        --     end,
        -- }

        -- Projectiles:CreateProjectile(projectile)

        count = count + 0.5
        return 0.5
    end)
end

function primal_cave_in:Effect(pos)
    if IsServer() then
        -- add projectile explode particle effect here on the pos it finishes at
        local particle_cast = "particles/clock/clock_vengeful_magic_missle_end.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 3, pos)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
end