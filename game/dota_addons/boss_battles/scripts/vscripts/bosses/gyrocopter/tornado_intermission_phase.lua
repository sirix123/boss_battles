tornado_intermission_phase = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

function tornado_intermission_phase:OnAbilityPhaseStart()
    if IsServer() then

        -- play sound
        self:GetCaster():EmitSound("gyrocopter_gyro_cast_02")

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function tornado_intermission_phase:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local caster_origin = caster:GetAbsOrigin()
        self.radius = 100

        local particle = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf"

        local nDirectionsGenerate = RandomInt(5,8)
        local tDirections = {}

        for i = 1, nDirectionsGenerate, 1 do
            table.insert(tDirections,Vector(RandomFloat(-1,1),RandomFloat(-1,1),0))
        end

        for i = 1, #tDirections, 1 do

            local velocity = RandomInt(500,1200)

            local hProjectile = {
                Source = caster,
                Ability = self,
                vSpawnOrigin = caster_origin,
                bDeleteOnHit = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                EffectName = particle,
                fDistance = 3000,
                fStartRadius = self.radius,
                fEndRadius = self.radius,
                vVelocity = tDirections[i] * velocity,
                bHasFrontalCone = false,
                bReplaceExisting = false,
                fExpireTime = GameRules:GetGameTime() + 35.0,
                bProvidesVision = true,
                iVisionRadius = 200,
                iVisionTeamNumber = caster:GetTeamNumber(),
                ExtraData = {
                                direction_x = tDirections[i].x,
                                direction_y = tDirections[i].y,
                                velocity = velocity,
                            }
            }

            ProjectileManager:CreateLinearProjectile(hProjectile)
        end

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function tornado_intermission_phase:OnProjectileHit_ExtraData(hTarget, location, ExtraData)
    if IsServer() then
        if hTarget ~= nil then
            --print("hit target, ",hTarget)
            --print("ExtraData ,",ExtraData)
            --print("ExtraData ,",ExtraData.direction)

            --PrintTable(ExtraData)

            hTarget:AddNewModifier(
                hTarget,
                self,
                "modifier_generic_arc_lua",
                {
                    dir_x = ExtraData.direction_x,
                    dir_y = ExtraData.direction_y,
                    speed = ExtraData.velocity,
                    distance = 1000,
                    height = 300,
                    fix_end = true,
                    isStun = true,
                    activity = ACT_DOTA_FLAIL,
                    isForward = true,
                }
            )

            return true
        end
    end
end
--[[
kv data (default):
-- direction, provide just one (or none for default):
    dir_x/y (forward), for direction
    target_x/y (forward), for target point
-- horizontal motion, provide 2 of 3, duration-only (for vertical arc), or all 3
    speed (0)
    duration (0)
    distance (0): zero means no horizontal motion
-- vertical motion.
    height (0): max height. zero means no vertical motion
    start_offset (0), height offset from ground at start of jump
    end_offset (0), height offset from ground at end of jump
-- arc types
    fix_end (true): if true, landing z-pos is the same as jumping z-pos, not respecting on landing terrain height (Pounce)
    fix_duration (true): if false, arc ends when unit touches ground, not respecting duration (Shield Crash)
    fix_height (true): if false, arc max height depends on jump distance, height provided is max-height (Tree Dance)
-- other
    isStun (false), parent is stunned
    isRestricted (false), parent is command restricted
    isForward (false), lock parent forward facing
    activity (none), activity when leaping]]