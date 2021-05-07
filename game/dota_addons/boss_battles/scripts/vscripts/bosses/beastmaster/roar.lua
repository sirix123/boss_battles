roar = class({})

LinkLuaModifier( "modifier_roar", "bosses/beastmaster/modifier_roar", LUA_MODIFIER_MOTION_NONE )

function roar:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.20)

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = self:GetCastPoint() + self:GetSpecialValueFor( "duration" ) } )

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function roar:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)

        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx,true)
        end

    end
end
---------------------------------------------------------------------------

function roar:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    local count = 0

    local distance_particle = 1600
    local distance_find_units = 1600

    local tLocations = {}
    local location = nil
    local currentAngle = 0
    local angleIncrement = 15

    while currentAngle <= 360 do
        location = RotatePosition(caster:GetAbsOrigin(), QAngle(0,currentAngle,0), caster:GetAbsOrigin() + caster:GetForwardVector() * distance_particle  )

        currentAngle = currentAngle + angleIncrement
        table.insert(tLocations,location)
    end

    Timers:CreateTimer(function()
        if IsValidEntity(caster) == false then
            if self.particleNfx then
                ParticleManager:DestroyParticle(self.particleNfx,true)
            end
            return false
        end

        if count == duration then
            if self.particleNfx then
                ParticleManager:DestroyParticle(self.particleNfx,true)
            end
            return false
        end

        self.units = FindUnitsInRadius(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            distance_find_units,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false)

        --DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 64, 2000, true, 0.5) -- melee is red

        for _, location in ipairs(tLocations) do
            local particle = ParticleManager:CreateParticle("particles/beastmaster/beasmtaterbm_shoulder_ti7_roar.vpcf", PATTACH_WORLDORIGIN,nil)
            ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
            ParticleManager:SetParticleControl(particle, 1, location)
            ParticleManager:ReleaseParticleIndex(particle)
        end

        if self.units ~= nil and #self.units ~= 0 then
            for _, unit in pairs(self.units) do
                unit:AddNewModifier(self:GetCaster(), self, "modifier_roar", {duration = 0.2})
                unit:AddNewModifier(self:GetCaster(), self, "modifier_generic_silenced", {duration = 1})
            end
        end

        count = count + 0.5
        return 0.5
    end)
end