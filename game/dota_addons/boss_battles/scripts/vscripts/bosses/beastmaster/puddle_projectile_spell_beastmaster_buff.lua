puddle_projectile_spell_beastmaster_buff = class({})

function puddle_projectile_spell_beastmaster_buff:IsHidden()
	return false
end

function puddle_projectile_spell_beastmaster_buff:IsDebuff()
	return true
end

function puddle_projectile_spell_beastmaster_buff:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function puddle_projectile_spell_beastmaster_buff:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self:IncrementStackCount()

        -- increase stacks above his head
        local stacks = self:GetStackCount()

        self.particle = ParticleManager:CreateParticle("particles/beastmaster/beastmater_wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())

        --local digitX = thisEntity.count >= 10 and 1 or 0
        if stacks >= 10 and stacks < 20 then
            digitX = 1
        elseif stacks >= 20 then
            digitX = 2
        else 
            digitX = 0
        end

        local digitY = stacks % 10
        --print("digitX: ",digitX,"digitY: ",digitY)
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 1, Vector( digitX, digitY, 0 ))


	end
end
---------------------------------------------------------------------------

function puddle_projectile_spell_beastmaster_buff:OnRefresh(table)
    if IsServer() then
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,true)
        end
        self:OnCreated()
	end
end
---------------------------------------------------------------------------


function puddle_projectile_spell_beastmaster_buff:OnDestroy( kv )
    if IsServer() then
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,true)
        end
	end
end
---------------------------------------------------------------------------