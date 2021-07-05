templar_m2_leap = class({})
LinkLuaModifier( "templar_power_charge", "player/templar/modifiers/templar_power_charge", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function templar_m2_leap:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        --- particle effect on cast
        local particle = "particles/econ/items/huskar/huskar_searing_dominator/huskar_searing_lifebreak_cast.vpcf"
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(nfx)

        -- emit sound
        EmitSoundOn( "Hero_Huskar.Life_Break", self:GetCaster() )

        return true
    end
end
---------------------------------------------------------------------------

function templar_m2_leap:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------
function templar_m2_leap:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

    self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    local caster = self:GetCaster()
    local point = nil
    point = Clamp(caster:GetAbsOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    local distance = (point - caster:GetAbsOrigin()):Length2D()

    if distance > 100 then

        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = point.x,
                target_y = point.y,
                distance = distance,
                speed = 1500,
                height = 200,
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        self.ember_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly_ember.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(self.ember_particle, 11, Vector(1, 0, 0))
        arc:AddParticle(self.ember_particle, false, false, -1, false, false)

        arc:SetEndCallback( function()
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
                caster:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if enemies~=nil and #enemies~=0 then

                -- grant power chage
                self:GetCaster():AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "templar_power_charge", -- modifier name
                    {duration = -1} -- kv
                )

                for _,enemy in pairs(enemies) do
                    damageTable.victim = enemy
                    ApplyDamage(damageTable)
                end
            end

            -- particle effect
            local particle = "particles/units/heroes/hero_mars/mars_debut_ground_impact.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_cast)

            local particle_1 = "particles/units/heroes/hero_mars/mars_debut_shieldbash.vpcf"
            local effect_cast_1 = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(effect_cast_1, 1, self:GetCaster():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_cast_1)

            -- slam sound
            EmitSoundOn( "Hero_Zuus.LightningBolt", self:GetCaster() )

        end)
    else
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
            caster:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies~=nil and #enemies~=0 then

            -- grant power chage
            self:GetCaster():AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "templar_power_charge", -- modifier name
                {duration = -1} -- kv
            )

            for _,enemy in pairs(enemies) do
                damageTable.victim = enemy
                ApplyDamage(damageTable)
            end
        end

        -- particle effect
        local particle = "particles/units/heroes/hero_mars/mars_debut_ground_impact.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        local particle_1 = "particles/units/heroes/hero_mars/mars_debut_shieldbash.vpcf"
        local effect_cast_1 = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast_1, 1, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast_1)

        -- slam sound
        EmitSoundOn( "Hero_Zuus.LightningBolt", self:GetCaster() )
    
    end

end
--------------------------------------------------------------------------------
