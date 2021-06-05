blademaster_death_enable_spells = class({})

-----------------------------------------------------------------------------

function blademaster_death_enable_spells:IsHidden()
    return true
end

function blademaster_death_enable_spells:RemoveOnDeath()
    return false
end

function blademaster_death_enable_spells:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function blademaster_death_enable_spells:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function blademaster_death_enable_spells:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
end

function blademaster_death_enable_spells:OnDeath(event)
    if IsServer() then
        if event.unit:GetUnitName() == self:GetParent():GetUnitName() then
            print("does this run when he dies")
            self:GetParent():FindAbilityByName("m1_sword_slash"):SetActivated(true)
            self:GetParent():FindAbilityByName("m2_sword_slam"):SetActivated(true)
            self:GetParent():FindAbilityByName("q_conq_shout"):SetActivated(true)
            self:GetParent():FindAbilityByName("e_warlord_shout"):SetActivated(true)
            self:GetParent():FindAbilityByName("r_blade_vortex"):SetActivated(true)
            self:GetParent():FindAbilityByName("space_chain_hook"):SetActivated(true)
        end
    end
end


function blademaster_death_enable_spells:OnDestroy()
    if not IsServer() then return nil end

end

