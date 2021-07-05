templar_passive = class({})

LinkLuaModifier("templar_passive_modifier", "player/templar/modifiers/templar_passive", LUA_MODIFIER_MOTION_NONE)

function templar_passive:GetIntrinsicModifierName()
	return "templar_passive_modifier"
end

templar_passive_modifier = class({})

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

function templar_passive_modifier:IsHidden() return true end

function templar_passive_modifier:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}

	return funcs
end

function templar_passive_modifier:GetModifierTotal_ConstantBlock( params )
    if IsServer() then

        -- when we take damage... if we have mana *block" the dmg but reduce mana
        local mana_damage_reduction = self:GetCaster():FindAbilityByName("templar_passive"):GetSpecialValueFor( "mind_over_matter" )
        local current_mana = self:GetCaster():GetMana()
        local incoming_damage = kv.damage
        local dmg_to_take = 0
        local mana_to_remove = ( incoming_damage * ( mana_damage_reduction / 100 ) )

        print("incoming_damage: ",incoming_damage)
        print("mana_to_remove: ",mana_to_remove)

        -- if current mana is less then the dmage coming in, if we don't have 30% of mana to mitgate need to take more dmg
        -- hit = 100, current mana = 20, player should take 80dmg
        -- hit * .7 = 70, mana loss hit * .3 = 30
        -- player hit for 70 + 10 = 80
        if mana_to_remove >= current_mana then

            dmg_to_take = ( incoming_damage * ( mana_damage_reduction / 100 ) ) + current_mana
            print("dmg_to_take: ",dmg_to_take)

            return dmg_to_take

        -- if current mana ismore the the damage coiming in
        else
            return ( incoming_damage * ( (100 - mana_damage_reduction) / 100 ) )
        end

        -- remove mana, if we need to remove more then total, reduce by current mana the caster has
        if current_mana <= mana_to_remove and curent_mana > 0 then
            self:GetCaster():ReduceMana( current_mana )
        else
            self:GetCaster():ReduceMana( mana_to_remove )
        end

    end
end
