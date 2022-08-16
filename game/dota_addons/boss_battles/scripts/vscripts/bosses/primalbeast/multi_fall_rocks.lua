multi_fall_rocks = class({})
LinkLuaModifier( "primal_circle_target_iceshot", "bosses/primalbeast/modifiers/primal_circle_target_iceshot", LUA_MODIFIER_MOTION_NONE )

function multi_fall_rocks:OnAbilityPhaseStart()
    if IsServer() then

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function multi_fall_rocks:OnSpellStart()
    if IsServer() then

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        local max_proj = 20
        local max_waves = 3
        local nWave = 0
        local previous_angle = 0.0

        Timers:CreateTimer(function()
            if IsValidEntity(self:GetCaster()) == false then return false end

            if nWave == max_waves then return false end

            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.2)
            self.sound_cast = "Hero_EarthShaker.Gravelmaw.Cast"
            EmitSoundOn(self.sound_cast, caster)

            nProj = 0
            local angle = RandomFloat(-1,1)

            local angle_delta =  math.abs(angle - previous_angle)
            while angle_delta < 0.4 do
                angle = RandomFloat(-1,1)
                angle_delta =  math.abs(angle - previous_angle)
            end

            local face_point_x = origin.x + 600 * math.cos(angle)
            local face_point_y = origin.y + 600 * math.sin(angle)
            local face_point = Vector(face_point_x,face_point_y , origin.z+10)

            Timers:CreateTimer(2, function()
                if IsValidEntity(self:GetCaster()) == false then return false end

                if nProj == max_proj then return false end

                angle = angle + RandomFloat(-0.3,0.3)

                local radius = 1000
                local cone_radius = RandomFloat(0,1) * radius
                local x = origin.x + cone_radius * math.cos(angle)
                local y = origin.y + cone_radius * math.sin(angle)

                local point = Vector(x,y,origin.z)

                CreateModifierThinker(
                    caster,
                    self,
                    "multi_fall_rocks_modifier",
                    {
                        duration = self:GetSpecialValueFor( "duration" ),
                        radius = self:GetSpecialValueFor( "radius" ),
                        damage = self:GetSpecialValueFor( "damage" ),
                    },
                    point,
                    caster:GetTeamNumber(),
                    false
                )

                CreateModifierThinker(
                    caster, -- player source
                    self, -- ability source
                    "primal_circle_target_iceshot", -- modifier name
                    {
                        duration = self:GetSpecialValueFor( "duration" ),
                        radius = self:GetSpecialValueFor( "radius" ),
                    },
                    point,
                    caster:GetTeamNumber(),
                    false
                )

                nProj = nProj + 1

                return 0.005
            end)

            self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2) --RemoveGesture

            nWave = nWave + 1
            previous_angle = angle

            return (max_proj * 0.005) + 1 --+ 2
        end)
	end
end
------------------------------------------------------------------------------------------------