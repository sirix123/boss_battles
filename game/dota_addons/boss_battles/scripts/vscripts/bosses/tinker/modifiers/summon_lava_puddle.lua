summon_lava_puddle = class({})

function summon_lava_puddle:IsHidden()
	return false
end

function summon_lava_puddle:IsDebuff()
	return false
end

function summon_lava_puddle:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function summon_lava_puddle:OnCreated( kv )
    if IsServer() then

		-- use the duration of this modifier
		self.count = self:GetDuration()
		self.timer = Timers:CreateTimer(function()
			if self.count == 0 or self:GetParent():IsAlive() == nil or self:GetParent():IsAlive() == false then
				ParticleManager:DestroyParticle(self.particle, true)
				return false
			end

			if self.particle then
				ParticleManager:DestroyParticle(self.particle, true)
			end

			self.particle = ParticleManager:CreateParticle("particles/gyrocopter/gyro_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
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
end
---------------------------------------------------------------------------

function summon_lava_puddle:OnDestroy( kv )
    if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
		Timers:RemoveTimer(self.timer)
	end
end
-----------------------------------------------------------------------------
