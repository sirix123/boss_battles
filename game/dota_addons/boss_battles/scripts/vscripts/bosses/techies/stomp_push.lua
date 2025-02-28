stomp_push = class({})

LinkLuaModifier( "modifier_stomp_push", "bosses/techies/modifiers/modifier_stomp_push", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stomp_pull", "bosses/techies/modifiers/modifier_stomp_pull", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "assistant_enchant_totem", "bosses/techies/modifiers/assistant_enchant_totem", LUA_MODIFIER_MOTION_NONE )

function stomp_push:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.20)

        self.radius = 550
        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self.radius, -self.radius, -self.radius ) )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
        ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

        -- play voice line
        EmitSoundOn("warlock_golem_wargol_laugh_02", self:GetCaster())

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function stomp_push:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)

    end
end
---------------------------------------------------------------------------

function stomp_push:OnSpellStart()
    if not IsServer() then return end

    local ability = self

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    self.units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),	-- int, your team number
        self:GetCaster():GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, Vector(350, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)

    -- play blinding light sound
    EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(),"Hero_KeeperOfTheLight.BlindingLight",self:GetCaster())

    if self.units == nil or #self.units == 0 then
        --play anger voice line
        --EmitSoundOn("warlock_golem_wargol_laugh_02", self:GetCaster())
    end

    if self.units ~= nil or #self.units ~= 0 then
        for _, unit in pairs(self.units) do
            EmitSoundOn("DOTA_Item.ForceStaff.Activate", unit)


            -- unit:AddNewModifier(self:GetCaster(), ability, "modifier_stomp_push", {duration = 1})
            --unit:AddNewModifier(self:GetCaster(), ability, "modifier_stomp_pull", {duration = 1})

            local distance = 900
            local knockback =
            {
                should_stun = false,
                knockback_duration = 0.5,
                duration = 0.5,
                knockback_distance = distance,
                knockback_height = 0,
                center_x = self:GetCaster():GetAbsOrigin().x,
                center_y = self:GetCaster():GetAbsOrigin().y,
                center_z = self:GetCaster():GetAbsOrigin().z
            }
            unit:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)
        end
    end

    self:GetCaster():AddNewModifier(self:GetCaster(), ability, "assistant_enchant_totem", {duration = 30})

end

-- local distance = radius - (target:GetAbsOrigin() - vPos):Length2D()
-- local knockback =
-- 	{
-- 		should_stun = false,
-- 		knockback_duration = 0.3,
-- 		duration = 0.3,
-- 		knockback_distance = distance,
-- 		knockback_height = 0,
-- 		center_x = vPos.x,
-- 		center_y = vPos.y,
-- 		center_z = vPos.z
-- 	}
-- target:AddNewModifier(caster, self, "modifier_knockback", knockback)