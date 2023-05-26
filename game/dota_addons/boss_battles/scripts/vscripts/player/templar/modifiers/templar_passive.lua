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

function templar_passive_modifier:GetStatusEffectName()
	return "particles/templar/templar_status_effect_arc_warden_tempest.vpcf"
end

function templar_passive_modifier:GetEffectName()
	return "particles/templar/templar_arc_warden_tempest_buff.vpcf"
end

function templar_passive_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function templar_passive_modifier:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function templar_passive_modifier:GetModifierTotal_ConstantBlock( params )
    if IsServer() then

        -- when we take damage... if we have mana *block" the dmg but reduce mana
        local mana_damage_reduction = self:GetParent():FindAbilityByName("templar_passive"):GetSpecialValueFor( "mind_over_matter" )
        local current_mana = self:GetParent():GetMana()
        local incoming_damage = params.damage
        local dmg_to_take = 0
        local dmg_to_block = 0
        local mana_to_remove = ( incoming_damage * ( mana_damage_reduction / 100 ) )

        --PrintTable(params)

        --print("incoming_damage: ",incoming_damage)
        --print("mana_to_remove: ",mana_to_remove)

        --[[
            bm net
            incoming_damage: 	300
            mana_to_remove: 	90
        ]]

        if params.damage_type ~= DAMAGE_TYPE_PURE then
            -- remove mana, if we need to remove more then total, reduce by current mana the caster has
            if current_mana <= mana_to_remove and current_mana > 0 then
                self:GetParent():Script_ReduceMana( current_mana ,nil)
            else
                self:GetParent():Script_ReduceMana( mana_to_remove ,nil)
            end

            -- if current mana is less then the dmage coming in, if we don't have 30% of mana to mitgate need to take more dmg
            -- hit = 100, current mana = 20, player should take 80dmg
            -- hit * .7 = 70, mana loss hit * .3 = 30
            -- player hit for 70 + 10 = 80
            -- return the dmg to block...
            if mana_to_remove >= current_mana then

                dmg_to_take = incoming_damage - ( incoming_damage * ( mana_damage_reduction / 100 ) ) + current_mana
                dmg_to_block = incoming_damage - dmg_to_take
                --print("1 dmg_to_block: ",dmg_to_block)
                --print("1 dmg_to_take: ",dmg_to_take)
                --print("-------------")
                return dmg_to_block

            -- if current mana ismore the the damage coiming in
            else
                dmg_to_take = incoming_damage - ( incoming_damage * ( mana_damage_reduction / 100 ) )
                dmg_to_block = incoming_damage - dmg_to_take
                --print("2 dmg_to_block: ",dmg_to_block)
                --print("2 dmg_to_take: ",dmg_to_take)
                --print("-------------")
                return dmg_to_block
            end
        end
    end
end
