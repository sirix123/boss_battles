absorbing_shell = class({})

--TODO update this, maybe use some sort of metal scrap / glaive 
--attack / reflect attack particle:
local particle = "particles/gyrocopter/luna_attack_crescent_moon.vpcf"

-- buff duration particle:
-- particles/units/heroes/hero_dazzle/dazzle_armor_friend.vpcf
-- particles/units/heroes/hero_dazzle/dazzle_armor_enemy_shield.vpcf
-- particles/units/heroes/hero_dazzle/dazzle_armor_friend_shield.vpcf


local duration = 15 --seconds
local tickDuration = 0.1
local totalTicks = duration / tickDuration

local totalAttacks = 5 -- 5 attacks over 5 second duration
local attackInterval = 1 -- attack every 1 second
local attackTickInterval = attackInterval / tickDuration

local initialHp = 0
local hpAtLastAttackInterval = 0

local dmgTakenPerDmgDone = 5 --for every 10 dmg taken, do 1 dmg.
local dmgToDealThreshold = 100

--OLD VERSION: Track dmg taken over duration, afterwards apply flak_cannon modifier
	--Old version was a shield for 5 seconds, then dmg afterwards
--NEW VERSION: Track dmg taken throughout duration, each threshold/interval, attack players dealing dmg based on dmg taken.
	--New version is a shield for 5 seconds, dmging players throughout
function absorbing_shell:OnSpellStart()
	print("absorbing_shell:OnSpellStart()")

	--local buff_particle = "particles/units/heroes/hero_dazzle/dazzle_armor_friend_shield.vpcf"
	local buff_particle = "particles/gyrocopter/gyro_armor_shield.vpcf"

	local target = self:GetCaster()
	local caster = self:GetCaster()


		--UNTESTED:
		--Code from https://github.com/Pizzalol/SpellLibrary/blob/master/game/scripts/vscripts/heroes/hero_abaddon/aphotic_shield.lua
		-- Particle. Need to wait one frame for the older particle to be destroyed
		-- Timers:CreateTimer(0.01, function() 
		-- 	target.ShieldParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

		-- 	-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		-- 	ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		-- end)
	
	-- example from https://github.com/Pizzalol/SpellLibrary/blob/master/game/scripts/vscripts/heroes/hero_dazzle/weave.lua
	-- result: ERRROR: CGameParticleManager::SetParticleControlEnt: Unable to lookup attachment attach_overhead on model models/heroes/gyro/gyro.vmdl for entity npc_dota_creature
	-- local pfx = ParticleManager:CreateParticle(buff_particle, PATTACH_OVERHEAD_FOLLOW, target)
	-- ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
	-- ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)


	-- example from Discord. By Shush.
	-- local pfx = ParticleManager:CreateParticle(buff_particle, PATTACH_OVERHEAD_FOLLOW, target)
	-- ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())

	--example from bear: didn't work. No error, no particle.
	-- local nFXIndex = ParticleManager:CreateParticle( buff_particle, PATTACH_CUSTOMORIGIN, nil )
	-- ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	-- ParticleManager:ReleaseParticleIndex( nFXIndex )

	--example from bear. using bloodlust particle
    -- local nFXIndex = ParticleManager:CreateParticle( "particles/beastmaster/bear_lust_ogre_magi_bloodlust_buff.vpcf", PATTACH_CUSTOMORIGIN, nil )
    -- ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
    -- ParticleManager:ReleaseParticleIndex( nFXIndex )

	
	--this particle just doesn't seem to work. maybe wrong control points but maybe it just doesn't work...
	-- self.effect = ParticleManager:CreateParticle( "particles/gyrocopter/gyro_armor_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
	-- ParticleManager:SetParticleControl( self.effect, 0, caster:GetAbsOrigin() )
	-- ParticleManager:SetParticleControl( self.effect, 60, caster:GetAbsOrigin() )
	-- ParticleManager:SetParticleControl( self.effect, 61, caster:GetAbsOrigin() )

	--working but not the particle I want:
	self.effect = ParticleManager:CreateParticle( "particles/beastmaster/beastmaster_enrage.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
	ParticleManager:SetParticleControl( self.effect, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.effect, 3, caster:GetAbsOrigin() )


	--TODO: start some particle that looks like a 'shell' defensive shell / armor
	initialHp = self:GetCaster():GetHealth()
	hpAtLastAttackInterval = initialHp
	print("initialHp = ", initialHp)

	local tickCount = 0
	Timers:CreateTimer(function()	
		tickCount = tickCount +1

		-- end of spell ... stop the timer
		if (tickCount == totalTicks) then 

			--TODO: remove the buff particle effect


			return
		end 

		-- every attackInterval seconds, do an attack, dmg done depends on dmg taken since last attack
		if (tickCount % attackTickInterval == 0) then
			local currentHp = self:GetCaster():GetHealth()

			--diff betwen hpAtLastAttackInterval and currentHp
			local dmgTakenSinceLastAttack = hpAtLastAttackInterval - currentHp
			
			local dmgToDeal = dmgTakenSinceLastAttack / dmgTakenPerDmgDone
			-- print("dmgTakenSinceLastAttack = ", dmgTakenSinceLastAttack)
			-- print("dmgToDeal = ", dmgToDeal)

			-- only reflect/attack if dmgToDeal is over some threshold...
			--if (dmgToDeal >  dmgToDealThreshold) then
			if ( 1 >  0) then
				--Apply Dmg to all units in radius?
				--Or apply dmg specifically to units who attacked gyro?
				--EASY: just apply evenly(or divided across) to all units.
						--Get nearby enemies
				--local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE,
				local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetCaster():GetAbsOrigin(), nil, 3000,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
				if #enemies == 0 then return tickDuration end --if no enemies, then no need to continue

				--Each enemy in radius gets hit for tickDamage / #enemies
				for key, enemy in pairs(enemies) do 
					--create proj:
			        local info = {
			        	--EffectName = "particles/econ/items/techies/techies_arcana/techies_base_attack_arcana_model.vpcf", --this spawns on target/enemy
			            --EffectName = "particles/gyrocopter/luna_attack_crescent_moon.vpcf", --spawns at gyro, then moves to enemys location, doesnt track enemy
			            --EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf", -- spawns at gyro, tracks enemy until hit
			            --EffectName = "particles/econ/items/luna/luna_crescent_moon/luna_glaive_bounce_crescent_moon.vpcf", --untested
			            --EffectName = "particles/econ/items/luna/luna_ti9_weapon/luna_ti9_base_attack.vpcf", --works. but too much glow/purple color
			            EffectName = "particles/units/heroes/hero_luna/luna_base_attack.vpcf",
			            Ability = self,
			            iMoveSpeed = 200,
			            Source = self:GetCaster(),
			            Target = enemy,
			            bDodgeable = false,
			            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			            bProvidesVision = true,
			            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			            iVisionRadius = 300,
			        }
			        --EmitSoundOn( "Hero_Invoker.ForgeSpirit", self:GetCaster() )
			        -- shoot proj:
			        ProjectileManager:CreateTrackingProjectile( info )

					local damageInfo = 
					{
						victim = enemy, attacker = self:GetCaster(),
						damage = dmgToDeal / #enemies, 
						damage_type = DAMAGE_TYPE_PHYSICAL,
						ability = self,
					}
					local dmgDealt = ApplyDamage(damageInfo)

				end
			end

			hpAtLastAttackInterval = currentHp
		end

		--local totalDamageTaken = initialHp - self:GetCaster():GetHealth()
		return tickDuration 
	end) --end timer

end