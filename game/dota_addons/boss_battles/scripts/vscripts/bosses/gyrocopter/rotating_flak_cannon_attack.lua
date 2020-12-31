rotating_flak_cannon_attack = class({})

function rotating_flak_cannon_attack:OnSpellStart()
	print("rotating_flak_cannon_attack:OnSpellStart()")

	self.damage = 15
	self.caster = self:GetCaster()

	-- grab target from _G.FlakCannonTargets[1], remove it, shoot at it
	if #_G.FlakCannonTargets > 0 then
		self.target = shallowcopy(_G.FlakCannonTargets[1])

		--remove [1] and reorder the list
		for i = 1, #_G.FlakCannonTargets, 1 do 
			if _G.FlakCannonTargets[i+1] ~= nil then 
				_G.FlakCannonTargets[i] = _G.FlakCannonTargets[i+1]
			else
				_G.FlakCannonTargets[i] = nil
			end
		end

	    local info = {
	    -- EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
	    EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
	    Ability = self,
	    iMoveSpeed = 600,
	    Source = self.caster,
	    Target = self.target,
	    bDodgeable = false,
	    --iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,

	    --from stefans code:
	    bDeleteOnHit = true,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,


	    bProvidesVision = true,
	    iVisionTeamNumber = self.caster:GetTeamNumber(),
		iVisionRadius = 300,
		}
	    ProjectileManager:CreateTrackingProjectile( info )

	else
		print("gyro_base_attack cast, but no targets found in _G.whirlwindTargets")
	end


end


function rotating_flak_cannon_attack:OnProjectileHit( hTarget, vLocation)
	--print("rotating_flak_cannon_attack:OnProjectileHit()")

    if IsServer() then
        if hTarget:IsAlive() == true then
            local dmgTable =
            {
                victim = hTarget,
                attacker = self.caster,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)

        end
    end
end