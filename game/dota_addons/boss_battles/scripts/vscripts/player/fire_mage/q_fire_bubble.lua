q_fire_bubble = class({})
LinkLuaModifier( "q_fire_bubble_modifier", "player/fire_mage/modifiers/q_fire_bubble_modifier", LUA_MODIFIER_MOTION_NONE )

function q_fire_bubble:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()
        local find_radius = self:GetSpecialValueFor( "find_radius" )
        local vTargetPos = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            vTargetPos,
            nil,
            find_radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if #friendlies == 0 or friendlies == nil then
            return false
        end

        if #friendlies ~= 0 and friendlies ~= nil then

            -- start casting animation
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

            self.target = friendlies[1]

            -- add casting modifier
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
            })

            return true
        end
    end
end
---------------------------------------------------------------------------

function q_fire_bubble:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_fire_bubble:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        self.caster = self:GetCaster()

        local duration = self:GetSpecialValueFor( "duration" )

        self.target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "q_fire_bubble_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------