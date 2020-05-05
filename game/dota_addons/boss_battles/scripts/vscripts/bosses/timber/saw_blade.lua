--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers


]]
LinkLuaModifier( "saw_blade_thinker", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "saw_blade_modifier", "bosses/timber/saw_blade_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "saw_blade_return", "bosses/timber/saw_blade_return", LUA_MODIFIER_MOTION_NONE )

-- table to keep track of thinkers and number of thinkers
-- need to keep track of these in the AI file 
local tSummonedSawBlades = {  }
local nMaxSawBlades = 5

saw_blade = class({})

function saw_blade:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    	-- play random sound effect on cast
	local tSoundEffects =
	{
		"shredder_timb_attack_03",
		"shredder_timb_attack_04",
		"shredder_timb_attack_06",
    }

    EmitSoundOn(tSoundEffects[ RandomInt( 1, #tSoundEffects ) ], caster)

    if #tSummonedSawBlades < nMaxSawBlades then
        self.thinkerSawBlade = CreateModifierThinker(
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

    table.insert(tSummonedSawBlades,  self.thinkerSawBlade:FindModifierByName( "saw_blade_thinker" ))
    local modifier = self.thinkerSawBlade:FindModifierByName( "saw_blade_thinker" )
end
--------------------------------------------------------------------------------


