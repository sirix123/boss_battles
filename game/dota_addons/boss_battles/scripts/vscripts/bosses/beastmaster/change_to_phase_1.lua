
change_to_phase_1 = class({})
--------------------------------------------------------------------------------

function change_to_phase_1:OnSpellStart() 
    if IsServer() then
        local caster = self:GetCaster()

    end
end

function change_to_phase_1:OnChannelFinish()

    local caster = self:GetCaster()
    FindClearSpaceForUnit(caster, Vector(13212,14902,256), true)
    caster:SetAngles(0, 0, 0)

end
