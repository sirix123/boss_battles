charge = class({})
LinkLuaModifier("charge_modifier", "player/warrior/charge_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("charge_modifier_aura", "player/warrior/charge_modifier_aura", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function charge:OnSpellStart()

    -- pull spell details from kv file
    local speed = self:GetSpecialValueFor("speed")

    -- setup
    local caster = self:GetCaster()
    local caster_location = caster:GetAbsOrigin()
    local target = self:GetCursorPosition()

    -- calc speed distance direction
    local direction = (target - caster_location):Normalized()

    -- move player to new position 
    caster:SetAbsOrigin(caster_location + (direction * speed))

    --FindClearSpaceForUnit(caster, new_location, false)
    --local new_location = (caster_location + (direction * speed))
end
