q_arcane_cage = class({})
LinkLuaModifier("q_arcane_cage_modifier", "player/templar/modifiers/q_arcane_cage_modifier", LUA_MODIFIER_MOTION_NONE)

function q_arcane_cage:OnAbilityPhaseStart()
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

            if self.target:GetUnitName() == "npc_dota_hero_huskar" then
                local playerID = self:GetCaster():GetPlayerID()
                local player = PlayerResource:GetPlayer(playerID)
                CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
                return false
            else
                self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

                return true

            end
        end
    end
end
---------------------------------------------------------------------------

function q_arcane_cage:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

    end
end

---------------------------------------------------------------------------

function q_arcane_cage:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()

        self.target:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "q_arcane_cage_modifier", -- modifier name
            {duration = self:GetSpecialValueFor( "duration" )} -- kv
        )

        -- sound
        EmitSoundOnLocationWithCaster(self.target:GetAbsOrigin(), "Hero_Huskar.Inner_Fire.Cast", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------
