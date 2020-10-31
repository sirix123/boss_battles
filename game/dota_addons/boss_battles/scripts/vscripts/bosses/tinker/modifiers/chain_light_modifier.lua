chain_light_modifier = class({})

LinkLuaModifier("modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE)

function chain_light_modifier:IsHidden()
    return true
end

function chain_light_modifier:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function chain_light_modifier:OnCreated(keys)
	if not IsServer() or not self:GetAbility() then return end

	self.arc_damage	= 1 --self:GetAbility():GetSpecialValueFor("arc_damage")
	self.radius	= 1000 --self:GetAbility():GetSpecialValueFor("radius")
	self.jump_count	= 10 --self:GetAbility():GetSpecialValueFor("jump_count")
	self.jump_delay	= 0.5 --self:GetAbility():GetSpecialValueFor("jump_delay")

	self.starting_unit = keys.unit

    self.units_affected	= {}

    if self.starting_unit and EntIndexToHScript(self.starting_unit) then

		self.current_unit= EntIndexToHScript(self.starting_unit)
		self.units_affected[self.current_unit] = 1

		self.dmgTable = {
			victim = self.current_unit,
			attacker = self:GetCaster(),
			damage = self.arc_damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self,
		}

		ApplyDamage(self.dmgTable)

	else
		self:Destroy()
		return
	end

	self.unit_counter = 0

	self:StartIntervalThink(self.jump_delay)
end
--------------------------------------------------------------------------------

function chain_light_modifier:OnIntervalThink()
    self.zapped = false

    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self.current_unit:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _, unit in pairs(units) do
		--print("unit:GetUnitName() ", unit:GetUnitName())
		--print("self.current_unit ", self.current_unit:GetUnitName())
		--print("self.previous_unit ", self.previous_unit:GetUnitName())
		if unit ~= self.current_unit and unit ~= self.previous_unit then
            unit:EmitSound("Hero_Zuus.ArcLightning.Target")

			print("applying modifier and particle effect")
			self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(self.lightning_particle)

			if unit:GetUnitName() == "npc_crystal" then
				unit:GiveMana(10)
				unit:AddNewModifier( nil, nil, "cast_electric_field", { duration = -1 } )
			elseif unit:GetUnitName() == "npc_ice_ele" then
				unit:AddNewModifier( nil, nil, "modifier_generic_stunned", { duration = 5 } )
			elseif unit:GetUnitName() == "npc_fire_ele" then
				unit:AddNewModifier( nil, nil, "modifier_generic_stunned", { duration = 5 } )
			elseif unit:GetUnitName() == "npc_elec_ele" then
				unit:AddNewModifier( nil, nil, "chain_light_buff_elec", { duration = 1 } )
			end

			if unit:HasModifier("fire_ele_encase_rocks_debuff") == true then
				unit:AddNewModifier( nil, nil, "electric_encase_rocks", { duration = 10 } )
			end

			self.unit_counter = self.unit_counter + 1
			self.previous_unit = self.current_unit
			self.current_unit = unit

			if self.units_affected[self.current_unit] then
				self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
			else
				self.units_affected[self.current_unit]	= 1
			end

			self.zapped	= true

			self.dmgTable = {
				victim = self.current_unit,
				attacker = self:GetCaster(),
				damage = self.arc_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}

			ApplyDamage(self.dmgTable)

			break
		end
    end

    if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
        self:StartIntervalThink(-1)
        self:Destroy()
    end

end
--------------------------------------------------------------------------------
