modifier_gyro_barrage_debuff = class({})

--------------------------------------------------------------------------------
function modifier_gyro_barrage_debuff:IsHidden()
	return false
end

function modifier_gyro_barrage_debuff:IsDebuff()
	return true
end

function modifier_gyro_barrage_debuff:GetTexture()
	return "gyrocopter_rocket_barrage"
end

--------------------------------------------------------------------------------
function modifier_gyro_barrage_debuff:OnCreated(kv)
end
function modifier_gyro_barrage_debuff:OnDestroy( kv )
end
