barrage_rotating_attack = class({})

function barrage_rotating_attack:OnSpellStart()
	--print("barrage_rotating_attack:OnSpellStart()")
	self.damage = 15 --TODO: put this in kvp txt file?

	-- grab target from _G.barrageTargets[1], remove it, shoot at it
	if #_G.barrageTargets > 0 then
		self.target = shallowcopy(_G.barrageTargets[1])

		--remove [1] and reorder the list
		for i = 1, #_G.barrageTargets, 1 do 
			if _G.barrageTargets[i+1] ~= nil then 
				_G.barrageTargets[i] = _G.barrageTargets[i+1]
			else
				_G.barrageTargets[i] = nil
			end
		end

		--create projectile and shoot at self.target
	    local info = {
	    -- EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
	    EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
	    Ability = self,
	    iMoveSpeed = 600,
	    Source = self:GetCaster(),
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
	    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iVisionRadius = 300,
		}
	    ProjectileManager:CreateTrackingProjectile( info )

	else
		print("barrage_rotating_attack cast, but no targets found in _G.barrageTargets")
	end
end



function barrage_rotating_attack:OnProjectileHit( hTarget, vLocation)
	--print("barrage_rotating_attack:OnProjectileHit()")

    if IsServer() then
        if hTarget:IsAlive() == true then
            local dmgTable =
            {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }
            ApplyDamage(dmgTable)

        end
    end
end