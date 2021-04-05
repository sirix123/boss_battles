barrage = class({})

-- barrage is an ability which does the two below abilities in succession; barrage_radius_melee and barrage_radius_ranged
--TODO: v2, allow it to cast melee or ranged first. 
function barrage:OnSpellStart()
	_G.IsGyroBusy = true
	local caster = self:GetCaster()


	local melee_barrage = caster:FindAbilityByName("barrage_radius_melee")
	local ranged_barrage = caster:FindAbilityByName("barrage_radius_ranged")
	
	--CAST melee barrage:
	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = melee_barrage:entindex(),
		Queue = false,
	})
	--once melee barrage finishes it will cast ranged barrage if this is set.
	_G.castRangeBarrageOnFinish = true

end