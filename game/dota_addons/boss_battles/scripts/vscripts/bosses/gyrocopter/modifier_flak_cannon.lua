
modifier_flak_cannon = class({})
LinkLuaModifier( "oil_drop_thinker", "bosses/gyrocopter/oil_drop_thinker", LUA_MODIFIER_MOTION_NONE )
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
        self.tick_rate = 0.5

        if IsServer() then

            self.timer = Timers:CreateTimer(function()
                if IsValidEntity(self:GetCaster()) == false then
                    return false
                end

                if self:GetCaster():IsAlive() == false then
                    return false
                end

                -- create the modifier thinker
                local puddle = CreateModifierThinker(
                self:GetCaster(),
                    self,
                    "oil_drop_thinker",
                    {
                        target_x = self:GetCaster().x,
                        target_y = self:GetCaster().y,
                        target_z = GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()).z,
                    },
                    GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()),
                    self:GetCaster():GetTeamNumber(),
                    false
                )

                table.insert(_G.Oil_Puddles, puddle)

                return 0.5
            end)

            self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/gyrocopter/no_arrows_gyro_darkmoon_calldown_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetParent():GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self.radius, -self.radius, -self.radius ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector(self:GetDuration() + 2,0,0) );
            ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

            self:StartIntervalThink(self.tick_rate)
        end
    end
end

function modifier_flak_cannon:OnRefresh(  )
    if IsServer() then
    end
end


function modifier_flak_cannon:OnDestroy()
    if IsServer() then
        Timers:RemoveTimer(self.timer)
        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
    end
end

-----------------------------------------------------------------------------

function modifier_flak_cannon:OnIntervalThink()
	if IsServer() then

		if self:GetParent() == nil then self:Destroy() end

		local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_ALL,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,unit in pairs(units) do

            EmitSoundOn( "Hero_Gyrocopter.FlackCannon", self:GetCaster() )

            local info = {
                EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
                Ability = self,
                iMoveSpeed = 1500,
                Source = self:GetCaster(),
                Target = unit,
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

-----------------------------------------------------------------------------

function modifier_flak_cannon:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
        if hTarget then
            local dmgTable =
            {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = 50,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)

        end
    end
end
-----------------------------------------------------------------------------

-- move speed boost

function modifier_flak_cannon:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
	}
	return funcs
end
-----------------------------------------------------------------------------

function modifier_flak_cannon:GetModifierMoveSpeedBonus_Percentage( params )
	return 100
end
--------------------------------------------------------------------------------

function modifier_flak_cannon:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end


function modifier_flak_cannon:GetDisableAutoAttack()
    return true
end


