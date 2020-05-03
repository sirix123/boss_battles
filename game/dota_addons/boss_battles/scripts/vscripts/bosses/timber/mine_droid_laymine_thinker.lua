mine_droid_laymine_thinker = class({})

function mine_droid_laymine_thinker:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function mine_droid_laymine_thinker:OnCreated( kv )
    if not IsServer() then return end

    -- init
    self.parent = self:GetParent()
    self.caster = self:GetCaster()

    -- ref kv 
    self.triggerRadius = 300
    self.explosion_delay = 1
    self.damage = 200
    self.activationTime = 1
    self.explosion_range = 300
    self.thinkInterval = FrameTime()

    -- get current pos from kv
    self.currentPosition = Vector( kv.target_x, kv.target_y, kv.target_z)

    -- init dmg table 
	self.damageTable = {
        victim = nil,
		attacker = self.caster,
		damage = self.damage ,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

    -- Set the mine as inactive
    self.active = false
    self.triggered = false
    self.trigger_time = 0

    -- start thinker
    -- cast landmine but wait ... before activating it
    Timers:CreateTimer( self.activationTime , function()
        self.active = true
        self:StartIntervalThink( self.thinkInterval )
    end)
    

end
--------------------------------------------------------------------------------

function mine_droid_laymine_thinker:OnIntervalThink()
    if not IsServer() then return end

    local parent = self.parent

    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),	-- int, your team number
        self.currentPosition,	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        self.triggerRadius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    local enemy_found
    if #enemies > 0 then
        enemy_found = true
    end

    -- if mine is not triggerd, check if we should explode or wait
    if not self.triggered then
        if enemy_found then
            self.triggered = true
            self.trigger_time = 0

            -- Play prime sound
            local sound_prime = "Hero_Techies.LandMine.Priming"
            EmitSoundOn(sound_prime, parent)
        end

    -- If the mine was already triggered, check if it should stop or count time
    else
        if enemy_found then
            self.trigger_time = self.trigger_time + self.thinkInterval

            -- Check if the mine should blow up
            if self.trigger_time >= self.explosion_delay then
                self:Explode()
            end
        else
            self.triggered = false
            self.trigger_time = 0
        end
    end

end
--------------------------------------------------------------------------------


function mine_droid_laymine_thinker:Explode()

    local parent = self.parent
    local parentAbsOrigin = parent:GetAbsOrigin()

    local sound_explosion = "Hero_Techies.LandMine.Detonate"
    EmitSoundOn(sound_explosion, parent)

    local particle_explosion = "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf"
	local particle_explosion_fx = ParticleManager:CreateParticle(particle_explosion, PATTACH_WORLDORIGIN, parent)
	ParticleManager:SetParticleControl(particle_explosion_fx, 0, parentAbsOrigin)
	ParticleManager:SetParticleControl(particle_explosion_fx, 1, parentAbsOrigin)
	ParticleManager:SetParticleControl(particle_explosion_fx, 2, Vector(explosion_range, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_explosion_fx)

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parentAbsOrigin,
        nil,
        self.explosion_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false)

    for _, enemy in pairs(enemies) do
        self.damageTable = {
            victim = enemy,
            attacker = self.caster,
            damage = self.damage ,
            damage_type = DAMAGE_TYPE_PHYSICAL,
        }

        ApplyDamage(self.damageTable)

    end

    local mines = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS,
        self.currentPosition,
        nil,
        1,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

    for _, mine in pairs(mines) do
        if mine:GetUnitName() == "npc_dota_techies_land_mine" then
            local mine_health = mine:GetHealth()
            if mine_health > 1 then
                mine:SetHealth(mine_health - 1)
            else
                mine:ForceKill(false)
            end
        end
    end

	self:Destroy()
end

function mine_droid_laymine_thinker:OnDestroy()
    if not IsServer() then return end

    self.parent:ForceKill(false)
    UTIL_Remove( self.parent )
end
