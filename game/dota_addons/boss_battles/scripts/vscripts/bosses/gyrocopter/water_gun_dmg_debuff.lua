water_gun_dmg_debuff = class({})

function water_gun_dmg_debuff:IsHidden()
	return false
end

function water_gun_dmg_debuff:IsDebuff()
	return true
end

function water_gun_dmg_debuff:IsPurgable()
	return false
end

function water_gun_dmg_debuff:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function water_gun_dmg_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function water_gun_dmg_debuff:GetTexture()
	return "huskar_inner_fire"
end

---------------------------------------------------------------------------

function water_gun_dmg_debuff:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.dmg = 100

        self:StartIntervalThink( 1 )

	end
end
---------------------------------------------------------------------------

function water_gun_dmg_debuff:OnIntervalThink()
    if IsServer() then

        local dmgTable = {
            victim = self.parent,
            attacker = self:GetCaster(),
            damage = self.dmg,
            damage_type = DAMAGE_TYPE_PHYSICAL,
        }

        ApplyDamage(dmgTable)

    end
end
---------------------------------------------------------------------------

function water_gun_dmg_debuff:OnDestroy( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------