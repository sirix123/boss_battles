
vertical_saw_blade = class({})


function vertical_saw_blade:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        self.tPos = {}

        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.projectile_speed = 300--self:GetSpecialValueFor("projectile_speed")
        self.radius = 150--self:GetSpecialValueFor( "radius" )
        self.damage = 250--self:GetSpecialValueFor( "damage" )

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

    end
end

function vertical_saw_blade:OnChannelFinish(bInterrupted)
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

    end
end

---------------------------------------------------------------------------

function vertical_saw_blade:OnSpellStart()
    if not IsServer() then return end
    if not self:IsChanneling() then return end

end
---------------------------------------------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnChannelThink( interval )
    if not IsServer() then return end

    if IsValidEntity(self:GetCaster()) == false then --or self.caster:HasModifier("chain_edge_bubble") == false
        return false
    end

    self.time = (self.time or 0) + interval
    local myInterval = 2.5

    if self.time >= myInterval then

        self.projectile_speed = self.projectile_speed + 50

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            6000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
        )

        local sound_random = math.random(1,11)
        if sound_random <= 9 then
            self:GetCaster():EmitSound("shredder_timb_attack_0"..sound_random)
        else
            self:GetCaster():EmitSound("shredder_timb_attack_"..sound_random)
        end

        if units ~= nil and #units ~= 0 then
            for _, target in pairs(units) do

                local projectile_direction = (Vector( target:GetAbsOrigin().x - self:GetCaster():GetAbsOrigin().x, target:GetAbsOrigin().y - self:GetCaster():GetAbsOrigin().y, 0 )):Normalized()

                local hProjectile = {
                    Source = self.caster,
                    Ability = self,
                    vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
                    bDeleteOnHit = true,
                    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                    EffectName = "particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram.vpcf",
                    fDistance = 9000,
                    fStartRadius = self.radius,
                    fEndRadius = self.radius,
                    vVelocity = projectile_direction * self.projectile_speed,
                    bHasFrontalCone = false,
                    bReplaceExisting = false,
                    fExpireTime = GameRules:GetGameTime() + 30.0,
                    bProvidesVision = true,
                    iVisionRadius = 200,
                    iVisionTeamNumber = DOTA_TEAM_GOODGUYS,
                }

                ProjectileManager:CreateLinearProjectile(hProjectile)

            end
        end
        self.time = self.time - myInterval
    end
end
---------------------------------------------------------------------------------------------------------------------------------------






--[[
local tProjectileData = {}

function vertical_saw_blade:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        self.tPos = {}

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            6000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            for _, unit in pairs(units) do
                table.insert(self.tPos,unit:GetAbsOrigin())
            end

            --self:GetCaster():SetForwardVector(self.vTargetPos)
            --self:GetCaster():FaceTowards(self.vTargetPos)

            local sound_random = math.random(1,11)
            if sound_random <= 9 then
                self:GetCaster():EmitSound("shredder_timb_attack_0"..sound_random)
            else
                self:GetCaster():EmitSound("shredder_timb_attack_"..sound_random)
            end

            --EmitSoundOn("shredder_timb_cast_03", self:GetCaster())

            return true
        end

        return true
    end
end
------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnSpellStart()
    if IsServer() then

        --ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)
        --print("casting spell")
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = 400--self:GetSpecialValueFor("projectile_speed")
        self.radius = 180--self:GetSpecialValueFor( "radius" )
        self.damage = 250--self:GetSpecialValueFor( "damage" )

        -- face center of the room
        --self:GetCaster():SetForwardVector(self.vTargetPos)
        --self:GetCaster():FaceTowards(self.vTargetPos)

        --[[local projectile_direction = self.vTargetPos-self.caster:GetAbsOrigin()
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()

        for _, target in pairs(self.tPos) do

            local projectile_direction = (Vector( target.x - origin.x, target.y - origin.y, 0 )):Normalized()

            local hProjectile = {
                Source = self.caster,
                Ability = self,
                vSpawnOrigin = origin,
                bDeleteOnHit = true,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                EffectName = "particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram.vpcf",
                fDistance = 9000,
                fStartRadius = self.radius,
                fEndRadius = self.radius,
                vVelocity = projectile_direction * projectile_speed,
                bHasFrontalCone = false,
                bReplaceExisting = false,
                fExpireTime = GameRules:GetGameTime() + 30.0,
                bProvidesVision = true,
                iVisionRadius = 200,
                iVisionTeamNumber = self.caster:GetTeamNumber(),
            }

            ProjectileManager:CreateLinearProjectile(hProjectile)
        end
	end
end]]
------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnProjectileHit(hTarget, vLocation)

    if hTarget ~= nil then

        local particle = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_explode_b_b_ti_5_gold.vpcf"
        local pIndex = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(pIndex, 0, vLocation)
        ParticleManager:ReleaseParticleIndex(pIndex)

        self.damageTable = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = self.damage ,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self, 
        }

        ApplyDamage(self.damageTable)

        return true
    end
end
------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnProjectileThink(vLocation)
    GridNav:DestroyTreesAroundPoint( vLocation, self.radius, true )
    
    local sound_tree = "Hero_Shredder.Chakram.Tree"
    local trees = GridNav:GetAllTreesAroundPoint( vLocation, self.radius, true )
    for _,tree in pairs(trees) do
        EmitSoundOnLocationWithCaster( tree:GetAbsOrigin(), sound_tree, self.caster )
    end

end
------------------------------------------------------------------------------------------------
