e_swallow_potion_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function e_swallow_potion_modifier:IsHidden()
	return false
end

function e_swallow_potion_modifier:IsDebuff()
	return false
end

function e_swallow_potion_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function e_swallow_potion_modifier:OnCreated( kv )
    if IsServer() then
        -- references
		--self.ms_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus_pct" )
		self:SetStackCount(1)


		
		--[[local caster = self:GetCaster()
		self.effectIndex = ParticleManager:CreateParticle(
			"particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave_playerglow.vpcf",
			PATTACH_CUSTOMORIGIN,
			caster)
		ParticleManager:SetParticleControlEnt(self.effectIndex , 0, caster, 5, "attach_attack2", Vector(0,0,0), true)]]



    end
end

function e_swallow_potion_modifier:OnRefresh( kv )
	if IsServer() then
		if self:GetStackCount() < 3 then
			self:IncrementStackCount()
		end

		if (SOLO_MODE == true and self:GetStackCount() == 3 ) then
			self.heal = self:GetAbility():GetSpecialValueFor("heal_tick")
			self.parent = self:GetParent()
			self.stopHealLoop = false
			self:HealLoop()
		end

    end
end

function e_swallow_potion_modifier:OnRemoved()
end

function e_swallow_potion_modifier:OnDestroy()
	if IsServer() then
		self.stopHealLoop = true
	end
end

function e_swallow_potion_modifier:HealLoop()
    if IsServer() then

        Timers:CreateTimer(1, function()
            if self.stopHealLoop == true then
                return false
            end

			local particle_lifesteal = "particles/items3_fx/octarine_core_lifesteal.vpcf"

			local lifesteal_fx = ParticleManager:CreateParticle(particle_lifesteal, PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControl(lifesteal_fx, 0, self.parent:GetAbsOrigin())

			self.parent:Heal( self.heal , self.parent )

            return 1
        end)

    end
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function e_swallow_potion_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function e_swallow_potion_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end]]

--------------------------------------------------------------------------------
--[[ Graphics & Animations
function e_swallow_potion_modifier:GetEffectName()
	return "particles/econ/items/abaddon/abaddon_everblack/abaddon_everblack_horse_ambient_eyes_glow.vpcf"
end

function e_swallow_potion_modifier:GetEffectAttachType()
	return PATTACH_EYES_FOLLOW
end]]