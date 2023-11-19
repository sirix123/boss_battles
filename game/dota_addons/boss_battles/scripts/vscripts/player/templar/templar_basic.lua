templar_basic = class({})


function templar_basic:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function templar_basic:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function templar_basic:GetManaCost(level)
	local caster = self:GetCaster()
    local mana_cost = 0

    if caster:GetMana() <= 10 then
        mana_cost = 0
    end

    mana_cost = caster:GetMana() * ( self:GetSpecialValueFor("percent_of_mana_cost") / 100) --0.08

	return mana_cost
end
---------------------------------------------------------------------------

function templar_basic:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

    local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")

    damage = damage + ( self:GetCaster():GetMana() * (self:GetSpecialValueFor("bonus_damage") / 100 ) )

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),	-- int, your team number
        self:GetCursorTarget():GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
    )

    if enemies ~= nil and #enemies ~= 0 then
        EmitSoundOn( "Hero_Huskar.ProjectileImpact", self:GetCaster() )

        for _, enemy in pairs(enemies) do

            local dmgTable = {
                victim = enemy,
                attacker = caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)
        end
    end
end
--------------------------------------------------------------------------------


