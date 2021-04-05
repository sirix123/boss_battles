barrage_radius_attack = class({})

function barrage_radius_attack:OnSpellStart()
	--print("barrage_radius_attack:OnSpellStart()")
	
	--damage is determined by how many targets are in radius. This is set in barrage_radius_melee/ranged.lua
	self.damage = _G.BarrageCurrentDamage

	-- Can't use DOTA_ABILITY_BEHAVIOR_UNIT_TARGET because then gyro will try to turn and face the target.
	--self.target = self:GetCursorTarget()
		
	-- grab target from _G.barrageTargets[1], remove it, shoot at it
	if #_G.BarrageTargets > 0 then
		self.target = shallowcopy(_G.BarrageTargets[1])

		--remove [1] and reorder the list
		for i = 1, #_G.BarrageTargets, 1 do 
			if _G.BarrageTargets[i+1] ~= nil then 
				_G.BarrageTargets[i] = _G.BarrageTargets[i+1]
			else
				_G.BarrageTargets[i] = nil
			end
		end

		--create projectile and shoot at self.target
	    local info = {
	    EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
	    --EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
	    Ability = self,
	    iMoveSpeed = 600,
	    Source = self:GetCaster(),
	    Target = self.target,
	    bDodgeable = false,
	    --iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	    --from stefans code: not certain if i need all of these or what the default values are.
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
		--print("barrage_radius_attack cast, but no targets found in _G.BarrageTargets")
	end
end

function barrage_radius_attack:OnProjectileHit( hTarget, vLocation)
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