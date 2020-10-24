ice_shot_tinker = class({})

LinkLuaModifier( "biting_frost_modifier_debuff", "bosses/tinker/modifiers/biting_frost_modifier_debuff", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "biting_frost_modifier_buff_elec", "bosses/tinker/modifiers/biting_frost_modifier_buff_elec", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "biting_frost_modifier_buff_fire", "bosses/tinker/modifiers/biting_frost_modifier_buff_fire", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "biting_frost_modifier_buff", "bosses/tinker/modifiers/biting_frost_modifier_buff", LUA_MODIFIER_MOTION_NONE  )

function ice_shot_tinker:OnAbilityPhaseStart()
    if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team numbers
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else
            for _, unit in pairs(units) do
                if unit:GetUnitName() == "npc_crystal" then
                    self.target = unit

                    self:GetCaster():SetForwardVector(self.target:GetAbsOrigin())
                    self:GetCaster():FaceTowards(self.target:GetAbsOrigin())
                    return true
                end
            end
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function ice_shot_tinker:OnSpellStart()
    if IsServer() then

        -- animtion 
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.5)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        self:GetCaster():SetForwardVector(self.target:GetAbsOrigin())
        self:GetCaster():FaceTowards(self.target:GetAbsOrigin())

        -- init projectile params
        local speed = 500
        local direction = (self.target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized()

        local projectile = {
            EffectName = "particles/tinker/iceshot__invoker_chaos_meteor.vpcf", --particles/tinker/iceshot__invoker_chaos_meteor.vpcf
            vSpawnOrigin = origin,
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = 200,
            Source = caster,
            vVelocity = direction * speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_NOTHING,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return true --unit:GetTeamNumber() ~= caster:GetTeamNumber() --and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS
            end,
            OnUnitHit = function(_self, unit)

                if unit:GetUnitName() == "npc_crystal" then
                    self:HitCrystal( unit )
                elseif unit:GetTeamNumber() == DOTA_UNIT_TARGET_TEAM_ENEMY then
                    self:HitPlayer()
                elseif unit:GetUnitName() == "npc_ice_ele" then
                    self:HitEle(unit)
                elseif unit:GetUnitName() == "npc_fire_ele" then
                    self:HitEle(unit)
                elseif unit:GetUnitName() == "npc_elec_ele" then
                    self:HitEle(unit)
                end

                self:DestroyEffect(unit:GetAbsOrigin())

            end,
            OnFinish = function(_self, pos)
                self:DestroyEffect(pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)


	end
end
------------------------------------------------------------------------------------------------

function ice_shot_tinker:DestroyEffect(pos)
    if IsServer() then
        --print("runing?")
        local particle = "particles/units/heroes/hero_tusk/tusk_snowball_destroy.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, pos)
        ParticleManager:SetParticleControl(effect_cast, 4, Vector(1,1,1))
        ParticleManager:ReleaseParticleIndex(effect_cast)

    end
end
------------------------------------------------------------------------------------------------

function ice_shot_tinker:HitCrystal( crystal )
    if IsServer() then

        EmitSoundOn( "rubick_rub_arc_attack_03 ", self:GetCaster() )

        -- find all players
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units ~= nil and #units ~= 0 then
            for _, unit in pairs(units) do
                if unit:GetUnitName() ~= "npc_rock" and unit:GetUnitName() ~= "npc_tinker" and unit:GetUnitName() ~= "npc_bird"then
                    -- references
                    self.speed = 500 -- special value

                    -- create projectile
                    local info = {
                        EffectName = "particles/tinker/green_iceshot__invoker_chaos_meteor.vpcf",
                        Ability = self,
                        iMoveSpeed = self.speed,
                        Source = crystal,
                        Target = unit,
                        bDodgeable = false,
                        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                        bProvidesVision = true,
                        iVisionTeamNumber = crystal:GetTeamNumber(),
                        iVisionRadius = 300,
                    }

                    -- shoot proj
                    ProjectileManager:CreateTrackingProjectile( info )
                end
            end
        end


    end
end

function ice_shot_tinker:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
        if hTarget == nil then return end
        if not hTarget:IsAlive() then return end

        if hTarget:GetTeam() == DOTA_TEAM_GOODGUYS then
            -- apply debuff
            hTarget:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_debuff", {duration = 15})
        end

        -- apply buff
        if hTarget:GetTeam() == DOTA_TEAM_BADGUYS then
            print("hit fire ele")
            -- apply debuff
            self:HitEle(hTarget)
        end

        -- remove encased debuff if they have it and destroy rock
        if hTarget:HasModifier("fire_ele_encase_rocks_debuff") then
            hTarget:RemoveModifierByName("modifier_rooted")
            hTarget:RemoveModifierByName("fire_ele_encase_rocks_debuff")

            local rocks = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                hTarget:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                100,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if rocks ~= nil and #rocks ~= 0 then
                for _, rock in pairs(rocks) do
                    if rock:GetUnitName() == "npc_encase_rocks" then
                        rock:ForceKill(false)
                    end
                end
            end
        end

    end
end
------------------------------------------------------------------------------------------------

function ice_shot_tinker:HitPlayer(unit)
    if IsServer() then
        unit:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_debuff", {duration = 15})

    end
end
------------------------------------------------------------------------------------------------

function ice_shot_tinker:HitEle(unit)
    if IsServer() then

        -- if it hits any element add do what it needs to do
        if unit:GetUnitName() == "npc_ice_ele" then
            unit:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_buff", {duration = -1})
        elseif unit:GetUnitName() == "npc_fire_ele" then
            unit:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_buff_fire", {duration = -1})
        elseif unit:GetUnitName() == "npc_elec_ele" then
            unit:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_buff_elec", {duration = -1})
        end

    end
end
------------------------------------------------------------------------------------------------
