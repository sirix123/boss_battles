phase_1_fog = class({})

--------------------------------------------------------------------------------
function phase_1_fog:IsHidden()
	return false
end

function phase_1_fog:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function phase_1_fog:OnCreated(kv)
    if IsServer() then

		self.reduceFog = -4000
		self.reduceFog_percent = -80

		self.original_vision_night = self:GetParent():GetBaseNightTimeVisionRange()
		self.original_vision_day = self:GetParent():GetBaseDayTimeVisionRange()

		self:GetParent():SetNightTimeVisionRange(1)
		self:GetParent():SetDayTimeVisionRange(1)

	end
end
--------------------------------------------------------------------------------

function phase_1_fog:OnDestroy( kv )
    if IsServer() then
		self.original_vision_night = self:GetParent():SetNightTimeVisionRange(self.original_vision_night)
		self.original_vision_day = self:GetParent():SetDayTimeVisionRange(self.original_vision_day)
		self.reduceFog = 5000
		self.reduceFog_percent = 100
	end
end

-- Modifier Effects
function phase_1_fog:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
	}

	return funcs
end

function phase_1_fog:GetBonusDayVision()
	return self.reduceFog
end

function phase_1_fog:GetBonusNightVision()
	return self.reduceFog
end

function phase_1_fog:GetBonusVisionPercentage ()
	return self.reduceFog_percent
end

