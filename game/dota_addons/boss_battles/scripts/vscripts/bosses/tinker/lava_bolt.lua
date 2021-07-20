
lava_bolt = class({})
LinkLuaModifier( "lava_bolt_modifier_stacks", "bosses/tinker/modifiers/lava_bolt_modifier_stacks", LUA_MODIFIER_MOTION_NONE  )

function lava_bolt:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function lava_bolt:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
---------------------------------------------------------------------------

function lava_bolt:OnSpellStart()
	if IsServer() then

        --local particle = "particles/custom/sirix_mouse/range_finder_cone.vpcf"

        local particle = "particles/tinker/tinker_lava_overhead.vpcf"
        self.overhead = ParticleManager:CreateParticle( particle, PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( self.overhead, 0, self:GetCaster():GetAbsOrigin())

        self.num_balls = nil
        if self:GetCaster():HasModifier("lava_bolt_modifier_stacks") then
            self.num_balls = self:GetCaster():FindModifierByName("lava_bolt_modifier_stacks"):GetStackCount()
        end

        if self.num_balls == 0 or self.num_balls == nil then
            self.num_balls = 20
        end

        --self.num_balls = 50
        --tinker_tink_attack_15

        local sound_random = math.random(1,15)
        if sound_random <= 9 then
            self:GetCaster():EmitSound("tinker_tink_attack_0"..sound_random)
        else
            self:GetCaster():EmitSound("tinker_tink_attack_"..sound_random)
        end

		self.balls = {}
		local direction = Vector(0,0,GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()).z )
		local randomVectorDirection = Vector(0,0,0)

		for i = 1, self.num_balls, 1 do

			self.ball_data = {}

			--[[self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
			ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(40,40,0)) -- line width
			ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour]]

            direction = RandomVector(1):Normalized()

			self.distance = self:GetCaster():GetAbsOrigin() + direction * 300

			--ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
			--ParticleManager:SetParticleControl(self.particleNfx , 2, self.distance)  -- target

			--[[local portal_particle = "particles/econ/items/weaver/weaver_immortal_ti6/weaver_immortal_ti6_shukuchi_portal.vpcf"
			self.particleNfx_portal = ParticleManager:CreateParticle(portal_particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(self.particleNfx_portal , 0, self:GetCaster():GetAbsOrigin())]]

			self.ball_data["direction"] = direction
			self.ball_data["particle_index"] = self.particleNfx
            self.ball_data["distance"] = self.distance
			--self.ball_data["particleNfx_portal"] = self.particleNfx_portal

			table.insert(self.balls,self.ball_data)
		end

        --[[Timers:CreateTimer(function()

            for _, value in ipairs(self.balls) do
                ParticleManager:SetParticleControl(value["particle_index"] , 1, self:GetCaster():GetAbsOrigin()) -- origin

                self.distance = self:GetCaster():GetAbsOrigin() + value["direction"] * 300
                ParticleManager:SetParticleControl(value["particle_index"] , 2, self.distance)  -- target
            end

            return 0.03
        end)]]

        Timers:CreateTimer(3,function() 
            --[[for _, value in ipairs(self.balls) do
                ParticleManager:DestroyParticle(value["particle_index"], true)
                --ParticleManager:DestroyParticle(value["particleNfx_portal"], true)
            end]]

            local radius = self:GetSpecialValueFor("radius")
            local projectile_speed = self:GetSpecialValueFor("ball_speed")
            local caster = self:GetCaster()
            local offset = 150

            local i = 1
            Timers:CreateTimer(function()

                if i == #self.balls then
                    if self.overhead then
                        ParticleManager:DestroyParticle(self.overhead, true)
                    end
                    return false
                end

                local origin = caster:GetAbsOrigin()

                local projectile_direction = self.balls[i].direction
                local projectile = {
                    EffectName = "particles/tinker/tinker_invoker_forged_spirit_projectile.vpcf",
                    vSpawnOrigin = origin + projectile_direction * offset,
                    fDistance = self:GetSpecialValueFor("distance"),
                    fStartRadius = radius,
                    fEndRadius = radius,
                    Source = caster,
                    vVelocity = projectile_direction * projectile_speed,
                    UnitBehavior = PROJECTILES_DESTROY,
                    bMultipleHits = false,
                    TreeBehavior = PROJECTILES_NOTHING,
                    WallBehavior = PROJECTILES_DESTROY,
                    GroundBehavior = PROJECTILES_NOTHING,
                    fGroundOffset = 80,
                    draw = false,
                    --bZCheck = false,
                    UnitTest = function(_self, unit)

                        if unit:GetUnitName() == "npc_dota_thinker" or CheckGlobalUnitTableForUnitName(unit) == true or unit:GetTeamNumber() == caster:GetTeamNumber() then
                            return false
                        else
                            return true
                        end

                    end,
                    OnUnitHit = function(_self, unit)

                        local dmgTable = {
                            victim = unit,
                            attacker = caster,
                            damage = self:GetSpecialValueFor("damage"),
                            damage_type = self:GetAbilityDamageType(),
                            ability = self,
                        }

                        ApplyDamage(dmgTable)

                        EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_Crystal.projectileImpact", self.caster)
                    end,
                    OnWallHit = function(_self, gnvPos)

                    end,
                    OnFinish = function(_self, pos)

                        local particle_cast = "particles/units/heroes/hero_invoker/invoker_forged_spirit_projectile_explosion.vpcf"
                        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                        ParticleManager:SetParticleControl(effect_cast, 3, pos)
                        ParticleManager:ReleaseParticleIndex(effect_cast)

                        EmitSoundOnLocationWithCaster(pos, "hero_Crystal.projectileImpact", self.caster)

                    end,
                }

                Projectiles:CreateProjectile(projectile)

                i = i + 1
                return 0.08
            end)

            return false
        end)
	end
end
---------------------------------------------------------------------------