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
		self.units_affected[self.current_unit]	= 1

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
        DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	--print("interval thinker")

	local friendly = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self.current_unit:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _, friend in pairs(friendly) do
		if friend:GetUnitName() == "npc_crystal" then
			friend:GiveMana(10)
			friend:AddNewModifier( nil, nil, "cast_electric_field", { duration = -1 } )
		elseif friend:GetUnitName() == "npc_ice_ele" then
			friend:AddNewModifier( nil, nil, "modifier_generic_stunned", { duration = 5 } )
		elseif friend:GetUnitName() == "npc_fire_ele" then
			friend:AddNewModifier( nil, nil, "modifier_generic_stunned", { duration = 5 } )
		elseif friend:GetUnitName() == "npc_elec_ele" then
			friend:AddNewModifier( nil, nil, "chain_light_buff_elec", { duration = 1 } )
		end
	end

	for _, enemy in pairs(units) do
		--print("units ", enemy:GetUnitName())
		if enemy ~= self.current_unit and enemy ~= self.previous_unit then
            enemy:EmitSound("Hero_Zuus.ArcLightning.Target")

			self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(self.lightning_particle)

			if enemy:HasModifier("fire_ele_encase_rocks_debuff") == true then
				enemy:AddNewModifier( nil, nil, "electric_encase_rocks", { duration = 10 } )
			end

			self.unit_counter = self.unit_counter + 1
			self.previous_unit = self.current_unit
			self.current_unit = enemy

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
