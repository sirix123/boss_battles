q_warlord_def_stance_modifier_bubble = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_warlord_def_stance_modifier_bubble:IsHidden()
	return false
end

function q_warlord_def_stance_modifier_bubble:IsDebuff()
	return false
end

function q_warlord_def_stance_modifier_bubble:IsPurgable()
	return false
end

function q_warlord_def_stance_modifier_bubble:RemoveOnDeath()
	return false
end

function q_warlord_def_stance_modifier_bubble:GetTexture()
	return "dragon_knight_dragon_tail"
end

--------------------------------------------------------------------------------
-- Initializations
function q_warlord_def_stance_modifier_bubble:OnCreated( kv )
    if IsServer() then

        self.parent = self:GetParent()
        self.parent_origin = self.parent:GetAbsOrigin()

        self.max_shield = self:GetAbility():GetSpecialValueFor( "max_shield" )
        self.shield_on_hit = self:GetAbility():GetSpecialValueFor( "shield_on_hit" )

        local particle_shield_size = self.parent:GetModelRadius() * 0.9

        self.shield_inital_value = 0
        self.shield_remaining = self.shield_inital_value

        self:SetStackCount(0)

        -- bubble effect
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		local common_vector = Vector(particle_shield_size,0,particle_shield_size)
		ParticleManager:SetParticleControl(self.particle, 1, common_vector)
		ParticleManager:SetParticleControl(self.particle, 2, common_vector)
		ParticleManager:SetParticleControl(self.particle, 4, common_vector)
		ParticleManager:SetParticleControl(self.particle, 5, Vector(particle_shield_size,0,0))

		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent_origin, true)
		self:AddParticle(self.particle, false, false, -1, false, false)

    end
end

function q_warlord_def_stance_modifier_bubble:OnRefresh( kv )
    if IsServer() then

    end
end

function q_warlord_def_stance_modifier_bubble:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle, true)
    end
end

--------------------------------------------------------------------------------
-- Effect
function q_warlord_def_stance_modifier_bubble:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then

        self.shield_amount = self.shield_remaining

        self.shield_remaining = self.shield_remaining - kv.damage

        if self.shield_remaining <= 0 then
            self.shield_remaining = 0
        end

        --print("GetModifierTotal_ConstantBlock: ",self.shield_remaining)
        --print("incoming damage: ",kv.damage)

        -- block all damage if we ahve the shield for it
        if kv.damage <= self.shield_amount then
            -- UI to show bubble strenght..
            self:SetStackCount(self.shield_remaining)

            -- ply particle effect

            -- numbers to display how much dmg was blocked

            return kv.damage

        -- reduce what we can and deal dmg to player
        else
            -- UI to show bubble strenght..
            self:SetStackCount(0)

            -- ply particle effect

            -- numbers to display how much dmg was blocked

            return self.shield_amount
        end

    end
end

function q_warlord_def_stance_modifier_bubble:OnTakeDamage(params)
    if IsServer() then
        local hero = self:GetParent()

        if params.inflictor then 
            --PrintTable(params.inflictor, indent, done)
            --params.inflictor:GetAbilityName() == "m2_sword_slam" and
            if params.attacker:HasModifier("q_warlord_def_stance_modifier_bubble") then
                -- incease curernt shield by flat amount

                -- get special value for shield per unit
                if self.shield_remaining < self.max_shield then

                    -- check if we will go over max shield
                    local check_shield_total = self.shield_remaining + self.shield_on_hit
                    if check_shield_total > self.max_shield then
                        self.shield_remaining = math.clamp(self.shield_remaining, 0, self.max_shield) --self.shield_remaining + ( check_shield_total - self.max_shield )
                    else
                        self.shield_remaining = self.shield_remaining + self.shield_on_hit --params.damage
                    end
                end

                -- ui to show bubble str
                self:SetStackCount(self.shield_remaining)

                --print("OnTakeDamage: ",self.shield_remaining)

                -- play effect on hero
                ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)
            end
        end
    end
end

--------------------------------------------------------------------------------
function q_warlord_def_stance_modifier_bubble:DeclareFunctions(params)
    local funcs =
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end
