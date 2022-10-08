
homing_missile_modifier = class({})

-----------------------------------------------------------------------------

function homing_missile_modifier:IsHidden()
	return false
end
-----------------------------------------------------------------------------
function homing_missile_modifier:OnCreated( params )
    if IsServer() then

        self.speed						= 150--self:GetAbility():GetSpecialValueFor("speed")
        self.acceleration				= 30--self:GetAbility():GetSpecialValueFor("acceleration")

        if not IsServer() then return end

        self.damage						= 100
        self.damage_type				= DAMAGE_TYPE_PHYSICAL

        self.target	= EntIndexToHScript(params.target)

        self.interval					= 1 / self.acceleration

        if self.target then
            self.target_particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target, self:GetCaster():GetTeamNumber())
            self:AddParticle(self.target_particle, false, false, -1, false, false)
        end

        self.find_gyro = true

        self.speed_counter = 0

        self.speed_counter_increment = 1

        -- accel timer
        -- add a timer here to icnrease speed every... 2 seconds?
        --[[self.speed_up_timer = Timers:CreateTimer(3,function()
            self:IncrementStackCount()
            return 3
        end)]]

    end
end

function homing_missile_modifier:OnRefresh(  )
    if IsServer() then
    end
end


function homing_missile_modifier:OnDestroy()
    if IsServer() then
        self:GetParent():StopSound("Hero_Gyrocopter.HomingMissile")
        self:GetParent():StopSound("Hero_Gyrocopter.HomingMissile.Enemy")

        --[[if self.speed_up_timer then
            Timers:RemoveTimer(self.speed_up_timer)
        end]]

        -- add explode particle
        local explosion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(explosion_particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(explosion_particle)
    end
end

-----------------------------------------------------------------------------

function homing_missile_modifier:OnIntervalThink()
	if IsServer() then

        self.speed_counter	= self.speed_counter + self.speed_counter_increment
        self:SetStackCount(self.speed_counter)

        -- if player is really close within 150 units or so to gyro, rocket changes target to gyro
        if self.find_gyro == true then
            local nearby_targets = FindUnitsInRadius(self.target:GetTeamNumber(), self.target:GetAbsOrigin(), nil, 120, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC ,DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false) 
            for _, gyro_target in pairs(nearby_targets) do
                if gyro_target:GetUnitName() == "npc_gyrocopter" then
                    self.target = gyro_target
                    self.speed_counter_increment = 3
                    self.find_gyro = false
                end
            end
        end

        if self.target then
            if self.target:IsNull() or not self.target:IsAlive() then
                local nearby_targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
                if #nearby_targets >= 1 then
                    self.target = nearby_targets[1]
                    
                    ParticleManager:DestroyParticle(self.target_particle, false)
                    ParticleManager:ReleaseParticleIndex(self.target_particle)
                    self.target_particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target, self:GetCaster():GetTeamNumber())
                    self:AddParticle(self.target_particle, false, false, -1, false, false)
                end
            end
        end
            
        -- Arbitrary change of target handling as missile gets close (so it can overlap and count collision detection)
        if (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > 250 then
            self:GetParent():MoveToNPC(self.target)
        else
            self:GetParent():MoveToPosition(self.target:GetAbsOrigin())
        end


        -- Missile impact logic
        if self.target and (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self:GetParent():GetHullRadius() then
            self.target:EmitSound("Hero_Gyrocopter.HomingMissile.Target")
            self.target:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")

            if self.target:GetUnitName() == "npc_gyrocopter"  then
                self.stun_modifier = self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "gyro_homing_missile_stun_check", {duration = -1})

                local stacks = 0
                if self:GetCaster():HasModifier("gyro_homing_missile_stun_check") then
                    stacks = self:GetCaster():GetModifierStackCount("gyro_homing_missile_stun_check", self:GetCaster())
                end

                self.rockets_that_need_to_hit_to_stun = 3
                if SOLO_MODE == true then
                    self.rockets_that_need_to_hit_to_stun = 1;
                end

                if stacks >= self.rockets_that_need_to_hit_to_stun then

                    if self:GetCaster().particle_timer ~= nil then
                        ParticleManager:DestroyParticle(self:GetCaster().particle_timer,true)
                    end
                    
                    if self:GetCaster():HasModifier("modifier_flak_cannon") then
                        self:GetCaster():RemoveModifierByName("modifier_flak_cannon")
                    end
                    if self:GetCaster():HasModifier("modifier_generic_disable_auto_attack") then
                        self:GetCaster():RemoveModifierByName("modifier_generic_disable_auto_attack")
                    end


                    self.target:AddNewModifier(
                        self:GetCaster(), -- player source
                        self, -- ability source
                        "modifier_stunned", -- modifier name
                        {
                            duration = 10,
                    })

                    self.target:AddNewModifier(
                        self:GetCaster(), -- player source
                        self, -- ability source
                        "purple_crystal_modifier", -- modifier name
                        {
                            duration = 10,
                    })
                end
            else
                ApplyDamage({
                    victim 			= self.target,
                    damage 			= self.damage,
                    damage_type		= self.damage_type,
                    attacker 		= self:GetCaster(),
                    ability 		= self:GetAbility()
                })
            end

            self:GetParent():ForceKill(false)
            self:GetParent():AddNoDraw()
        end
	end
end

-----------------------------------------------------------------------------

function homing_missile_modifier:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION]					= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]						= true,
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS]	= (not self.bAutoCast or self.bAutoCast == 0) or self:GetParent():HasModifier("modifier_imba_gyrocopter_homing_missile_pre_flight"),
		[MODIFIER_STATE_IGNORING_STOP_ORDERS]				= true
	}
end

function homing_missile_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end

function homing_missile_modifier:GetModifierMoveSpeed_Absolute()
	if self:GetParent():HasModifier("modifier_imba_gyrocopter_homing_missile_pre_flight") then
		return 0
	else
        --print("GetModifierMoveSpeed_Absolute ",self.speed + self:GetStackCount())
		return self.speed + self:GetStackCount()
	end
end

function homing_missile_modifier:GetModifierMoveSpeed_Limit()
	if self:GetParent():HasModifier("modifier_imba_gyrocopter_homing_missile_pre_flight") then
		return -0.01
	else
        --print("GetModifierMoveSpeed_Limit ",self.speed + self:GetStackCount())
		return self.speed + self:GetStackCount()
	end
end



