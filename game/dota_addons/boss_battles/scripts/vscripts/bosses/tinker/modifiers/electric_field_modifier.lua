electric_field_modifier = class({})

function electric_field_modifier:IsHidden()
    return true
end

function electric_field_modifier:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function electric_field_modifier:OnCreated(keys)
	if not IsServer() then return end
    local caster = self:GetCaster()

    local maxRadius = 2500--self:GetTalentSpecialValueFor("radius")
    local speed = 1200--self:GetTalentSpecialValueFor("speed")
    local damage = 10--self:GetTalentSpecialValueFor("damage")
    local currentRadius = 0

    --DebugDrawCircle(caster:GetAbsOrigin(), Vector(0,255,0),128,maxRadius,true,60)

    local nfx = ParticleManager:CreateParticle("particles/tinker/tinker_razor_plasmafield.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 1, Vector(speed, maxRadius + 500, 1))

    local enemyHit = {}

    -- flag for returning
    local return_field = false

    Timers:CreateTimer(0, function()
        if currentRadius < maxRadius and return_field == false then

            local enemies = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                currentRadius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            for _, enemy in pairs(enemies) do
                if not enemyHit[enemy] then

                    self.dmgTable = {

                        victim = enemy,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = self,
                    }

                    ApplyDamage(self.dmgTable)

                    enemyHit[enemy] = true
                end
            end

            currentRadius = currentRadius + maxRadius*FrameTime()
            return 0.06

        else

            ParticleManager:SetParticleControl(nfx, 1, Vector(-speed, maxRadius, 1))

        end
    end)

    self:AddParticle(nfx, false, false, 0, false, false)

end
--------------------------------------------------------------------------------
