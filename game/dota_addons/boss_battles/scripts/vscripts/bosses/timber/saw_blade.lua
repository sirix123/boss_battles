--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers


]]
LinkLuaModifier( "saw_blade_thinker", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "saw_blade_modifier", "bosses/timber/saw_blade_modifier", LUA_MODIFIER_MOTION_NONE )

-- table to keep track of thinkers and number of thinkers
-- need to keep track of these in the AI file 
local tSummonedSawBlades = {  }
local nMaxSawBlades = 5

saw_blade = class({})

-- sub ability
saw_blade.sub_name = "return_saw_blades"

function saw_blade:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

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

    -- check if sawblades is maxxed 
    if #tSummonedSawBlades == nMaxSawBlades then
        local sub = caster:AddAbility( self.sub_name )
        sub:SetLevel( 1 )
        caster:SwapAbilities(
            self:GetAbilityName(),
            self.sub_name,
            false,
            true
        )
        -- register each other
        self.modifier = modifier
        self.sub = sub
        sub.modifier = modifier
        modifier.sub = sub
    end
end
--------------------------------------------------------------------------------

return_saw_blades = class({})

function return_saw_blades:OnSpellStart()
    for _, v in pairs(tSummonedSawBlades) do
        if v and not v:IsNull() then
            v:ReturnChakram()
        end
    end
end
--------------------------------------------------------------------------------

