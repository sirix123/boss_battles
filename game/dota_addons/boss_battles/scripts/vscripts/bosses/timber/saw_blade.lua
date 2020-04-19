--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers


]]
LinkLuaModifier( "saw_blade_thinker", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "saw_blade_modifier", "bosses/timber/saw_blade_modifier", LUA_MODIFIER_MOTION_NONE )

-- table to keep track of thinkers and number of thinkers
local tSawBlades = {  }
local nMaxSawBlades = 100

saw_blade = class({})

function saw_blade:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    print("number of saw blades in table = ", #tSawBlades)
    print("number of saw blades in table = ", nMaxSawBlades)

    if #tSawBlades < nMaxSawBlades then
        local thinkerSawBlade = CreateModifierThinker(
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

        table.insert( tSawBlades, thinkerSawBlade )
    
        local sound_cast = "Hero_Shredder.Chakram.Cast"
        EmitSoundOn( sound_cast, caster )
    end
end

