e_syncwithforest_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function e_syncwithforest_modifier:IsHidden()
	return false
end

function e_syncwithforest_modifier:IsDebuff()
	return false
end

function e_syncwithforest_modifier:IsStunDebuff()
	return false
end

function e_syncwithforest_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function e_syncwithforest_modifier:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end
-----------------------------------------------------------------------------

function e_syncwithforest_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()


        --particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_debuff.vpcf

        --[[local particle = "particles/units/heroes/hero_enchantress/enchantress_natures_attendants_lvl1.vpcf"
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)

        for wisp = 3, 7 do
            ParticleManager:SetParticleControlEnt(nfx, wisp, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
        end]]
    end
end
----------------------------------------------------------------------------

function e_syncwithforest_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function e_syncwithforest_modifier:OnDestroy()
    if IsServer() then

    end
end
----------------------------------------------------------------------------
