barrage = class({})

-- barrage is an ability which does the two below abilities; barrage_radius_melee and barrage_radius_ranged

function barrage:OnSpellStart()
	--print("barrage:OnSpellStart()")
	_G.IsGyroBusy = true
	local caster = self:GetCaster()

	local melee_barrage = caster:FindAbilityByName("barrage_radius_melee")
	local ranged_barrage = caster:FindAbilityByName("barrage_radius_ranged")
	
	local duration = self:GetSpecialValueFor("duration")

	--CAST melee barrage:
	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = melee_barrage:entindex(),
		Queue = false,
	})

	-- Moved this code inside barrage_radius_melee. To help with the timing...
	--melee barrage casts, when done it casts ranged barrage

	--cast range barrage after half the spells duration. 
	-- A timer that executes after duration/2 seconds 
	-- Timers:CreateTimer(duration/2, function()
	--   	ExecuteOrderFromTable({
	-- 		UnitIndex = caster:entindex(),
	-- 		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
	-- 		AbilityIndex = ranged_barrage:entindex(),
	-- 		Queue = false,
	-- 	})
	--   return
	-- end)





end