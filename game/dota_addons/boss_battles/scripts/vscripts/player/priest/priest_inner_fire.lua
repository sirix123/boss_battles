priest_inner_fire = class({})
LinkLuaModifier("priest_inner_fire_modifier", "player/priest/modifiers/priest_inner_fire_modifier", LUA_MODIFIER_MOTION_NONE)

function priest_inner_fire:OnAbilityPhaseStart()
    if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if units == nil or #units == 0 then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
            return false
        else

            self.target = units[1]

            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

            local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf"
            local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControlEnt(particle_cast_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(particle_cast_fx, 1, self.target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)

            return true
        end
    end
end
---------------------------------------------------------------------------

function priest_inner_fire:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

    end
end
---------------------------------------------------------------------------

function priest_inner_fire:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )

        self.modifier = self.target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "priest_inner_fire_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------
