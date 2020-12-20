green_cube_on_attacked = class({})
-----------------------------------------------------------------------------

function green_cube_on_attacked:RemoveOnDeath()
    return true
end

function green_cube_on_attacked:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function green_cube_on_attacked:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function green_cube_on_attacked:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACKED,
        }
        return funcs
end


function green_cube_on_attacked:OnAttacked( params )
    if not IsServer() then return nil end

    if params.attacker:GetUnitName() == "npc_guard" then
        self:GetParent():ForceKill(false)
    end

end

