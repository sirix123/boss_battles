attack_interupt = class({})

function attack_interupt:IsHidden()
	return false
end

function attack_interupt:IsDebuff()
	return false
end

function attack_interupt:IsPurgable()
	return false
end

---------------------------------------------------------------------------

function attack_interupt:OnCreated( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

function attack_interupt:OnDestroy( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

-- Effect
function attack_interupt:OnTakeDamage( params )
    if IsServer() then
        if params.unit == self:GetParent() then
            self:Destroy()
        end
    end
end

--------------------------------------------------------------------------------
function attack_interupt:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end