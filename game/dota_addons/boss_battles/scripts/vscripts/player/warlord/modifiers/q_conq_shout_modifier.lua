q_conq_shout_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_conq_shout_modifier:IsHidden()
	return false
end

function q_conq_shout_modifier:IsDebuff()
	return false
end

function q_conq_shout_modifier:IsPurgable()
	return false
end

function q_conq_shout_modifier:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function q_conq_shout_modifier:OnCreated( kv )
    if IsServer() then
    end
end

function q_conq_shout_modifier:OnRefresh( kv )
    if IsServer() then

    end
end

function q_conq_shout_modifier:OnDestroy( kv )
    if IsServer() then

    end
end
