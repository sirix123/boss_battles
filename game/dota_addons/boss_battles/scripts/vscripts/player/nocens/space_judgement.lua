space_judgement = class({})
LinkLuaModifier( "q_armor_aura_debuff", "player/nocens/modifiers/q_armor_aura_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "e_regen_aura_debuff", "player/nocens/modifiers/e_regen_aura_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "r_outgoing_dmg_debuff", "player/nocens/modifiers/r_outgoing_dmg_debuff", LUA_MODIFIER_MOTION_NONE )

function space_judgement:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.5)
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        self.caster = self:GetCaster()
        self.point = nil
        self.point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.point )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self:GetSpecialValueFor( "radius" ), -self:GetSpecialValueFor( "radius" ), -self:GetSpecialValueFor( "radius" ) ) )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );

        return true
    end
end
---------------------------------------------------------------------------

function space_judgement:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_judgement:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function space_judgement:OnSpellStart()
    if IsServer() then
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        self.caster = self:GetCaster()

        local damage = self:GetSpecialValueFor( "dmg" )

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.point,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self:GetSpecialValueFor( "radius" ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies ~= nil and #enemies ~= 0 then

            for _, enemy in pairs(enemies) do

                if self.caster:HasModifier("q_armor_aura_buff") then

                    EmitSoundOn("Hero_DragonKnight.DragonTail.Target", enemies[1])

                    damage = self:GetSpecialValueFor( "dmg" ) + self:GetSpecialValueFor( "bonus_dmg" )
                    enemy:AddNewModifier(self.caster, self, "q_armor_aura_debuff", {duration = self:GetSpecialValueFor( "debuff_duration" )})

                    self.caster:FindAbilityByName("q_armor_aura"):StartCooldown(self.caster:FindAbilityByName("q_armor_aura"):GetCooldown(1))
                    self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(true)
                    self.caster:FindAbilityByName("e_regen_aura"):SetActivated(true)

                elseif self.caster:HasModifier("e_regen_aura_buff") then

                    EmitSoundOn("Hero_DragonKnight.DragonTail.Target", enemies[1])

                    damage = self:GetSpecialValueFor( "dmg" ) + self:GetSpecialValueFor( "bonus_dmg" )
                    enemy:AddNewModifier(self.caster, self, "e_regen_aura_debuff", {duration = self:GetSpecialValueFor( "debuff_duration" )})

                    self.caster:FindAbilityByName("e_regen_aura"):StartCooldown(self.caster:FindAbilityByName("e_regen_aura"):GetCooldown(1))
                    self.caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(true)
                    self.caster:FindAbilityByName("q_armor_aura"):SetActivated(true)

                elseif self.caster:HasModifier("r_outgoing_dmg_buff") then

                    EmitSoundOn("Hero_Sven.StormBoltImpact", enemies[1])

                    damage = self:GetSpecialValueFor( "dmg" ) + self:GetSpecialValueFor( "bonus_dmg" ) + self:GetCaster():FindAbilityByName("r_outgoing_dmg"):GetSpecialValueFor( "r_dmg" )
                    --enemy:AddNewModifier(self.caster, self, "r_outgoing_dmg_debuff", {duration = self:GetSpecialValueFor( "debuff_duration" )})

                    local nfxID = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_POINT, enemies[1])
                    ParticleManager:SetParticleControlEnt(nfxID, 3, enemies[1], PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", enemies[1]:GetAbsOrigin(), false)

                    self.caster:FindAbilityByName("r_outgoing_dmg"):StartCooldown(self.caster:FindAbilityByName("r_outgoing_dmg"):GetCooldown(1))
                    self.caster:FindAbilityByName("e_regen_aura"):SetActivated(true)
                    self.caster:FindAbilityByName("q_armor_aura"):SetActivated(true)

                else

                    EmitSoundOn("Hero_DragonKnight.DragonTail.Target", enemies[1])

                end

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                }

                ApplyDamage(self.dmgTable)
            end
        end

        if self.caster:HasModifier("q_armor_aura_buff") then
            self:RemoveBuffsAllUnits( "q_armor_aura_buff" )
        elseif self.caster:HasModifier("e_regen_aura_buff") then
            self:RemoveBuffsAllUnits( "e_regen_aura_buff" )
        elseif self.caster:HasModifier("r_outgoing_dmg_buff") then
            self:RemoveBuffsAllUnits( "r_outgoing_dmg_buff" )
        end

        local particle = "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_target.vpcf"
        local particle_aoe_fx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle_aoe_fx, 0, self.point)
        ParticleManager:SetParticleControl(particle_aoe_fx, 3, self.point)
        ParticleManager:ReleaseParticleIndex(particle_aoe_fx)
    end
end
---------------------------------------------------------------------------

function space_judgement:RemoveBuffsAllUnits( buff )
    if IsServer() then

        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.point,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if friendlies ~= nil and #friendlies ~= 0 then
            for _, friend in pairs(friendlies) do
                if friend:HasModifier(buff) then
                    friend:RemoveModifierByName(buff)
                end
            end
        end
    end
end