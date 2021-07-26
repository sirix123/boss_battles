gyro_rocket_modifier = class({})

--------------------------------------------------------------------------------
function gyro_rocket_modifier:IsHidden()
	return false
end

function gyro_rocket_modifier:IsDebuff()
	return true
end

function gyro_rocket_modifier:GetTexture()
	return "gyrocopter_homing_missile"
end

--------------------------------------------------------------------------------
function gyro_rocket_modifier:OnCreated(kv)
end
function gyro_rocket_modifier:OnDestroy( kv )
end
