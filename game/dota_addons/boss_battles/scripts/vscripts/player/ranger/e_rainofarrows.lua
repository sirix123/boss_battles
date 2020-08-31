e_rainofarrows = class({})
LinkLuaModifier( "e_rainofarrows_thinker", "player/ranger/modifiers/e_rainofarrows_thinker", LUA_MODIFIER_MOTION_NONE )

function e_rainofarrows:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_rainofarrows:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
--------------------------------------------------------------------------------

function e_rainofarrows:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
function e_rainofarrows:OnSpellStart()

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor( "duration" )

	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"e_rainofarrows_thinker", -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)

	-- play effects
	local sound_cast = "Hero_SkywrathMage.MysticFlare.Cast"
	EmitSoundOn( sound_cast, caster )

end