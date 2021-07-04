warlord_modifier_shouts = class({})

--------------------------------------------------------------------------------
-- Classifications
function warlord_modifier_shouts:IsHidden()
	return false
end

function warlord_modifier_shouts:IsDebuff()
	return false
end

function warlord_modifier_shouts:IsPurgable()
	return false
end

function warlord_modifier_shouts:RemoveOnDeath()
	return true
end

function warlord_modifier_shouts:GetTexture()
	return "axe_battle_hunger"
end

--------------------------------------------------------------------------------
-- Initializations
function warlord_modifier_shouts:OnCreated( kv )
    if IsServer() then

        if self:GetStackCount() < 3 then
            self:IncrementStackCount()
        end

        self.parent = self:GetParent()
        self.parent_origin = self.parent:GetAbsOrigin()

        if self.parent:GetUnitName() == "npc_dota_hero_hoodwink" then
            self.health_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "health_regen" )
            self.mana_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "mana_regen" )
        else
            self.health_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "health_regen" )
            self.mana_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "mana_regen" ) / 10
        end


    end

    if self.parent:GetUnitName() == "npc_dota_hero_hoodwink" then
        self.health_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "health_regen" )
        self.mana_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "mana_regen" )
    else
        self.health_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "health_regen" )
        self.mana_regen = self:GetCaster():FindAbilityByName("e_warlord_shout"):GetSpecialValueFor( "mana_regen" ) / 10
    end

end

function warlord_modifier_shouts:OnRefresh( kv )
    if IsServer() then
        if self:GetStackCount() < 3 then
            self:IncrementStackCount()
        end
    end
end

function warlord_modifier_shouts:OnDestroy( kv )
    if IsServer() then

    end
end

--------------------------------------------------------------------------------

function warlord_modifier_shouts:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end
-----------------------------------------------------------------------------

function warlord_modifier_shouts:GetModifierConstantHealthRegen( params )
    if self:GetStackCount() == nil or self:GetStackCount() == 0 then
        return self.health_regen
    else
        return self.health_regen * self:GetStackCount()
    end
end
--------------------------------------------------------------------------------

function warlord_modifier_shouts:GetModifierConstantManaRegen( params )

    if self:GetStackCount() == nil or self:GetStackCount() == 0 then
        return self.mana_regen
    else
        return self.mana_regen * self:GetStackCount()
    end
end
--------------------------------------------------------------------------------