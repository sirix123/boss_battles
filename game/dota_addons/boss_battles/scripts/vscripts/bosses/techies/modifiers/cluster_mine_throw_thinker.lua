cluster_mine_throw_thinker = class({})

function cluster_mine_throw_thinker:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function cluster_mine_throw_thinker:OnCreated( kv )
    if not IsServer() then return end

    -- init
    self.parent = self:GetParent()
    self.caster = self:GetCaster()

    -- ref kv
    self.triggerRadius = kv.triggerRadius
    self.explosion_delay = kv.explosion_delay
    self.damage = kv.damage
    self.activationTime = kv.activationTime
    self.explosion_range = kv.explosion_range
    self.thinkInterval = FrameTime()

    -- invul
    self.invul = true

    -- get current pos from kv
    self.currentPosition = Vector( kv.target_x, kv.target_y, kv.target_z)

    -- init dmg table
	self.damageTable = {
        victim = nil,
		attacker = self.caster,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self,
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

function cluster_mine_throw_thinker:OnIntervalThink()
    if not IsServer() then return end

    local parent = self.parent

    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),	-- int, your team number
        self.currentPosition,	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        self.triggerRadius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
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

            -- play explosion range particle effect
            self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.currentPosition )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self.explosion_range, -self.explosion_range, -self.explosion_range ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self.explosion_delay, 0, 0 ) );
            ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

            -- Check if the mine should blow up
            if self.trigger_time >= self.explosion_delay then
                self.invul = false
                self:Destroy()
            end
        else
            -- destroy explosion range particle effect
            if self.nPreviewFXIndex ~= nil then
                ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)
            end

            self.triggered = false
            self.trigger_time = 0
        end
    end

    local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
    local heroes = HERO_LIST--HeroList:GetAllHeroes()
    for _, hero in pairs(heroes) do
        if hero.playerLives > 0 then
            areAllHeroesDead = false
            break
        end
    end
    if areAllHeroesDead then
        --Timers:CreateTimer(1.0, function()
            self:Destroy()
        --end)
    end

end
--------------------------------------------------------------------------------

function cluster_mine_throw_thinker:Explode()

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
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false)

    for _, enemy in pairs(enemies) do
        self.damageTable = {
            victim = enemy,
            attacker = self.caster,
            damage = self.damage ,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }

        ApplyDamage(self.damageTable)
    end

    local mines = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        10,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

    for _, mine in pairs(mines) do
        --print("hello123")
        if mine:GetUnitName() == "npc_dota_techies_land_mine" then
            local mine_health = mine:GetHealth()
            --print(mine_health)
            if mine_health > 1 then
                mine:SetHealth(mine_health - 1)
            else
                mine:ForceKill(false)
                mine:Kill(self.ability, attacker)
            end
        end
    end

	--self:Destroy()
end
--------------------------------------------------------------------------------

function cluster_mine_throw_thinker:OnDestroy()
    if not IsServer() then return end
    self:Explode()
    self.parent:ForceKill(false)
    UTIL_Remove( self.parent )
end
--------------------------------------------------------------------------------

function cluster_mine_throw_thinker:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = self.invul, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end