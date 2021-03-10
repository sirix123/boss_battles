m1_sword_slash = class({})
LinkLuaModifier("rage_stacks_warlord", "player/warlord/modifiers/rage_stacks_warlord", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function m1_sword_slash:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.1)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = CustomGetCastPoint(self:GetCaster(),self),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_sword_slash:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_sword_slash:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
	local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)
	local radius = self:GetSpecialValueFor("radius")
	local direction = (Vector(point.x-origin.x, point.y-origin.y, 0)):Normalized()
	local damage = self:GetSpecialValueFor("damage")
	local base_mana = self:GetSpecialValueFor( "mana_gain_percent" )
	local bonus_mana = self:GetSpecialValueFor( "mana_gain_percent_bonus" )

	-- function in utility_functions
	local enemies = FindUnitsInCone(
		caster:GetTeamNumber(),
		direction,
		0,
		origin,
		radius,
		nil,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false
	)

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

	-- mana percent per mob hit
	-- add more rage generation more mobs but dimishing returns
	if #enemies == 1 then
		caster:ManaOnHit( base_mana )
		EmitSoundOn( "Hero_Juggernaut.Attack", self:GetCaster() )
	elseif #enemies == 2 then
		caster:ManaOnHit( base_mana + ( math.fmod(#enemies,bonus_mana) ))
		EmitSoundOn( "Hero_Juggernaut.Attack", self:GetCaster() )
	elseif #enemies == 3 then
		caster:ManaOnHit( base_mana + ( math.fmod(#enemies,bonus_mana) ))
		EmitSoundOn( "Hero_Juggernaut.Attack", self:GetCaster() )
	elseif #enemies == 0 then
		return
	else
		caster:ManaOnHit( base_mana + bonus_mana )
		EmitSoundOn( "Hero_Juggernaut.Attack", self:GetCaster() )
	end
end
--------------------------------------------------------------------------------


