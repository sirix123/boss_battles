bird_floor_nofly = class({})

--------------------------------------------------------------------------------
-- Classifications
function bird_floor_nofly:IsHidden()
	return false
end

function bird_floor_nofly:IsDebuff()
	return false
end

function bird_floor_nofly:IsPurgable()
	return true
end

function bird_floor_nofly:GetEffectName()
	return "particles/units/heroes/hero_visage/visage_stone_form_area_energy.vpcf"
end

--------------------------------------------------------------------------------
-- Initializations
function bird_floor_nofly:OnCreated( kv )
    --if IsServer() then
        self:GetParent():EmitSound("Visage_Familar.StoneForm.Cast")
        print("flying modifier created")
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_stone_form.vpcf", PATTACH_ABSORIGIN, self:GetParent())
        self:AddParticle(particle, false, false, -1, false, false)

        self.flying = false
        --print("self.flying ", self.flying)
	--end
end

function bird_floor_nofly:OnDestroy()
    --if IsServer() then
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_familiar_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(particle)
        --print("flying modifier OnDestroy")
        self.flying = true
    --end
end

--------------------------------------------------------------------------------

function bird_floor_nofly:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = false }
end

function bird_floor_nofly:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function bird_floor_nofly:GetVisualZDelta()
	return 0
end

function bird_floor_nofly:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end
