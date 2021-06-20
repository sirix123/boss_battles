r_blade_vortex = class({})
LinkLuaModifier( "r_blade_vortex_thinker", "player/warlord/modifiers/r_blade_vortex_thinker", LUA_MODIFIER_MOTION_NONE )

function r_blade_vortex:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

        self.caster = self:GetCaster()
        local find_radius = 150
        local vTargetPos = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            vTargetPos,
            nil,
            find_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false)

        if #units == 0 or units == nil then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
            return false
        end

        if CheckGlobalUnitTableForUnitName(units[1]) == true then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
            return false
        end

        if #units ~= 0 and units ~= nil then

            -- start casting animation
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.5)

            self.target = units[1]

            -- add casting modifier
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
            })

            return true
        end
    end
end
---------------------------------------------------------------------------

function r_blade_vortex:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_blade_vortex:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("radius")

        --local vTargetPos = nil
        --vTargetPos = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        -- sound effect
        caster:EmitSound("Hero_LegionCommander.Overwhelming.Location")

        self.target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "r_blade_vortex_thinker", -- modifier name
            { duration = self:GetSpecialValueFor( "duration" )} -- kv
        )

        --[[CreateModifierThinker(
            caster,
            self,
            "r_blade_vortex_thinker",
            {
                duration = self:GetSpecialValueFor( "duration" ),
                target_x = vTargetPos.x,
                target_y = vTargetPos.y,
                target_z = vTargetPos.z,
            },
            vTargetPos,
            caster:GetTeamNumber(),
            false
        )]]

    end
end
---------------------------------------------------------------------------

