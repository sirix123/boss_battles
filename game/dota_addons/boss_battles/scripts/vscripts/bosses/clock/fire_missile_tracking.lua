fire_missile_tracking = class({})

function fire_missile_tracking:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_missile_tracking:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_missile_tracking:OnSpellStart()
    if IsServer() then

        -- references
        self.speed = 500 -- special value
        self.damage = 100

        -- find all units
        local targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            9000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            0,
            0,
            false
        )


        if targets ~= nil and #targets ~= 0 then
            EmitSoundOn( "Hero_Rattletrap.Rocket_Flare.Fire", self:GetCaster() )
            for _, target in pairs(targets) do

                local info = {
                    EffectName = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare.vpcf",
                    Ability = self,
                    iMoveSpeed = self.speed,
                    Source = self:GetCaster(),
                    Target = target,
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
---------------------------------------------------------------------------------------------------------------------------------------

function fire_missile_tracking:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then
            local dmgTable =
            {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(dmgTable)

            return true
        end
    end
end
