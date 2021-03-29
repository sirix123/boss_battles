
modifier_flak_cannon = class({})

-----------------------------------------------------------------------------

function modifier_flak_cannon:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function modifier_flak_cannon:OnCreated(  )
    if IsServer() then
        self.radius				= 800 --self:GetAbility():GetSpecialValueFor("radius")
        self.projectile_speed	= 150 --self:GetAbility():GetSpecialValueFor("projectile_speed")

        print("casting flak cnon")

        local particle = "particles/units/heroes/hero_gyrocopter/gyro_flak_cannon_overhead.vpcf"
        self.nfx = ParticleManager:CreateParticle(particle,PATTACH_OVERHEAD_FOLLOW,self:GetParent())
        ParticleManager:SetParticleControl(self.nfx, 0, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,300))
        ParticleManager:SetParticleControl(self.nfx, 1, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,300))
    end
end

function modifier_flak_cannon:OnRefresh(  )
    if IsServer() then
    end
end


function modifier_flak_cannon:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.nfx,true)
    end
end

-----------------------------------------------------------------------------
--[[
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

		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)) do
			if enemy ~= keys.target then
				self:GetParent():PerformAttack(enemy, false, false, true, true, true, false, false)
			end
		end
	end
end]]


