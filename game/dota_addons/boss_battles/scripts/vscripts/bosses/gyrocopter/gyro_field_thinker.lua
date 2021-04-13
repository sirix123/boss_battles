gyro_field_thinker = class({})

function gyro_field_thinker:IsHidden()
	return false
end

function gyro_field_thinker:IsDebuff()
	return false
end

function gyro_field_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function gyro_field_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.vLocation = Vector(kv.target_x,kv.target_y,kv.target_z)

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_WORLDORIGIN, self.parent)
		ParticleManager:SetParticleControl(particle, 0, self.vLocation)
		ParticleManager:SetParticleControl(particle, 1, Vector(250, 250, 250))
        self:AddParticle(particle, false, false, -1, false, false)

        EmitSoundOn( "Hero_FacelessVoid.Chronosphere", self.parent )

        self:StartIntervalThink(0.01)

	end
end
---------------------------------------------------------------------------

function gyro_field_thinker:OnIntervalThink()
    if IsServer() then


        local units = FindUnitsInRadius(
            self.parent:GetTeamNumber(),
            self.vLocation,
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false )

        if units ~= nil and #units ~= 0 then
            for _,unit in pairs(units) do
                unit:AddNewModifier(caster, self, "vortex_prison_modifier",
                {
                    duration = 0.5
                })
            end
        end

    end
end
---------------------------------------------------------------------------


function gyro_field_thinker:OnDestroy( kv )
    if IsServer() then

        self:OnIntervalThink(-1)

        if self.effect_cast ~= nil then
            ParticleManager:DestroyParticle(self.effect_cast,false)
        end

	end
end
---------------------------------------------------------------------------
