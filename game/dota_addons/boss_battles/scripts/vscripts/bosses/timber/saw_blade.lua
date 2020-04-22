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

local main_ability_name = "saw_blade"
local main_ability_level = 1 --probably a way to get this value from the api instead of tracking it myself
local sub_ability_name = "return_saw_blades"

saw_blade = class({})

-- sub ability
saw_blade.sub_name = "return_saw_blades"


function saw_blade:OnSpellStart()
    print("saw_blade OnSpellStart")
    print("self:GetAbilityName() = ", self:GetAbilityName())
    print("#tSummonedSawBlades = ", #tSummonedSawBlades)
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local mainAbility = caster:FindAbilityByName( main_ability_name ) 

    --Only ever AddAbility to a caster if they don't already have it
    local subAbility = caster:FindAbilityByName( sub_ability_name ) 
    if subAbility == nil then
        --caster doesn't know subAbility, need to learn it
        subAbility = caster:AddAbility( sub_ability_name )
        subAbility:SetLevel( 1 )
    else
        --ability already known
    end   

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
        caster:SwapAbilities(
            main_ability_name,
            sub_ability_name,
            false,
            true
        ) --weird api, first two params are two ability names, 3rd param useFirstSpell, 4th param useSecondSpell
    end
end
--------------------------------------------------------------------------------

return_saw_blades = class({})

function return_saw_blades:OnSpellStart()
    local caster = self:GetCaster()

    for _, v in pairs(tSummonedSawBlades) do
        if v and not v:IsNull() then
            v:ReturnChakram()
        end
    end

    --reset tSummonedSawBlades as they're no longer 'active' and are being returned
    tSummonedSawBlades = {} 

    --level up saw_blade 
    local mainAbility = caster:FindAbilityByName( main_ability_name ) 
    main_ability_level = main_ability_level + 1  --increment to next level
    mainAbility:SetLevel(main_ability_level)

    --Now that return_saw_blades has been cast swap spell back to normal saw blade spell
    caster:SwapAbilities(
        main_ability_name,
        sub_ability_name,
        true,
        false
    ) --weird api, first two params are two ability names, 3rd param useFirstSpell, 4th param useSecondSpell
end
--------------------------------------------------------------------------------

