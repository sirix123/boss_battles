r_frostbomb_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function r_frostbomb_modifier:IsHidden()
	return false
end

function r_frostbomb_modifier:IsDebuff()
	return true
end

function r_frostbomb_modifier:IsStunDebuff()
	return false
end

function r_frostbomb_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function r_frostbomb_modifier:GetEffectName()
	return "particles/items4_fx/nullifier_mute_debuff.vpcf"--"particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function r_frostbomb_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function r_frostbomb_modifier:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- reference from kv
        self.fb_bse_dmg = kv.fb_bse_dmg
        self.damage_interval = kv.damage_interval
        self.fb_dmg_per_shatter_stack = kv.fb_dmg_per_shatter_stack
        self.nStackCount = kv.nStackCount
        self.damage_type = kv.damage_type

        -- damge loop start
        self.stopDamageLoop = false

        -- sound
        --self:GetParent():EmitSound("Hero_Ancient_Apparition.ColdFeetCast")

        -- start damage timer
        self:StartApplyDamageLoop()

    end
end
----------------------------------------------------------------------------

function r_frostbomb_modifier:StartApplyDamageLoop()
    if IsServer() then

        Timers:CreateTimer(self.damage_interval, function()
            if self.stopDamageLoop == true then
                return false
            end

            -- dmg calcuation
            self.dmg = self.fb_bse_dmg + ( self.nStackCount * self.fb_dmg_per_shatter_stack )

            self.dmgTable = {
                victim = self.parent,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = self.damage_type,
            }

            ApplyDamage(self.dmgTable)

            return self.damage_interval
        end)

    end
end
----------------------------------------------------------------------------

function r_frostbomb_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function r_frostbomb_modifier:OnDestroy()
    if IsServer() then
        -- stop timer
        self.stopDamageLoop = true
    end
end
----------------------------------------------------------------------------