r_metamorph_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function r_metamorph_modifier:IsHidden()
	return false
end

function r_metamorph_modifier:IsDebuff()
	return false
end

function r_metamorph_modifier:IsStunDebuff()
	return false
end

function r_metamorph_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- effect
function r_metamorph_modifier:GetEffectName()
	return "particles/ranger/debuff_ranger_huskar_burning_spear_debuff.vpcf"
end

function r_metamorph_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function r_metamorph_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- play effect
        self:PlayEffects()

        -- init ability table
        self.tMetamorphAbilities =
        {
            "m1_trackingshot_metamorph",
            "m2_serratedarrow_metamorph",
            "q_stonegaze_metamorph",
            "e_immolate_metamorph"
        }

        self.tMainAbilities =
        {
            "m1_trackingshot",
            "m2_serratedarrow",
            "q_herbarrow",
            "e_syncwithforest"
        }

        self.tDisableAbilities =
        {
            "r_metamorph",
            "space_roar",
        }

        --swap abilities for metamorph ones
        for i = 1 , #self.tMetamorphAbilities, 1 do
                --print("metamorph ab = ", self.tMetamorphAbilities[i]," main ability = ",self.tMainAbilities[i] )
                local abilityToSwap = self.caster:FindAbilityByName(self.tMetamorphAbilities[i])

                if not abilityToSwap then
                    abilityToSwap = self.caster:AddAbility( self.tMetamorphAbilities[i] )
                    self.add = abilityToSwap
                end

                abilityToSwap:SetLevel( 1 )

                self:SetLayout( false, self.tMetamorphAbilities[i], self.tMainAbilities[i], i )
        end

        -- hide abilities
        for i = 1 , #self.tDisableAbilities, 1 do
            local abilityToHide = self.caster:FindAbilityByName(self.tDisableAbilities[i])
            --print(abilityToHide)
            abilityToHide:SetHidden(true)
        end

    end
end
----------------------------------------------------------------------------

function r_metamorph_modifier:SetLayout(main, metamorphAbility, mainAbility, i)
	if self.layout_main~=main then
		local ability_main = mainAbility
		local ability_sub = metamorphAbility

		-- swap
        self:GetCaster():SwapAbilities( ability_main, ability_sub, main, (not main) )

        if i == 4 then
            self.layout_main = main
        end
	end
end
----------------------------------------------------------------------------

function r_metamorph_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function r_metamorph_modifier:OnDestroy()
    if IsServer() then
        for i = 1 , #self.tDisableAbilities, 1 do
            local abilityToHide = self.caster:FindAbilityByName(self.tDisableAbilities[i])
            abilityToHide:SetHidden(false)
        end

        for i = 1 , #self.tMetamorphAbilities, 1 do
            self:SetLayout( true, self.tMetamorphAbilities[i], self.tMainAbilities[i], i )
        end
    end
end
----------------------------------------------------------------------------

--  functions table
-- MODIFIER_PROPERTY_MODEL_SCALE GetModifierModelScale
function r_metamorph_modifier:GetModifierModelChange()
	return "models/heroes/medusa/medusa.vmdl"
end

function r_metamorph_modifier:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end
----------------------------------------------------------------------------

function r_metamorph_modifier:PlayEffects()
    if IsServer() then


    end
end
