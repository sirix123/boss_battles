
change_to_phase_2 = class({})
--------------------------------------------------------------------------------

function change_to_phase_2:OnSpellStart() 

    if IsServer() then
        local caster = self:GetCaster()

    end
end

function change_to_phase_2:OnChannelFinish()

    local caster = self:GetCaster()
    FindClearSpaceForUnit(caster, Vector(0,0,0), true)
    caster:SetAngles(0, 0, 0)

end
