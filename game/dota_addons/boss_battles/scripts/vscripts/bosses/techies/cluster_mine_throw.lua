

-- todo
--[[
    cast range x amount
    largeish aoe
    find x points in aoe
    launch x bombs (create thinkers?)
]]

cluster_mine_throw = class({})

LinkLuaModifier( "cluster_mine_throw_thinker", "bosses/techies/modifiers/cluster_mine_throw_thinker", LUA_MODIFIER_MOTION_NONE )

function cluster_mine_throw:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function cluster_mine_throw:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

        local delay = 0.1
        local point = Vector(0,0,0)

        local max_mines = self:GetSpecialValueFor( "max_mines" )
        local radius = self:GetSpecialValueFor( "radius" )

        self.triggerRadius = self:GetSpecialValueFor( "triggerRadius" )
        self.explosion_delay = self:GetSpecialValueFor( "explosion_delay" )
        self.damage = self:GetSpecialValueFor( "damage" )
        self.activationTime = self:GetSpecialValueFor( "activationTime" )
        self.explosion_range = self:GetSpecialValueFor( "explosion_range" )

        -- find a random point inside the map arena (cell)
        --local vTargetPos = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z) -- for testing
        local vTargetPos = self:GetCursorPosition()
        --print("self:GetCursorPosition() ",self:GetCursorPosition())
        --DebugDrawCircle(vTargetPos, Vector(0,255,0), 128, 100, true, 60)
        --print(vTargetPos)

        self:GetCaster():SetForwardVector(vTargetPos)
        self:GetCaster():FaceTowards(vTargetPos)

        -- play sound
        EmitSoundOnLocationWithCaster(vTargetPos,"Hero_Techies.LandMine.Plant",caster)

        local i = 0
        Timers:CreateTimer(delay, function()
            if IsValidEntity(self:GetCaster()) == false then return false end
            if i == max_mines then
                return false
            end

            -- get some random points around the intial cast point
            point.x = RandomInt(vTargetPos.x - radius, vTargetPos.x + radius)
            point.y = RandomInt(vTargetPos.y - radius, vTargetPos.y + radius)

            point = Vector(point.x,point.y,vTargetPos.z)
            --DebugDrawCircle(point, Vector(0,0,255), 128, 20, true, 60)

            local land_mine = CreateUnitByName("npc_dota_techies_land_mine", point, true, self:GetCaster(), self:GetCaster():GetOwner(), caster:GetTeamNumber())

            --unit:AddNewModifier( self:GetCaster(), self, "bear_bloodlust_modifier", { duration = -1, as_bonus = 10, ms_bonus = 10 } )

            land_mine:AddNewModifier(caster, self, "cluster_mine_throw_thinker",
            {
                target_x = point.x,
                target_y = point.y,
                target_z = point.z,
                triggerRadius = self.triggerRadius,
                explosion_delay = self.explosion_delay,
                damage = self.damage,
                activationTime = self.activationTime,
                explosion_range = self.explosion_range,
            })

            --[[CreateModifierThinker(
                caster,
                self,
                "cluster_mine_throw_thinker",
                {
                    target_x = point.x,
                    target_y = point.y,
                    target_z = point.z,
                    triggerRadius = self.triggerRadius,
                    explosion_delay = self.explosion_delay,
                    damage = self.damage,
                    activationTime = self.activationTime,
                    explosion_range = self.explosion_range,
                },
                land_mine:GetAbsOrigin(),
                caster:GetTeamNumber(),
                false)]]

            i = i  +  1
            return delay
        end)
    end
end