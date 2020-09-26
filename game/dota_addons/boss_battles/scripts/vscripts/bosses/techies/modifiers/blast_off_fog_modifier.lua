blast_off_fog_modifier = class({})

--------------------------------------------------------------------------------
function blast_off_fog_modifier:IsHidden()
	return false
end

--------------------------------------------------------------------------------
function blast_off_fog_modifier:OnCreated(kv)
    --if IsServer() then

        self.reduceFog = -4900

	--end
end
--------------------------------------------------------------------------------

function blast_off_fog_modifier:OnDestroy( kv )
    --if IsServer() then

	--end
end

-- Modifier Effects
function blast_off_fog_modifier:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}

	return funcs
end

function blast_off_fog_modifier:GetBonusDayVision()
	return self.reduceFog
end

function blast_off_fog_modifier:GetBonusNightVision()
	return self.reduceFog
end

