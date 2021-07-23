oil_fire_checker_modifier = class({})

function oil_fire_checker_modifier:IsHidden()
	return false
end

function oil_fire_checker_modifier:IsDebuff()
	return true
end

function oil_fire_checker_modifier:IsPurgable()
	return false
end

---------------------------------------------------------------------------

function oil_fire_checker_modifier:OnCreated( kv )
    if IsServer() then

        self:IncrementStackCount()

        self.count = self:GetStackCount()

        if self.count >= 10 then
            --print("self.count ",self.count)

            -- start the count down
            self.timer = Timers:CreateTimer(function()
                if self.particle ~= nil then
                    ParticleManager:DestroyParticle(self.particle,true)
                end

                if self.count <= 0 then
                    print("destroying modifier oil_fire_checker_modifier")
                    self:Destroy()
                    return false
                end

                self.particle = ParticleManager:CreateParticle("particles/gyrocopter/gyro_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())

                --local digitX = thisEntity.count >= 10 and 1 or 0
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

                return 1
            end)
        else
            self.particle = ParticleManager:CreateParticle("particles/techies/wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())

            --local digitX = thisEntity.count >= 10 and 1 or 0
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
        end

	end
end
---------------------------------------------------------------------------

function oil_fire_checker_modifier:OnRefresh( kv )
    if IsServer() then
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,true)
        end
        self:OnCreated()
	end
end

function oil_fire_checker_modifier:OnDestroy( kv )
    if IsServer() then
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,true)
        end
        Timers:RemoveTimer(self.timer)
	end
end
---------------------------------------------------------------------------