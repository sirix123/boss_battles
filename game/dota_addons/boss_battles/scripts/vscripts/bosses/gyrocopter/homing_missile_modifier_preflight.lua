
homing_missile_modifier_preflight = class({})

-----------------------------------------------------------------------------

function homing_missile_modifier_preflight:IsHidden()
	return false
end
-----------------------------------------------------------------------------
function homing_missile_modifier_preflight:OnCreated( params )
    if IsServer() then
        self.speed						= 400
        self.interval = 1 / 20--self:GetAbility():GetSpecialValueFor("acceleration")

        if IsServer() then

            self:GetParent():EmitSound("Hero_Gyrocopter.HomingMissile")

            self.target	= EntIndexToHScript(params.target)


            self:StartIntervalThink(self.interval)
        end
    end
end

function homing_missile_modifier_preflight:OnRefresh(  )
    if IsServer() then
    end
end


function homing_missile_modifier_preflight:OnDestroy()
    if IsServer() then

        if not self:GetParent():IsAlive() then return end

        self:GetParent():EmitSound("Hero_Gyrocopter.HomingMissile.Enemy")

        if self:GetParent():HasModifier("homing_missile_modifier") then

            --self:GetParent():SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

            if self.target and not self.target:IsNull() and self.target:IsAlive() then
                self:GetParent():MoveToNPC(self.target)
            end

            self:GetParent():FindModifierByName("homing_missile_modifier"):StartIntervalThink(self.interval)

            local missile_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(missile_particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_fuse", self:GetParent():GetAbsOrigin(), true)
            self:GetParent():FindModifierByName("homing_missile_modifier"):AddParticle(missile_particle, false, false, -1, false, false)

        else
            self:GetParent():ForceKill(false)
            self:GetParent():AddNoDraw()
        end

    end
end

-----------------------------------------------------------------------------

function homing_missile_modifier_preflight:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function homing_missile_modifier_preflight:OnDeath(keys)
	-- find new target for missile if target dies during preflight
	if self.target and keys.unit == self.target then
		local nearby_targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)

		if #nearby_targets >= 1 then
			self.target = nearby_targets[1]
			self:GetParent():FindModifierByName("homing_missile_modifier").target = nearby_targets[1]

			ParticleManager:DestroyParticle(self:GetParent():FindModifierByName("homing_missile_modifier").target_particle, false)
			ParticleManager:ReleaseParticleIndex(self:GetParent():FindModifierByName("homing_missile_modifier").target_particle)
			self:GetParent():FindModifierByName("homing_missile_modifier").target_particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target, self:GetCaster():GetTeamNumber())
			self:GetParent():FindModifierByName("homing_missile_modifier"):AddParticle(self:GetParent():FindModifierByName("homing_missile_modifier").target_particle, false, false, -1, false, false)
		end
	end
end

