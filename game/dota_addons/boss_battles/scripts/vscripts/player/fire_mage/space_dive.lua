space_dive = class({})
LinkLuaModifier( "space_dive_modifier", "player/fire_mage/modifiers/space_dive_modifier", LUA_MODIFIER_MOTION_NONE )

function space_dive:OnAbilityPhaseStart()
    if IsServer() then
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function space_dive:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_dive:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        EmitSoundOn("Hero_Lina.ProjectileImpact", self:GetCaster())

        local caster = self:GetCaster()
        local point = nil
        point = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = point.x,
                target_y = point.y,
                distance = self:GetCastRange(Vector(0,0,0), nil),
                speed = 1500,
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        --[[self.firefly_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(self.firefly_particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.firefly_particle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.firefly_particle, 11, Vector(1, 0, 0))
        arc:AddParticle(self.firefly_particle, false, false, 0, false, false)]]

        self.ember_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly_ember.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(self.ember_particle, 11, Vector(1, 0, 0))
		arc:AddParticle(self.ember_particle, false, false, -1, false, false)

        arc:SetEndCallback( function()
            --ParticleManager:ReleaseParticleIndex(self.ember_particle)
            --ParticleManager:DestroyParticle(self.ember_particle,true)
        end)
	end
end
----------------------------------------------------------------------------------------------------------------