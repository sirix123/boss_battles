m1_trackingshot_metamorph = class({})LinkLuaModifier("m1_trackingshot_charges", "player/ranger/modifiers/m1_trackingshot_charges", LUA_MODIFIER_MOTION_NONE)

function m1_trackingshot_metamorph:GetIntrinsicModifierName()
	return "m1_trackingshot_charges"
end

local nAtkCount = 1

function m1_trackingshot_metamorph:OnAbilityPhaseStart()
    if IsServer() then

        --check if we have charges
        if self:GetCaster():HasModifier("m1_trackingshot_charges") == true then
            if self:GetCaster():GetModifierStackCount("m1_trackingshot_charges", nil) == 0 then
                -- surface message to player?
                return false
            end
        end

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -80,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_trackingshot_metamorph:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_trackingshot_metamorph:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        self.nMaxCharges = self:GetSpecialValueFor( "max_charges" )
        local dmg = 0

        --self.caster:FindModifierByName("m1_trackingshot_charges"):DecrementStackCount()

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        -- init effect
        local enEffect = ""

        -- attack 3
        if nAtkCount == self.nMaxCharges then
            dmg = self:GetSpecialValueFor( "base_dmg_3" )
            enEffect = "particles/ranger/_attk3_ranger_terrorblade_metamorphosis_base_attack.vpcf"

        -- attack 1 and 2
        else
            dmg = self:GetSpecialValueFor( "base_dmg_1_2" )
            enEffect = "particles/ranger/ranger_terrorblade_metamorphosis_base_attack.vpcf"
        end

        -- metamorph init
        local nProjPerAttack = 3
        local tProjInfo = {}

        -- 3 proj spawn + directions
        --origin.z = 200
        local tSpawnLoc =
        {
            origin + Vector(0,0,50) + self.caster:GetRightVector()       *100,
            origin + Vector(0,0,50) + self.caster:GetForwardVector()         ,
            origin + Vector(0,0,50) - self.caster:GetRightVector()       *100,
        }

        for i = 1, nProjPerAttack, 1 do
            local projectile = {
                EffectName = enEffect,
                vSpawnOrigin = tSpawnLoc[i],
                fDistance = self:GetCastRange(Vector(0,0,0), nil),
                fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
                Source = self.caster,
                vVelocity = projectile_direction * projectile_speed,
                UnitBehavior = PROJECTILES_DESTROY,
                TreeBehavior = PROJECTILES_DESTROY,
                WallBehavior = PROJECTILES_DESTROY,
                GroundBehavior = PROJECTILES_NOTHING,
                fGroundOffset = 80,
                UnitTest = function(_self, unit)
                    return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
                end,
                OnUnitHit = function(_self, unit)
    
                    if nAtkCount == self.nMaxCharges and unit:FindModifierByNameAndCaster("m2_serratedarrow_modifier", self.caster) == true then
                        dmg = dmg + self:GetSpecialValueFor( "addtional_dmg_3_serrated_debuff" )
                        -- play effect on target
                        -- effect
                    elseif nAtkCount < self.nMaxCharges and unit:FindModifierByNameAndCaster("m2_serratedarrow_modifier", self.caster) == true then
                        dmg = dmg + self:GetSpecialValueFor( "addtional_dmg_1_2_serrated_debuff" )
                    end
    
                    local dmgTable = {
                        victim = unit,
                        attacker = self.caster,
                        damage = dmg,
                        damage_type = self:GetAbilityDamageType(),
                    }
    
                    ApplyDamage(dmgTable)
    
                    -- play sound
                    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_WindRunner.projectileImpact", self.caster)
    
                end,
                OnFinish = function(_self, pos)
                    -- add projectile explode particle effect here on the pos it finishes at
                    local particle_cast = "particles/units/heroes/hero_windrunner/windrunner_base_attack_explosion_flash.vpcf"
                    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(effect_cast, 0, pos)
                    ParticleManager:SetParticleControl(effect_cast, 1, pos)
                    ParticleManager:SetParticleControl(effect_cast, 3, pos)
                    ParticleManager:ReleaseParticleIndex(effect_cast)
                end,
            }

            table.insert(tProjInfo, projectile)

        end

        for _, proj in pairs(tProjInfo) do
            Projectiles:CreateProjectile(proj)
        end

        nAtkCount = nAtkCount + 1
        if nAtkCount > self.nMaxCharges then
            nAtkCount = 1
        end

	end
end
----------------------------------------------------------------------------------------------------------------
