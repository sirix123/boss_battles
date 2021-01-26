e_rainofarrows = class({})
LinkLuaModifier("r_explosive_tip_modifier_target", "player/ranger/modifiers/r_explosive_tip_modifier_target", LUA_MODIFIER_MOTION_NONE)

function e_rainofarrows:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_rainofarrows:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
--------------------------------------------------------------------------------

function e_rainofarrows:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
function e_rainofarrows:OnSpellStart()
	if IsServer() then

		local caster = self:GetCaster()
		local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)

		local dmg = self:GetSpecialValueFor( "dmg" )

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_overwhelming_odds_ti7/legion_commander_odds_ti7.vpcf", PATTACH_CUSTOMORIGIN, nil );
		ParticleManager:SetParticleControl( nFXIndex, 0, point );
		ParticleManager:SetParticleControl( nFXIndex, 1, point );
		ParticleManager:SetParticleControl( nFXIndex, 3, point );
		ParticleManager:SetParticleControl( nFXIndex, 6, point );
		ParticleManager:SetParticleControl( nFXIndex, 4, Vector(self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius"), 0) );
		ParticleManager:ReleaseParticleIndex( nFXIndex );

		EmitSoundOn( "Hero_LegionCommander.Overwhelming.Location.ti7", self:GetCaster() )
		EmitSoundOn( "Hero_LegionCommander.Overwhelming.Cast", self:GetCaster() )

		local enemies = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),	-- int, your team number
				point,	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				self:GetSpecialValueFor( "radius" ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)

		if enemies ~= nil and #enemies ~= 0 then
			for _,enemy in pairs(enemies) do

				if caster:HasModifier("r_explosive_tip_modifier") then
					local hbuff = caster:FindModifierByNameAndCaster("r_explosive_tip_modifier", caster)
					local flBuffTimeRemaining = hbuff:GetRemainingTime()
					enemy:AddNewModifier(caster, self, "r_explosive_tip_modifier_target", {duration = flBuffTimeRemaining})

				end

				local dmgTable = {
					victim = enemy,
					attacker = caster,
					damage = dmg / #enemies,
					damage_type = self:GetAbilityDamageType(),
					ability = self,
				}

				ApplyDamage(dmgTable)
			end
		end
	end
end