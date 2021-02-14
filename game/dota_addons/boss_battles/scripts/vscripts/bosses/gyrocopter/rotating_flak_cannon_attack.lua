rotating_flak_cannon_attack = class({})

function rotating_flak_cannon_attack:OnSpellStart()
	--print("rotating_flak_cannon_attack:OnSpellStart()")

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
    	-- WORKING but not what I want
	    --EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
	    --EffectName = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf",
	    --EffectName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits_launch_bird.vpcf",	
	    --EffectName = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_line_flames.vpcf",
	    --EffectName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits_launch_fire.vpcf",
	    
	    --TO TEST:

		

		--TESTED: works pretty good, consider using with slight modifications
		--Near perfect!
		EffectName = "particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf",		


		--TESTED but didnt work:
		--EffectName = "particles/econ/events/ti10/portal/portal_revealed_phoenix_trailtrail_fire.vpcf",
		--EffectName = "particles/addons_gameplay/lamp_flame_new_main.vpcf",
		--EffectName = "particles/battlepass/healing_campfire_flame.vpcf",
		--EffectName = "particles/econ/courier/courier_cluckles/courier_cluckles_ambient_rocket_flame.vpcf",
		--EffectName = "particles/econ/items/batrider/batrider_fall20/batrider_fall20_mount_tail_flames.vpcf",
		--EffectName = "particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_offhand_elixir_flame.vpcf",
		--EffectName = "particles/econ/items/invoker/invoker_ti7/invoker_ti7_alacrity_flame.vpcf",
		-- EffectName = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden_flame_hot.vpcf",
		-- EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_fire_split_flame_head.vpcf",
		-- EffectName = "particles/units/heroes/hero_batrider/batrider_flaming_lasso_generic_flames_body.vpcf",

	    Ability = self,
	    --iMoveSpeed = 600,
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
		print("rotating_flak_cannon_attack cast, but no targets found in _G.whirlwindTargets")
	end


end


function rotating_flak_cannon_attack:OnProjectileHit( hTarget, vLocation)
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