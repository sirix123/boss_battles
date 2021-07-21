
puddle_projectile_spell = class({})
LinkLuaModifier( "puddle_projectile_spell_player_dot_debuff", "bosses/beastmaster/puddle_projectile_spell_player_dot_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "puddle_projectile_spell_beastmaster_buff", "bosses/beastmaster/puddle_projectile_spell_beastmaster_buff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function puddle_projectile_spell:OnAbilityPhaseStart()
    if IsServer() then

        -- soudn
        self:GetCaster():AddNewModifier( nil, nil, "modifier_rooted", { duration = -1 } )
        -- animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_VICTORY, 2.0)

        if Beastmaster_Puddles_Locations then
            return true
        else
            return false
        end
    end
end

function puddle_projectile_spell:OnAbilityPhaseInterrupted()
	if IsServer() then

        -- soudn

        if self:GetCaster():HasModifier("modifier_rooted") then
			self:GetCaster():RemoveModifierByName("modifier_rooted")
		end

        -- animation
        self:GetCaster():RemoveGesture(ACT_DOTA_VICTORY)
	end
end

function puddle_projectile_spell:OnChannelFinish(bInterrupted)
	if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_VICTORY)

        if self:GetCaster():HasModifier("modifier_rooted") then
			self:GetCaster():RemoveModifierByName("modifier_rooted")
		end

	end
end


function puddle_projectile_spell:OnSpellStart()
	if IsServer() then

        -- soudn

        -- animation

		local caster = self:GetCaster()
        local radius = 150

        for _, spawn_location in pairs(Beastmaster_Puddles_Locations) do
            if spawn_location then

                local info = {
                    EffectName = "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf",
                    Ability = self,
                    iMoveSpeed = 1000,
                    Source = spawn_location,
                    Target = caster,
                    bDodgeable = false,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                    bProvidesVision = true,
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                    iVisionRadius = 300,
                }

                ProjectileManager:CreateTrackingProjectile( info )

                --[[local projectile_speed = RandomInt(200,600)
                local direction = (self:GetCaster():GetAbsOrigin() - spawn_location:GetAbsOrigin()):Normalized()

                local projectile = {
                    EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
                    vSpawnOrigin = spawn_location:GetAbsOrigin(),
                    fDistance = 5000,
                    fStartRadius = radius,
                    fEndRadius = radius,
                    Source = spawn_location,
                    vVelocity = direction * projectile_speed,
                    UnitBehavior = PROJECTILES_DESTROY,
                    bMultipleHits = false,
                    TreeBehavior = PROJECTILES_NOTHING,
                    WallBehavior = PROJECTILES_DESTROY,
                    GroundBehavior = PROJECTILES_NOTHING,
                    fGroundOffset = 80,
                    draw = false,
                    UnitTest = function(_self, unit)

                        if unit:GetUnitName() == "npc_dota_thinker" and CheckGlobalUnitTableForUnitName(unit) == true then
                            return false
                        else
                            return true
                        end

                    end,
                    OnUnitHit = function(_self, unit)

                        if unit:GetUnitName() == "npc_beastmaster" then
                            unit:AddNewModifier(caster,self,"puddle_projectile_spell_beastmaster_buff",{duration = 30})
                        else
                            unit:AddNewModifier(caster,self,"puddle_projectile_spell_player_dot_debuff",{duration = 5})
                        end

                        local particle_cast = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf"
                        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, nil)
                        ParticleManager:SetParticleControl(effect_cast, 0, unit:GetAbsOrigin())
                        ParticleManager:ReleaseParticleIndex(effect_cast)

                    end,
                    OnWallHit = function(_self, gnvPos)

                        local particle_cast = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf"
                        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                        ParticleManager:SetParticleControl(effect_cast, 0, gnvPos)
                        ParticleManager:ReleaseParticleIndex(effect_cast)

                    end,
                    OnFinish = function(_self, pos)

                        local particle_cast = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf"
                        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                        ParticleManager:SetParticleControl(effect_cast, 0, pos)
                        ParticleManager:ReleaseParticleIndex(effect_cast)

                    end,
                }

                Projectiles:CreateProjectile(projectile)]]
            end
        end
	end
end

---------------------------------------------------------------------------

function puddle_projectile_spell:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then
            if hTarget:GetUnitName() == "npc_beastmaster" then
                hTarget:AddNewModifier(self:GetCaster(),self,"puddle_projectile_spell_beastmaster_buff",{duration = 20})
            end

            local particle_cast = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, hTarget:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_cast)
            return true
        end
    end
end
---------------------------------------------------------------------------