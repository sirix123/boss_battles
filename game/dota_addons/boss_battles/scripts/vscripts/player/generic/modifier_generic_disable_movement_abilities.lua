modifier_generic_disable_movement_abilities = class ({})

--- Misc 
function modifier_generic_disable_movement_abilities:IsHidden()
    return false
end

function modifier_generic_disable_movement_abilities:DestroyOnExpire()
    return true
end

function modifier_generic_disable_movement_abilities:IsPurgable()
    return false
end

function modifier_generic_disable_movement_abilities:RemoveOnDeath()
    return true
end

function modifier_generic_disable_movement_abilities:GetTexture()
    return "slark_dark_pact"
end


function modifier_generic_disable_movement_abilities:OnCreated( kv )
    if IsServer() then

        if self:GetParent():GetUnitName() == "npc_dota_hero_lina" then
            self:GetParent():FindAbilityByName("space_dive"):SetActivated(false)
        end
        if self:GetParent():GetUnitName() == "npc_dota_hero_crystal_maiden" then
            self:GetParent():FindAbilityByName("space_frostblink"):SetActivated(false)
        end
        if self:GetParent():GetUnitName() == "npc_dota_hero_juggernaut" then
            self:GetParent():FindAbilityByName("space_chain_hook"):SetActivated(false)
        end
        if self:GetParent():GetUnitName() == "npc_dota_hero_phantom_assassin" then
            self:GetParent():FindAbilityByName("space_shadowstep"):SetActivated(false)
            self:GetParent():FindAbilityByName("space_shadowstep_teleport"):SetActivated(false)
            self:GetParent():FindAbilityByName("space_shadowstep_teleport_back"):SetActivated(false)
        end
    end
end

function modifier_generic_disable_movement_abilities:OnDestroy( kv )
    if IsServer() then
        if self:GetParent():GetUnitName() == "npc_dota_hero_lina" then
            self:GetParent():FindAbilityByName("space_dive"):SetActivated(true)
        end
        if self:GetParent():GetUnitName() == "npc_dota_hero_crystal_maiden" then
            self:GetParent():FindAbilityByName("space_frostblink"):SetActivated(true)
        end
        if self:GetParent():GetUnitName() == "npc_dota_hero_juggernaut" then
            self:GetParent():FindAbilityByName("space_chain_hook"):SetActivated(true)
        end
        if self:GetParent():GetUnitName() == "npc_dota_hero_phantom_assassin" then
            self:GetParent():FindAbilityByName("space_shadowstep"):SetActivated(true)
            self:GetParent():FindAbilityByName("space_shadowstep_teleport"):SetActivated(true)
            self:GetParent():FindAbilityByName("space_shadowstep_teleport_back"):SetActivated(true)
        end
    end
end
--------------------------------------------------------------------------------
