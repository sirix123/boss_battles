oil_leak_modifier = class({})
LinkLuaModifier( "oil_leak_modifier_thinker", "bosses/techies/modifiers/oil_leak_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Classifications
function oil_leak_modifier:IsHidden()
	return false
end

function oil_leak_modifier:IsDebuff()
	return false
end

function oil_leak_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function oil_leak_modifier:OnCreated( kv )
    if not IsServer() then return end

    self.parent = self:GetParent()

   --_G.tOilLeaks = {}

    self.thinkInterval = 5
    self:StartIntervalThink( self.thinkInterval )

end

function oil_leak_modifier:OnRefresh( kv )
	if not IsServer() then return end

end

function oil_leak_modifier:OnRemoved()
	if not IsServer() then return end

end

function oil_leak_modifier:OnDestroy()
	if not IsServer() then return end

end
--------------------------------------------------------------------------------

function oil_leak_modifier:OnIntervalThink()
    if not IsServer() then return end

    -- every interval create an oil slick at bosses feet
    CreateModifierThinker(
        self:GetParent(),
        self,
        "oil_leak_modifier_thinker",
        {
            duration = 30,
        },
        self.parent:GetAbsOrigin(),
        self:GetParent():GetTeamNumber(),
        false )

    --table.insert( self.tOilLeaks, self.oil_slick_thinker)

end
