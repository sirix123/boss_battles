
modifier_flak_cannon = class({})

-----------------------------------------------------------------------------

function modifier_flak_cannon:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function modifier_flak_cannon:GetEffectName()
	return "particles/gyrocopter/higher_gyro_flak_cannon_overhead.vpcf"
end

function modifier_flak_cannon:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_flak_cannon:OnCreated(  )
    if IsServer() then
        self.radius				= self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_flak_cannon:OnRefresh(  )
    if IsServer() then
    end
end


function modifier_flak_cannon:OnDestroy()
    if IsServer() then
        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
    end
end

-----------------------------------------------------------------------------

function modifier_flak_cannon:DeclareFunctions()
    local funcs = {
            MODIFIER_EVENT_ON_ATTACK,
        }

    return funcs
end

-----------------------------------------------------------------------------

function modifier_flak_cannon:OnAttack(keys)
	if keys.attacker == self:GetParent() then
		self:GetParent():EmitSound("Hero_Gyrocopter.FlackCannon")

        local enemies = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )

		for _, enemy in pairs(enemies) do
			if enemy ~= keys.target then
                local info = {
                    EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
                    Ability = self,
                    iMoveSpeed = 1500,
                    Source = self:GetCaster(),
                    Target = enemy,
                    bDodgeable = false,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
                    bProvidesVision = true,
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                    iVisionRadius = 300,
                }

                -- shoot proj
                ProjectileManager:CreateTrackingProjectile( info )
			end
		end
	end
end

function modifier_flak_cannon:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
        if hTarget then
            local dmgTable =
            {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self:GetAbility():GetSpecialValueFor("dmg"),
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)

        end
    end
end


