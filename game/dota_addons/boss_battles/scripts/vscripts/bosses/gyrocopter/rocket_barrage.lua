rocket_barrage = class({})

--As the spell level increases the dmg increase, perhaps the radius or duration too. 


local spellDuration = 3 -- Spell duration in seconds
local tickDuration = 0.1 -- Amount of time to delay between ticks
local tickLimit = spellDuration / tickDuration

local totalDamage = 500
local tickDamage = totalDamage / tickLimit

local radius = 300

--Spell deals x dmg every second. 
--Spell checks for enemies in radius, then splits this dmg amongst the players in radius
function rocket_barrage:OnSpellStart()


	--TODO: make a timer
	local tickCount = 0
	Timers:CreateTimer(function()	
		tickCount = tickCount + 1

		--Get nearby enemies
		local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		print("Found this many enemies: ", #enemies)

		--if no enemies, then no need to continue
		if #enemies == 0 then 
			return tickDuration
		end

		--distribute dmg amongst them
			--each enemy gets tickDamage / (#enemies +1) --+1 if 0 indexed, otherwise just #enemies
		local enemyDmg = tickDamage / #enemies
		print("enemyDmg = ",enemyDmg)


		for key, enemy in pairs(enemies) do 
			--todo make dmg table

			--apply

		end

		--check if we've reached the end of the spell
		if tickCount >= tickLimit then
			print("tickCount >= tickLimit. Returning.")
			return 
		end

		return tickDuration
	end)

end