
summon_bear = class({})

--------------------------------------------------------------------------------

function summon_bear:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

-- make some sounds when beastmaster summons the animals
function summon_bear:OnAbilityPhaseStart()

end

--------------------------------------------------------------------------------

function summon_bear:OnSpellStart()
	if IsServer() then
		
		
	end
end
