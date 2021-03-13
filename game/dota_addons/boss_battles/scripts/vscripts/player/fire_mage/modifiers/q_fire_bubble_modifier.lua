q_fire_bubble_modifier = class({})

function q_fire_bubble_modifier:RemoveOnDeath()
    return true
end

function q_fire_bubble_modifier:IsHidden()
	return false
end

function q_fire_bubble_modifier:IsDebuff()
	return false
end

function q_fire_bubble_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function q_fire_bubble_modifier:GetEffectName()
    return "particles/econ/items/ember_spirit/ember_ti9/ember_ti9_flameguard.vpcf"
end

function q_fire_bubble_modifier:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
-----------------------------------------------------------------------------

function q_fire_bubble_modifier:OnCreated( kv )
	if IsServer() then

		self.burn_tick = self:GetAbility():GetSpecialValueFor( "burn_tick")
		self.burn_amount = self:GetAbility():GetSpecialValueFor( "burn_amount")

		self.max_shield = self:GetAbility():GetSpecialValueFor( "bubble_amount" )
        self.shield_remaining = self.max_shield
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

		self.caster = self:GetCaster()
		self.parent = self:GetParent()

		self:StartIntervalThink(self.burn_tick)

    end
end

function q_fire_bubble_modifier:OnIntervalThink()
	if IsServer() then

		local enemies = FindUnitsInRadius(
            self.caster:GetTeam(),
            self.parent:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        if enemies ~= nil and #enemies ~= 0 then
            for _, enemy in pairs(enemies) do
				local damageTable = {
					attacker = self:GetCaster(),
					damage = self.burn_amount,
					damage_type = self:GetAbility():GetAbilityDamageType(),
					ability = self:GetAbility(),
				}

				damageTable.victim = enemy
				ApplyDamage(damageTable)

            end
        end
    end
end

----------------------------------------------------------------------------

function q_fire_bubble_modifier:OnDestroy()
	if IsServer() then

	end
end
----------------------------------------------------------------------------

-- Effect
function q_fire_bubble_modifier:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then

        self.shield_amount = self.shield_remaining

        self.shield_remaining = self.shield_remaining - kv.damage

        --print("self.shield_remaining ",self.shield_remaining)

        if self.shield_remaining <= 0 then
            self.shield_remaining = 0
        end

        -- block all damage if we ahve the shield for it
        if kv.damage <= self.shield_amount then
            return kv.damage

        -- reduce what we can and deal dmg to player
        else
            self:Destroy()
            return self.shield_amount
        end

    end
end

--------------------------------------------------------------------------------
function q_fire_bubble_modifier:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end