function CDOTABaseAbility:GetCastPoint()

    print("running cast point override")
    -- whirling winds handler
    if self:GetCaster():HasModifier("e_whirling_winds_modifier") and self:GetAbilityIndex() == 0 then
        return self:GetCastPoint() - ( self:GetCastPoint() * flWHIRLING_WINDS_CAST_POINT_REDUCTION )
    end
end