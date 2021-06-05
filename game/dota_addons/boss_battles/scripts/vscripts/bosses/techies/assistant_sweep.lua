assistant_sweep = class({})
LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

function assistant_sweep:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.4)

        self.vTargetPos = nil
		if self:GetCursorTarget() then
			self.vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			self.vTargetPos = self:GetCursorPosition()
        end

        self.vTargetPos = self:GetAbsOrigin() + self:GetCaster():GetForwardVector() * 900

        self.spell_width = 200
        self.start_pos = self:GetAbsOrigin() + self:GetCaster():GetForwardVector() * 250

        local particle = "particles/custom/sirix_mouse/range_finder_cone_nohead.vpcf"
        self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
        ParticleManager:SetParticleControl(self.particleNfx , 1, self.start_pos) -- origin
        ParticleManager:SetParticleControl(self.particleNfx , 2, self.vTargetPos)  -- target
		ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(self.spell_width,self.spell_width,0)) -- line width
		ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function assistant_sweep:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    end
end
---------------------------------------------------------------------------

function assistant_sweep:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self.caster = self:GetCaster()

    EmitSoundOnLocationWithCaster(self.start_pos, "Hero_EarthShaker.Fissure", self.caster)

    -- indicator
    ParticleManager:DestroyParticle(self.particleNfx,true)

    -- spell
    local effect = "particles/techies/techies_lion_spell_impale.vpcf"

    local distance = (self.start_pos - self.vTargetPos):Length2D() - 50

    local tSpawn =
    {
        self.start_pos + ( self.caster:GetRightVector()       *100),
        self.start_pos + self.caster:GetForwardVector()        ,
        self.start_pos - (self.caster:GetRightVector()       *100),
    }

    local num_proj = 3

    -- projectile
    for i = 1, num_proj, 1 do
        local projectile = {
            EffectName = effect,
            vSpawnOrigin = tSpawn[i],
            fDistance = distance,
            fUniqueRadius = self.spell_width/3,
            Source = self.caster,
            vVelocity = self:GetCaster():GetForwardVector() * 1000,
            UnitBehavior = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            --draw = true,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)

                unit:AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "modifier_generic_stunned", -- modifier name
                    { duration = 3 } -- kv
                )

                ApplyDamage({
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage = 150,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self,
                })

                -- play sound
                EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Lion.ImpaleHitTarget", self.caster)

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                local particle_cast = "particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 0, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end,
        }

        Projectiles:CreateProjectile(projectile)
    end
end