electric_encase_rocks = class({})

function electric_encase_rocks:IsHidden()
	return false
end

function electric_encase_rocks:IsDebuff()
	return false
end

function electric_encase_rocks:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function electric_encase_rocks:OnCreated( kv )
	if IsServer() then
		self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = 150 --kv.radius
        self.dmg = 1--50 --kv.dmg
        self.stopDamageLoop = false
        self.damage_interval = 2 --kv.damage_interval

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function electric_encase_rocks:OnDestroy( kv )
    if IsServer() then
		self.stopDamageLoop = true
	end
end
---------------------------------------------------------------------------


function electric_encase_rocks:StartApplyDamageLoop()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
		end

		local dmgTable = {
			victim = self.parent,
			attacker = self:GetCaster(),
			damage = self.dmg,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(dmgTable)

		return self.damage_interval
	end)
end

function electric_encase_rocks:GetEffectName()
    return "particles/tinker/blue_huskar_burning_spear_debuff.vpcf"
end

function electric_encase_rocks:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function electric_encase_rocks:GetTexture()
    return "ember_spirit_flame_guard"
end