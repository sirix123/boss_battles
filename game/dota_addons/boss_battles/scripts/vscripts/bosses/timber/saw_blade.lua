--[[

    This script needs to handle the following: 
        Initial cast location 


]]
LinkLuaModifier( "saw_blade_thinker", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "saw_blade_modifier", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )


saw_blade = class({})

function saw_blade:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    -- need to create a table here to store each thinker.. they can't all use the same thinker...

    CreateModifierThinker(
        caster,
        self,
        "saw_blade_thinker",
        { 
            target_x = point.x,
			target_y = point.y,
			target_z = point.z,
        },
        caster:GetOrigin(),
        caster:GetTeamNumber(),
        false 
    )

    local sound_cast = "Hero_Shredder.Chakram.Cast"
	EmitSoundOn( sound_cast, caster )
end

