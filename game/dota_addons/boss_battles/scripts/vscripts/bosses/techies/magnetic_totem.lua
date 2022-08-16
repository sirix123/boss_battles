magnetic_totem = class({})

function magnetic_totem:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.4)

        local particle = "particles/techies/techies_earthshaker_totem_ti6_buff.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle, PATTACH_POINT_FOLLOW, self:GetCaster() )

        local attach = "attach_attack1"
        if self:GetCaster():ScriptLookupAttachment( "attach_totem" )~=0 then attach = "attach_totem" end
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            0,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            attach,
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function magnetic_totem:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

    end
end
---------------------------------------------------------------------------

function magnetic_totem:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
    local caster = self:GetCaster()
    local mines_to_pull = {}
    local particles = {}

    EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_EarthShaker.Totem.Cast", caster)

    local particle = "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_blur_impact.vpcf"
    self.nFXIndex_1 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN , caster  )
	ParticleManager:SetParticleControl(self.nFXIndex_1, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_1, 1, Vector(200, 1, 1))
	ParticleManager:SetParticleControl(self.nFXIndex_1, 3, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.nFXIndex_1)

    -- find x mines (far away)
        -- give them some particle effect as they move ()
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        8000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_FARTHEST,
        false)

    local count = 0
    if units ~= nil and #units ~= 0 then
        for _, unit in pairs(units) do
            if unit:GetUnitName() == "npc_imba_techies_land_mines" and count < 3 then
                table.insert(mines_to_pull,unit)

                local particle_mine = "particles/techies/techies_earthshaker_totem_ti6_buff.vpcf"
                self.effect_cast_mine = ParticleManager:CreateParticle( particle_mine, PATTACH_POINT_FOLLOW, unit )
                ParticleManager:SetParticleControl(self.effect_cast_mine, 0, unit:GetAbsOrigin())

                table.insert(particles,self.effect_cast_mine)

                count = count + 1
            elseif count >= 4 then
                break
            end
        end
    end

    Timers:CreateTimer(1, function ()
        if mines_to_pull ~= nil and #mines_to_pull ~= 0 then
            for _, mine in pairs(mines_to_pull) do

                self.arc = mine:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "modifier_generic_arc_lua", -- modifier name
                    {
                        target_x = caster:GetAbsOrigin().x + RandomInt(-100, 100),
                        target_y = caster:GetAbsOrigin().y + RandomInt(-100, 100),
                        speed = 1800,
                        height = 250,
                        distance = ( caster:GetAbsOrigin() - mine:GetAbsOrigin() ):Length2D(),
                        fix_end = true,
                        fix_height = false,
                        isStun = true,
                    } -- kv
                )
            end
        end

        self.arc:SetEndCallback( function()

            if particles ~= nil and #particles ~= 0 then
                for _, particle_mine in pairs(particles) do
                    if particle_mine then
                        ParticleManager:DestroyParticle(particle_mine,true)
                    end
                end
            end

        end)

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

        return false
    end)


end