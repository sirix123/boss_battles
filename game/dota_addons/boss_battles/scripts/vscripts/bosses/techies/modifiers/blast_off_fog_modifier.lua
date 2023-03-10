blast_off_fog_modifier = class({})

--------------------------------------------------------------------------------
function blast_off_fog_modifier:IsHidden()
	return true
end

function blast_off_fog_modifier:IsDebuff()
	return true
end

--------------------------------------------------------------------------------
function blast_off_fog_modifier:OnCreated(kv)
    if IsServer() then

		--self.reduceFog = -4700
		--self.reduceFog_percent = -90

		self.original_vision_night = self:GetParent():GetBaseNightTimeVisionRange()
		self.original_vision_day = self:GetParent():GetBaseDayTimeVisionRange()

		self:GetParent():SetNightTimeVisionRange(1)
		self:GetParent():SetDayTimeVisionRange(1)

		self:StartIntervalThink(1)

	end
end
--------------------------------------------------------------------------------

function blast_off_fog_modifier:OnIntervalThink()
	self:GetParent():SetNightTimeVisionRange(1)
	self:GetParent():SetDayTimeVisionRange(1)
	--print("self:GetParent():GetBaseNightTimeVisionRange() ", self:GetParent():GetBaseNightTimeVisionRange())
	--print("self:GetParent():GetBaseDayTimeVisionRange() ", self:GetParent():GetBaseDayTimeVisionRange())
	--print("---------------------")
end

function blast_off_fog_modifier:OnDestroy( kv )
    if IsServer() then
		self.original_vision_night = self:GetParent():SetNightTimeVisionRange(self.original_vision_night)
		self.original_vision_day = self:GetParent():SetDayTimeVisionRange(self.original_vision_day)
		--self.reduceFog = 5000
		--self.reduceFog_percent = 100
	end
end

--[[Modifier Effects
function blast_off_fog_modifier:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_DONT_GIVE_VISION_OF_ATTACKER,
	}

	return funcs
end

function blast_off_fog_modifier:GetBonusDayVision()
	return self.reduceFog
end

function blast_off_fog_modifier:GetBonusNightVision()
	return self.reduceFog
end

function blast_off_fog_modifier:GetBonusVisionPercentage ()
	return self.reduceFog_percent
end

function blast_off_fog_modifier:GetModifierNoVisionOfAttacker ()
	return true
end]]

