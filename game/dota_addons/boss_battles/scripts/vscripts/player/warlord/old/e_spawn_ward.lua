e_spawn_ward = class({})
LinkLuaModifier( "e_spawn_ward_thinker", "player/warlord/modifiers/e_spawn_ward_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "e_spawn_ward_buff", "player/warlord/modifiers/e_spawn_ward_buff", LUA_MODIFIER_MOTION_NONE )

function e_spawn_ward:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_spawn_ward:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_spawn_ward:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("radius")

        local vTargetPos = nil
        vTargetPos = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        -- sound effect
        caster:EmitSound("Hero_Juggernaut.HealingWard.Cast")

        caster:AddNewModifier(caster, self, "e_spawn_ward_thinker", {duration = self:GetSpecialValueFor( "duration" )})

        --[[CreateModifierThinker(
            caster,
            self,
            "e_spawn_ward_thinker",
            {
                duration = self:GetSpecialValueFor( "duration" ),
                target_x = vTargetPos.x,
                target_y = vTargetPos.y,
                target_z = vTargetPos.z,
            },
            vTargetPos,
            caster:GetTeamNumber(),
            false
        )]]

    end
end
---------------------------------------------------------------------------

