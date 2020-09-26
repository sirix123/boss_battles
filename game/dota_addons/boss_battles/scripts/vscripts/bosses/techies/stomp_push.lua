stomp_push = class({})

LinkLuaModifier( "modifier_stomp_push", "bosses/techies/modifiers/modifier_stomp_push", LUA_MODIFIER_MOTION_NONE )

function stomp_push:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        self.units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            250,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if self.units == nil or #self.units == 0 then
            return false
        end

        local radius = 250
		self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
        ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function stomp_push:OnSpellStart()
    if not IsServer() then return end

    local ability = self

    for _, unit in pairs(self.units) do
        EmitSoundOn("DOTA_Item.ForceStaff.Activate", unit)
        unit:AddNewModifier(self:GetCaster(), ability, "modifier_stomp_push", {duration = 1})
    end
end