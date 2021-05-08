gyro_homing_missile_stun_check = class({})

function gyro_homing_missile_stun_check:IsHidden()
	return false
end

function gyro_homing_missile_stun_check:IsDebuff()
	return false
end

function gyro_homing_missile_stun_check:IsPurgable()
	return false
end

---------------------------------------------------------------------------

function gyro_homing_missile_stun_check:OnCreated( kv )
    if IsServer() then

        self:IncrementStackCount()

	end
end
---------------------------------------------------------------------------

function gyro_homing_missile_stun_check:OnRefresh( kv )
    if IsServer() then

        self:IncrementStackCount()

	end
end
---------------------------------------------------------------------------

function gyro_homing_missile_stun_check:OnDestroy( kv )
    if IsServer() then

	end
end
---------------------------------------------------------------------------