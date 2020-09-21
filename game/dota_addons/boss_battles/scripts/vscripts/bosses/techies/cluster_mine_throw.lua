

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
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function cluster_mine_throw:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        local delay = 0.1
        local point = Vector(0,0,0)

        local max_mines = self:GetSpecialValueFor( "max_mines" )
        local radius = self:GetSpecialValueFor( "radius" )

        self.triggerRadius = self:GetSpecialValueFor( "triggerRadius" )
        self.explosion_delay = self:GetSpecialValueFor( "explosion_delay" )
        self.damage = self:GetSpecialValueFor( "damage" )
        self.activationTime = self:GetSpecialValueFor( "activationTime" )
        self.explosion_range = self:GetSpecialValueFor( "explosion_range" )

        -- find a random point inside the map arena
        local vTargetPos = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z) -- for testing
        --local vTargetPos = Vector(Rand)

        local i = 0
        Timers:CreateTimer(delay, function()

            if i == max_mines then
                return false
            end

            -- get some random points around the intial cast point
            point.x = RandomInt(vTargetPos.x - radius, vTargetPos.x + radius)
            point.y = RandomInt(vTargetPos.y - radius, vTargetPos.y + radius)

            point = Vector(point.x,point.y,0)

            local land_mine = CreateUnitByName("npc_dota_techies_land_mine", point, true, self:GetCaster(), self:GetCaster():GetOwner(), caster:GetTeamNumber())

            CreateModifierThinker(
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
                false)

            i = i  +  1
            return delay
        end)
    end
end