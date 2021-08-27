
link_crystals_modifier = class({})

function link_crystals_modifier:IsHidden()
	return false
end

function link_crystals_modifier:IsDebuff()
	return true
end

function link_crystals_modifier:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function link_crystals_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = 200
        self.dmg_link = 100
        self.stopDamageLoop = false
        self.damage_interval = 1
        self.tCrystals = {}

        self.previous_crystal_link = EntIndexToHScript(kv.target)
        local duration = kv.duration

        -- find closet crystal
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.parent:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            self:Destroy()
        else
            for _, unit in pairs(units) do
                if unit:GetUnitName() == "npc_phase2_crystal" then
                    if unit:HasModifier("link_crystals_modifier") == false then
                        table.insert(self.tCrystals,unit)
                    end
                end
            end
        end

        if #self.tCrystals ~= 0 then
            local previous_distance = 999999
            self.close_target = nil

            for index, crystal in pairs(self.tCrystals) do

                local distance = ( self.parent:GetAbsOrigin() - crystal:GetAbsOrigin() ):Length2D()

                if distance == 0 then
                    table.remove(self.tCrystals,index)
                end

                if distance < previous_distance and distance ~= 0 then
                    self.close_target = crystal
                    previous_distance = distance
                end
            end

            -- put a modifier on the next crystal
            if self.close_target ~= nil then
                self.close_target:AddNewModifier( self.close_target, self, "link_crystals_modifier", { duration = duration, target = self.close_target:GetEntityIndex() } )

                -- link particle
                --[[
                local particleName = "particles/tinker/crystals_green_phoenix_sunray.vpcf"
                self.effect_cast_link = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self:GetParent() )
                ParticleManager:SetParticleControl( self.effect_cast_link, 0, Vector( self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y, self:GetParent():GetAbsOrigin().z + 100 ))
                ParticleManager:SetParticleControl( self.effect_cast_link, 1, Vector( self.close_target:GetAbsOrigin().x,self.close_target:GetAbsOrigin().y, self.close_target:GetAbsOrigin().z + 100 ) )
                ]]

                self.close_target_location = self.close_target:GetAbsOrigin()
                self.caster_location = self:GetParent():GetAbsOrigin()

                self:StartApplyDamageLoopLink()
            end
        end


        --self:StartApplyDamageLoopStorm()
	end
end
---------------------------------------------------------------------------

function link_crystals_modifier:StartApplyDamageLoopLink()

    self.dmg_timer = Timers:CreateTimer(self.damage_interval, function()
        if self:IsNull() == true then
            --print("IsValidEntity(self) == false")
            return false
        end

	    if self.stopDamageLoop == true then
            --print("self.stopDamageLoop== true ")
		    return false
        end

        local speed = 600
        local direction = ( self.close_target_location - self.parent:GetAbsOrigin() ):Normalized()
        local distance = (self.close_target_location - self.parent:GetAbsOrigin()):Length2D()

        local particleEffect = "particles/tinker/tinker_arc_warden_base_attack.vpcf"

        local projectile = {
            EffectName = particleEffect,
            vSpawnOrigin = self.parent:GetAbsOrigin(),
            fDistance = distance,
            fUniqueRadius = 80,--200
            Source = self.parent,
            vVelocity = direction * speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_NOTHING,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= casterTeamNumber and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)
                self.dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self.dmg_link,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    --ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)
            end,
            OnFinish = function(_self, pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)

        --print("this timer running?")

        --[[local enemies = FindUnitsInLine(
            self:GetCaster():GetTeamNumber(),
            self.caster_location,
            self.close_target_location,
            nil,
            80,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE)

        if enemies ~= nil and #enemies ~= 0 then
            for _, enemy in pairs(enemies) do

                --print("enemy hit")

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg_link,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)
            end
        end]]


		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------

function link_crystals_modifier:OnDestroy( kv )
    if IsServer() then

        --Timers:RemoveTimer(self.dmg_timer)

        if self.effect_cast_storm then
            ParticleManager:DestroyParticle(self.effect_cast_storm,true)
        end
        if self.effect_cast_link then
            ParticleManager:DestroyParticle(self.effect_cast_link,true)
        end
        self.stopDamageLoop = true
	end
end
---------------------------------------------------------------------------