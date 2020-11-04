chain_light_buff_elec = class({})

function chain_light_buff_elec:IsHidden()
	return false
end

function chain_light_buff_elec:IsDebuff()
	return false
end

function chain_light_buff_elec:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function chain_light_buff_elec:OnCreated( kv )
    if IsServer() then

		-- gives proj speed in spell and changes the particle effect
	end
end
---------------------------------------------------------------------------

function chain_light_buff_elec:OnDestroy( kv )
	if IsServer() then

		self.death_pos = self:GetParent():GetAbsOrigin()

		-- particle effect
		local particle = "particles/tinker/summon_elementals_portal_open_good.vpcf"
        self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.effect_cast_1, 0, self.death_pos)

		Timers:CreateTimer(2, function()
			ParticleManager:DestroyParticle(self.effect_cast_1,false )
			CreateUnitByName( "npc_elec_ele", self.death_pos, true, nil, nil, DOTA_TEAM_BADGUYS)
			CreateUnitByName( "npc_elec_ele", self.death_pos, true, nil, nil, DOTA_TEAM_BADGUYS)
			return false
		end)

	end
end
---------------------------------------------------------------------------

function chain_light_buff_elec:GetStatusEffectName()
	return "particles/status_fx/status_effect_electrical.vpcf"
end