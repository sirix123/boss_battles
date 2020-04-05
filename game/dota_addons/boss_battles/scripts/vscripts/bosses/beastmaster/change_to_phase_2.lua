
change_to_phase_2 = class({})
--------------------------------------------------------------------------------

PHASE_COUNT = 0

function change_to_phase_2:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        --local hSpell =  caster:FindAbilityByName("stampede")
        
        --PHASE_COUNT = PHASE_COUNT + 1
        --hSpell:SetLevel(PHASE_COUNT)
    end
end

function change_to_phase_2:OnChannelFinish()

    local caster = self:GetCaster()
    FindClearSpaceForUnit(caster, Vector(0,0,0), true)
    caster:SetAngles(0, 0, 0)

end
