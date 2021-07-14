r_infest_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function r_infest_modifier:IsHidden()
	return false
end

function r_infest_modifier:IsDebuff()
	return false
end

function r_infest_modifier:GetTexture()
	return "queenofpain_blink"
end

function r_infest_modifier:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end

function r_infest_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_goo.vpcf"
end
-----------------------------------------------------------------------------

function r_infest_modifier:OnCreated( kv )
	if not IsServer() then return end

    self.total_damage = 0
    self.dot_duration = kv.dot_duration
    self.count = self:GetDuration()

    self.timer = Timers:CreateTimer(function()
		if self.count == 0 then
			ParticleManager:DestroyParticle(self.particle, true)
			return false
		end

		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end

		self.particle = ParticleManager:CreateParticle("particles/rat/_rat_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		--local digitX = self.count >= 10 and 1 or 0
		if self.count >= 10 and self.count < 20 then
			digitX = 1
		elseif self.count >= 20 then
			digitX = 2
		else 
			digitX = 0
		end

		local digitY = self.count % 10
		--print("digitX: ",digitX,"digitY: ",digitY)
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, Vector( digitX, digitY, 0 ))

		self.count = self.count - 1

		return 1.0
	end)

end

function r_infest_modifier:OnRefresh( kv )
	if not IsServer() then return end

	self:OnCreated()

end

function r_infest_modifier:OnRemoved()
    if not IsServer() then return end

end

function r_infest_modifier:OnDestroy()
	if not IsServer() then return end

    self:GetParent():AddNewModifier(
        self:GetCaster(), -- player source
        self:GetAbility(), -- ability source
        "r_infest_modifier_damage", -- modifier name
        {
            duration = self.dot_duration,
            dmg = self.total_damage,
        } -- kv
    )

    Timers:RemoveTimer(self.timer)

end
----------------------------------------------------------------------------

function r_infest_modifier:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function r_infest_modifier:OnTakeDamage( params )
    if IsServer() then
        --print("params.attacker.name ",params.attacker:GetUnitName())
        if params.attacker:GetUnitName() == "npc_dota_hero_hoodwink" then
            --print("healing")
            --print("original_damage ",params.original_damage)
            --print("damage ",params.damage)

            local damage = params.damage
            self.total_damage = damage + self.total_damage

            --print("self.total_damage ",self.total_damage)

        end
    end
end

