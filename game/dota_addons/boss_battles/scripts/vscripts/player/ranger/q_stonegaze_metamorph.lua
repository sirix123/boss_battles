q_stonegaze_metamorph = class({})
LinkLuaModifier( "q_stonegaze_metamorph_modifier", "player/ranger/modifiers/q_stonegaze_metamorph_modifier", LUA_MODIFIER_MOTION_NONE )

function q_stonegaze_metamorph:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()

	-- Add modifier
	self.modifier = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"q_stonegaze_metamorph_modifier", -- modifier name
		{ duration = self:GetChannelTime() } -- kv
	)
end

function q_stonegaze_metamorph:OnChannelFinish( bInterrupted )
	if self.modifier then
		self.modifier:Destroy()
		self.modifier = nil
	end
end


--[[
function q_stonegaze_metamorph:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_1, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
        })

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "q_stonegaze_metamorph_modifier", {duration = self:GetSpecialValueFor( "duration")})

        return true
    end
end
---------------------------------------------------------------------------

function q_stonegaze_metamorph:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_stonegaze_metamorph:OnSpellStart()
    if IsServer() then
        self:GetCaster():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
        self.caster = self:GetCaster()
    end
end]]