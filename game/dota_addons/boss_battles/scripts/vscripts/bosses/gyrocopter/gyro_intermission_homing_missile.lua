
gyro_intermission_homing_missile = class({})
LinkLuaModifier( "homing_missile_modifier", "bosses/gyrocopter/homing_missile_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "homing_missile_modifier_preflight", "bosses/gyrocopter/homing_missile_modifier_preflight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "gyro_homing_missile_stun_check", "bosses/gyrocopter/gyro_homing_missile_stun_check", LUA_MODIFIER_MOTION_NONE )

function gyro_intermission_homing_missile:Precache(context)
    PrecacheResource( "particle", "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_homing_missile_fuse.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_homing_missile_target.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_homing_missile.vpcf", context )
end

function gyro_intermission_homing_missile:OnAbilityPhaseStart()
    if IsServer() then

        print("we starting to cast hgominh missile?")

        self.responses =
        {
            "gyrocopter_gyro_homing_missile_fire_02",
            "gyrocopter_gyro_homing_missile_fire_03",
            "gyrocopter_gyro_homing_missile_fire_04",
            "gyrocopter_gyro_homing_missile_fire_06",
            "gyrocopter_gyro_homing_missile_fire_07"
        }

        EmitSoundOnClient(self.responses[RandomInt(1, #self.responses)], self:GetCaster():GetPlayerOwner())

        return true
    end
end
---------------------------------------------------------------------------

function gyro_intermission_homing_missile:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
---------------------------------------------------------------------------

function gyro_intermission_homing_missile:OnSpellStart()
	if IsServer() then

        self.pre_flight_time = self:GetSpecialValueFor("pre_flight_time")

        self.GyroIntermissionLocations = {
            Vector(-13282,178,132),
            Vector(-13716,916,132),
            Vector(-13551,1932,132),
            Vector(-13495,2593,132),
            Vector(-12857,2991,132),
            Vector(-11795,2980,132),
            Vector(-11071,2720,132),
            Vector(-10966,1806,132),
            Vector(-11048,985,132),
            Vector(-10939,152,132),
            Vector(-12093,206,132),
        }

        self.starting_position = self.GyroIntermissionLocations[RandomInt(1,#self.GyroIntermissionLocations)]

        -- find targets for missile, create one for each player
        -- remeber to pass the entindex into the modifier
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            5000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD,
            FIND_CLOSEST,
            false )

        if #enemies ~= 0 and enemies ~= nil then
            for _, enemy in pairs(enemies) do
                local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", self.starting_position, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
                missile:AddNewModifier(self:GetCaster(), self, "homing_missile_modifier_preflight", {duration = self.pre_flight_time, target = enemy:GetEntityIndex()})
                missile:AddNewModifier(self:GetCaster(), self, "homing_missile_modifier", {duration = -1, target = enemy:GetEntityIndex()})
                missile:SetModelScale(1.5)
                missile:AddNewModifier( self:GetCaster(), self, "modifier_remove_healthbar", { duration = -1 } )
                missile:AddNewModifier( self:GetCaster(), self, "modifier_phased", { duration = -1 })
                missile:AddNewModifier( self:GetCaster(), self, "modifier_invulnerable", { duration = -1 })

                local fuse_particle = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_homing_missile_fuse.vpcf", PATTACH_ABSORIGIN, missile)
                ParticleManager:SetParticleControlForward(fuse_particle, 0, missile:GetForwardVector() * (-1))
                ParticleManager:ReleaseParticleIndex(fuse_particle)
            end
        end
	end
end
---------------------------------------------------------------------------
