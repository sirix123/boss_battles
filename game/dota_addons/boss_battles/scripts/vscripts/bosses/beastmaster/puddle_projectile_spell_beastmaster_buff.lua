puddle_projectile_spell_beastmaster_buff = class({})

function puddle_projectile_spell_beastmaster_buff:IsHidden()
	return false
end

function puddle_projectile_spell_beastmaster_buff:IsDebuff()
	return true
end

function puddle_projectile_spell_beastmaster_buff:IsPurgable()
	return false
end

function puddle_projectile_spell_beastmaster_buff:GetHeroEffectName()
	return "particles/beastmaster/green_ursa_enrage_buff_beastmaster.vpcf"
end

---------------------------------------------------------------------------

function puddle_projectile_spell_beastmaster_buff:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self:IncrementStackCount()
        local digitX = nil

        -- increase stacks above his head
        local stacks = self:GetStackCount()

        self.particle = ParticleManager:CreateParticle("particles/beastmaster/beastmater_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())

        --local digitX = thisEntity.count >= 10 and 1 or 0
        if stacks >= 10 and stacks < 20 then
            digitX = 1
        elseif stacks >= 20 and stacks < 30 then
            digitX = 2
        elseif stacks >= 30 and stacks < 40 then
            digitX = 3
        elseif stacks >= 40 and stacks < 50 then
            digitX = 4
        elseif stacks >= 50 and stacks < 60 then
            digitX = 5
        elseif stacks >= 60 and stacks < 70 then
            digitX = 6
        else
            digitX = 0
        end

        local digitY = stacks % 10
        --print("digitX: ",digitX,"digitY: ",digitY)
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 1, Vector( digitX, digitY, 0 ))

        if stacks ~= nil and stacks ~= 0 then
			self.dmg = 3 * stacks
		else
			self.dmg = 10
		end


	end
end
---------------------------------------------------------------------------

function puddle_projectile_spell_beastmaster_buff:OnRefresh(table)
    if IsServer() then
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,true)
        end
        self:OnCreated()
	end
end
---------------------------------------------------------------------------


function puddle_projectile_spell_beastmaster_buff:OnDestroy( kv )
    if IsServer() then
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,true)
        end
	end
end
---------------------------------------------------------------------------

function puddle_projectile_spell_beastmaster_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function puddle_projectile_spell_beastmaster_buff:OnAttackLanded( keys )
	if IsServer() then
		local owner = self:GetParent()

		if owner ~= keys.attacker then
			return end

        local target = keys.target

        target:AddNewModifier(owner,self:GetAbility(),"beastmaster_puddle_dot_debuff_attack_player_debuff",{duration = 6, dmg_per_tick = self.dmg})

	end
end
