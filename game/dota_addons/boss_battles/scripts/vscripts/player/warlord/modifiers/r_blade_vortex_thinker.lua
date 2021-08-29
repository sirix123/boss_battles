r_blade_vortex_thinker = class({})

function r_blade_vortex_thinker:IsHidden()
	return true
end

function r_blade_vortex_thinker:IsDebuff()
	return false
end

function r_blade_vortex_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- kv ref
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "base_dmg" )
        self.interval = self:GetAbility():GetSpecialValueFor( "tick_rate" )
        self.base_mana = self:GetAbility():GetSpecialValueFor( "mana_gain_percent_bonus" )

        -- ref from spell
        self.currentTarget = self.parent:GetAbsOrigin()                -- Vector( kv.target_x, kv.target_y, kv.target_z )
        self.previous_location = nil
        self.base_mana = self.caster:FindAbilityByName("m1_sword_slash"):GetSpecialValueFor( "mana_gain_percent" )
        self.bonus_mana = self.caster:FindAbilityByName("m1_sword_slash"):GetSpecialValueFor( "mana_gain_percent_bonus" )

        -- do on create stuff
        self:PlayEffectsOnCreated()

        self.timer_find_caster = Timers:CreateTimer(function()
                if IsValidEntity(self.parent) == false then
                    self:Destroy()
                    return false
                end

                if self.caster:IsAlive() == false then
                    self:Destroy()
                    return false
                end

                if self.parent:IsAlive() == false then
                    self:Destroy()
                    return false
                end

                ParticleManager:SetParticleControl(self.nfx , 0, self.parent:GetAbsOrigin())

                if self.caster:HasModifier("q_conq_shout_modifier") then
                    -- move vortex to caster location
                    -- self.currentTarget = self.caster:GetAbsOrigin()

                    -- play effects
                    local particle = 'particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf'
                    local particle_stomp_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.caster)
                    ParticleManager:SetParticleControl(particle_stomp_fx, 0, self.parent:GetAbsOrigin())
                    ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(self.radius, 1, 1))
                    ParticleManager:SetParticleControl(particle_stomp_fx, 2, Vector(250,0,0))
                    ParticleManager:ReleaseParticleIndex(particle_stomp_fx)

                    -- increase dmg
                    self.dmg = self.caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" ) + ( ( self.caster:FindAbilityByName("q_conq_shout"):GetSpecialValueFor( "vortex_dmg_inc" ) /100 ) * self.caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" ) )

                    -- reset dmg
                    self.timer_damage_boost = Timers:CreateTimer(self.caster:FindAbilityByName("q_conq_shout"):GetSpecialValueFor( "duration" ), function()
                        self.dmg = self.caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" )
                        return false
                    end)
                end
            return 0.03
        end)

        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:OnIntervalThink()
    if IsServer() then

        -- destroy conditions
        --[[if self.caster:IsAlive() == false or ( self.caster:GetAbsOrigin() - self.currentTarget ):Length2D() > 5000 then
            self:Destroy()
            print("destryoing case far away from caster or caster is dead")
        end]]

        -- play effects
        --[[if self.previous_location ~= self.currentTarget or self.previous_location == nil then
            self.previous_location = self.currentTarget
            if self.nfx ~= nil then
                ParticleManager:DestroyParticle(self.nfx,true)
            end
            self:PlayEffectsOnCreated()
        end]]

        -- find enemies
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies ~= nil and #enemies ~= 0  then

            self:GetCaster():ManaOnHit( self.base_mana )

            for _, enemy in pairs(enemies) do
                --EmitSoundOn("Hero_Juggernaut.BladeFury.Impact", enemy)

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)

            end

            if self.caster:HasModifier("q_conq_shout_modifier") then
                if #enemies == 1 then
                    self.caster:ManaOnHit( self.base_mana )
                elseif #enemies == 2 then
                    self.caster:ManaOnHit( self.base_mana + ( math.fmod(#enemies,self.bonus_mana) ))
                elseif #enemies == 3 then
                    self.caster:ManaOnHit( self.base_mana + ( math.fmod(#enemies,self.bonus_mana) ))
                else
                    self.caster:ManaOnHit( self.base_mana + self.bonus_mana )
                end
            end
        end
    end
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:OnDestroy( kv )
    if IsServer() then

        -- stop looping sound
        --self.parent:StopSound("Hero_Juggernaut.BladeFuryStart")

        -- play end sound
        --EmitSoundOn("Hero_Juggernaut.BladeFuryStop", self.parent)

        if self.timer_find_caster ~= nil then
            Timers:RemoveTimer(self.timer_find_caster)
        end

        if self.timer_damage_boost ~= nil then
            Timers:RemoveTimer(self.timer_damage_boost)
        end

        if self.nfx then
            ParticleManager:DestroyParticle(self.nfx,false)
        end

        self:StartIntervalThink( -1 )
        --UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:PlayEffectsOnCreated()
    if IsServer() then

        -- for the arcana

        if self.caster.arcana_equipped == true then
            local particle = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_blade_fury.vpcf"
            self.nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
            ParticleManager:SetParticleControl(self.nfx , 0, self.parent:GetAbsOrigin())
            ParticleManager:SetParticleControl(self.nfx , 2, Vector(self.radius,1,1))
        else
            local particle = "particles/econ/items/juggernaut/jugg_sword_dragon/juggernaut_blade_fury_dragon.vpcf"
            self.nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
            ParticleManager:SetParticleControl(self.nfx , 0, self.parent:GetAbsOrigin())
            ParticleManager:SetParticleControl(self.nfx , 5, Vector(self.radius,1,1))
        end

	end
end
---------------------------------------------------------------------------
