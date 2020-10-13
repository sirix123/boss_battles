
cast_electric_field = class({})

-----------------------------------------------------------------------------

function cast_electric_field:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function cast_electric_field:OnCreated(  )
    if IsServer() then
    end
end

function cast_electric_field:OnDestroy()
    if IsServer() then

    end
end

