r_remnant = class({})
LinkLuaModifier( "r_remnant_modifier", "player/fire_mage/modifiers/r_remnant_modifier", LUA_MODIFIER_MOTION_NONE )

function r_remnant:OnAbilityPhaseStart()
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

function r_remnant:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_remnant:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        local caster = self:GetCaster()

        local vTargetPos = nil
        vTargetPos = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        local unit = CreateUnitByName("npc_lina_remant", vTargetPos, true, caster, caster, DOTA_TEAM_NEUTRALS)
        --unit:SetOwner(caster)
        unit:EmitSound("Hero_EmberSpirit.FireRemnant.Activate")
        unit:SetRenderColor(255, 0, 0)

        unit:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 1.0)

        local particle = "particles/units/heroes/hero_invoker_kid/invoker_kid_debut_spawn_embers.vpcf"
        local effect_cast = ParticleManager:CreateParticleForTeam( particle, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
        ParticleManager:SetParticleControl( effect_cast, 0, vTargetPos )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        unit:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "r_remnant_modifier", -- modifier name
            { duration = self:GetSpecialValueFor( "duration" ) } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------