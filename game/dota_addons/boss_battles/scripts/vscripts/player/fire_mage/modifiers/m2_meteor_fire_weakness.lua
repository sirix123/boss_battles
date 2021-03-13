m2_meteor_fire_weakness = class({})

function m2_meteor_fire_weakness:IsHidden()
	return false
end

function m2_meteor_fire_weakness:IsDebuff()
	return false
end

function m2_meteor_fire_weakness:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function m2_meteor_fire_weakness:OnCreated( kv )
    if IsServer() then
        self.particle_fx = ParticleManager:CreateParticleForPlayer("particles/fire_mage/fire_magemeteor_hammer_spell_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControlEnt(self.particle_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end
end
---------------------------------------------------------------------------

function m2_meteor_fire_weakness:OnRefresh( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

function m2_meteor_fire_weakness:OnDestroy( kv )
    if IsServer() then
		ParticleManager:DestroyParticle(self.particle_fx,true)
	end
end
-----------------------------------------------------------------------------
