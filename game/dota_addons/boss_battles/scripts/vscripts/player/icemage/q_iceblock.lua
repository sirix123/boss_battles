q_iceblock = class({})
LinkLuaModifier("q_iceblock_modifier", "player/icemage/modifiers/q_iceblock_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bonechill_modifier", "player/icemage/modifiers/bonechill_modifier", LUA_MODIFIER_MOTION_NONE)

function q_iceblock:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
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

function q_iceblock:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_iceblock:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )
        local boneChillDuration = self:GetSpecialValueFor( "bone_chill_duration" )
        local target = self:GetCursorTarget()

        self.modifier = target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "q_iceblock_modifier", -- modifier name
            { duration = duration } -- kv
        )

        --[[if self.caster:FindModifierByNameAndCaster("bonechill_modifier", self.caster) then

            self.caster:RemoveModifierByNameAndCaster("bonechill_modifier", self.caster)

            target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "bonechill_modifier", -- modifier name
                { duration = boneChillDuration } -- kv
            )

        end]]

        self.caster:SwapAbilities("q_iceblock", "cancel_ice_block", false, true)

	end
end
----------------------------------------------------------------------------------------------------------------
