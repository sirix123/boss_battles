priest_holy_nova = class({})

function priest_holy_nova:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("space_angel_mode_modifier") == true then
        return ability_cast_point - ( ability_cast_point * caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_cps" ) )
    else
        return ability_cast_point
    end
end

function priest_holy_nova:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function priest_holy_nova:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function priest_holy_nova:GetManaCost(level)
	local caster = self:GetCaster()
	local modifier = "space_angel_mode_modifier"
	local base_mana_cost = self.BaseClass.GetManaCost(self, level)

    local mana_cost = base_mana_cost

	if caster:HasModifier(modifier) then
		--mana_cost = base_mana_cost / caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_mana_cost" )
        mana_cost = 0
	end

	return mana_cost
end
---------------------------------------------------------------------------

function priest_holy_nova:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
        local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        self:GetCaster():EmitSound("Hero_Oracle.FalsePromise.Healed")

        local blast_radius = self:GetSpecialValueFor("radius")
        local blast_speed = self:GetSpecialValueFor("speed")
        local damage = self:GetSpecialValueFor("dmg")
        local dist_multi = self:GetSpecialValueFor("distance_multi") /100
        local blast_duration = blast_radius / blast_speed
        local current_loc = self:GetCaster():GetAbsOrigin()

        local particle_name = "particles/orcale/holy_novashivas_guard_active.vpcf"
        local blast_pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(blast_pfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(blast_pfx, 1, Vector(blast_radius, blast_duration * 1.33, blast_speed))
        ParticleManager:ReleaseParticleIndex(blast_pfx)

        caster:Heal(self:GetSpecialValueFor( "heal_amount" ),caster)

        self.reduce_healing = 100 / caster:FindAbilityByName("priest_inner_fire"):GetSpecialValueFor( "healing_reduce_target" )

        local targets_hit = {}

        -- Main blasting loop
        local current_radius = 0
        local tick_interval = 0.1
        Timers:CreateTimer(tick_interval, function()

            -- Update current radius and location
            current_radius = current_radius + blast_speed * tick_interval
            current_loc = self:GetCaster():GetAbsOrigin()

            --print("current_radius = ",current_radius)

            -- Iterate through enemies in the radius
            local nearby_enemies =  FindUnitsInRadius(
                                    self:GetCaster():GetTeamNumber(),
                                    current_loc,
                                    nil,
                                    current_radius,
                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false
                                )
            for _, enemy in pairs(nearby_enemies) do
                -- Check if this enemy was already hit
                local enemy_has_been_hit = false
                for _,enemy_hit in pairs(targets_hit) do
                    if enemy == enemy_hit then enemy_has_been_hit = true end
                end

                -- If not, blast it
                if not enemy_has_been_hit then
                    -- Play hit particle
                    local particle_name = "particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf"
                    local hit_pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, enemy)
                    ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
                    ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(hit_pfx)

                    if enemy:GetTeam() == DOTA_TEAM_BADGUYS then

                        -- dmg calc
                        local dmg = damage - ( current_radius * dist_multi  )

                        -- Deal damage
                        ApplyDamage({attacker = caster, victim = enemy, ability = self, damage = dmg, damage_type = DAMAGE_TYPE_PHYSICAL})
                    elseif enemy:GetTeam() == DOTA_TEAM_GOODGUYS then

                        -- heal calc
                        local heal = self:GetSpecialValueFor( "heal_amount" ) - ( current_radius * dist_multi  )

                        --heal
                        enemy:Heal(heal,caster)

                        local units = FindUnitsInRadius(
                            self:GetCaster():GetTeamNumber(),
                            self:GetCaster():GetAbsOrigin(),
                            nil,
                            FIND_UNITS_EVERYWHERE,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO,
                            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                            FIND_CLOSEST,
                            false)

                        if units ~= nil or #units ~= 0 then
                            for _, unit in pairs(units) do
                                if unit:HasModifier("priest_inner_fire_modifier") then
                                    unit:Heal(heal / self.reduce_healing ,caster)
                                end
                            end
                        end

                    end

                    -- Add enemy to the targets hit table
                    targets_hit[#targets_hit + 1] = enemy
                end
            end

            -- If the current radius is smaller than the maximum radius, keep going
            if current_radius < blast_radius then
                return tick_interval
            end
        end)

	end
end
----------------------------------------------------------------------------------------------------------------
