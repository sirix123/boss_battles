
beastmaster_mark_modifier = class({})


-----------------------------------------------------------------------------
function beastmaster_mark_modifier:IsDebuff()
	return true
end

-----------------------------------------------------------------------------
function beastmaster_mark_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------
function beastmaster_mark_modifier:GetEffectName()
	return "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_target.vpcf"
end


