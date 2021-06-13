vortex_grenade_thinker = class({})

function vortex_grenade_thinker:IsHidden()
	return false
end

function vortex_grenade_thinker:IsDebuff()
	return false
end

function vortex_grenade_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function vortex_grenade_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.interval = 0.01
        self.starting_size = 300
        self.end_size = 900
        self.current_size = self.starting_size
        self.max_size_reached = false
        self.end_timer = false

        self.vLocation = Vector(kv.target_x,kv.target_y,kv.target_z)

        self.particle = ParticleManager:CreateParticle("particles/clock/clock_v2_rubick_faceless_void_chronosphere.vpcf", PATTACH_WORLDORIGIN, self.parent)
		ParticleManager:SetParticleControl(self.particle, 0, self.vLocation)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(self.starting_size, self.starting_size, self.starting_size))
        --self:AddParticle(self.particle, false, false, -1, false, false)

        EmitSoundOn( "Hero_FacelessVoid.Chronosphere", self.parent )

        self:StartIntervalThink(self.interval)

        Timers:CreateTimer(1,function()
            if self.end_timer == true then return false end

            if self.particle and self.max_size_reached == false then
                ParticleManager:DestroyParticle(self.particle,true)
            end

            if self.current_size <= self.end_size then

                self.current_size = ( self.current_size / 4 ) + self.current_size

                self.particle = ParticleManager:CreateParticle("particles/clock/clock_v2_rubick_faceless_void_chronosphere.vpcf", PATTACH_WORLDORIGIN, self.parent)
                ParticleManager:SetParticleControl(self.particle, 0, self.vLocation)
                ParticleManager:SetParticleControl(self.particle, 1, Vector(self.current_size, self.current_size, self.current_size))

            elseif self.current_size >= self.end_size and self.max_size_reached == false then
                self.max_size_reached = true
                self.particle = ParticleManager:CreateParticle("particles/clock/clock_v2_rubick_faceless_void_chronosphere.vpcf", PATTACH_WORLDORIGIN, self.parent)
                ParticleManager:SetParticleControl(self.particle, 0, self.vLocation)
                ParticleManager:SetParticleControl(self.particle, 1, Vector(self.end_size, self.end_size, self.end_size))
            end

            return 1
        end)

	end
end
---------------------------------------------------------------------------

function vortex_grenade_thinker:OnIntervalThink()
    if IsServer() then



        local units = FindUnitsInRadius(
            self.parent:GetTeamNumber(),
            self.vLocation,
            nil,
            self.current_size - 80,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false )

        if units ~= nil and #units ~= 0 then
            for _,unit in pairs(units) do
                if unit:GetUnitName() ~= "npc_clock" then
                    unit:AddNewModifier(caster, self, "vortex_prison_modifier",
                    {
                        duration = 0.5
                    })
                end
            end
        end

    end
end
---------------------------------------------------------------------------


function vortex_grenade_thinker:OnDestroy( kv )
    if IsServer() then

        self:OnIntervalThink(-1)

        self.end_timer = true

        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,false)
        end

	end
end
---------------------------------------------------------------------------
