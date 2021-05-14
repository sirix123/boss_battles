
cleaning_bot_explode = class({})

function cleaning_bot_explode:OnSpellStart()
	if IsServer() then

        local enemies_everywhere = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
            )


        if enemies_everywhere ~= nil and #enemies_everywhere ~= 0 then
            for _, enemy in pairs(enemies_everywhere) do

                local info = {
                    EffectName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf",
                    Ability = self,
                    iMoveSpeed = 1500,
                    Source = self:GetCaster(),
                    Target = enemy,
                    bDodgeable = false,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                    bProvidesVision = true,
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                    iVisionRadius = 300,
                }

                ProjectileManager:CreateTrackingProjectile( info )

            end
        end

	end
end
---------------------------------------------------------------------------

function cleaning_bot_explode:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget ~= nil then

            local particle_burn_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_mana_loss.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControl(particle_burn_fx, 0, hTarget:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_burn_fx)

            local dmgTable = {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = 250,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(dmgTable)

            return true
        end
    end
end
