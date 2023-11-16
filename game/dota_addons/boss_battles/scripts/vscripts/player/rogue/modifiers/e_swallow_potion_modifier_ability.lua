e_swallow_potion_modifier_ability = class({})
LinkLuaModifier( "e_swallow_potion_modifier", "player/rogue/modifiers/e_swallow_potion_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "e_swallow_potion_modifier_debuff", "player/rogue/modifiers/e_swallow_potion_modifier_debuff", LUA_MODIFIER_MOTION_NONE )

-----------------------------------------------------------------------------
-- Classifications
function e_swallow_potion_modifier_ability:IsHidden()
	return false
end

function e_swallow_potion_modifier_ability:IsDebuff()
	return false
end

function e_swallow_potion_modifier_ability:IsStunDebuff()
	return false
end

function e_swallow_potion_modifier_ability:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function e_swallow_potion_modifier_ability:GetEffectName()
	return "particles/rogue/bb_test_envem_phantom_assassin_mark_overhead.vpcf"
end

function e_swallow_potion_modifier_ability:GetStatusEffectName()
	return
end

function e_swallow_potion_modifier_ability:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
-----------------------------------------------------------------------------

function e_swallow_potion_modifier_ability:OnCreated( kv )
	if IsServer() then
    end
end

function e_swallow_potion_modifier_ability:OnRefresh( kv )
	if IsServer() then
    end
end

function e_swallow_potion_modifier_ability:OnDestroy()
    if IsServer() then
    end
end
-----------------------------------------------------------------------------

function e_swallow_potion_modifier_ability:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function e_swallow_potion_modifier_ability:OnAttack( params )
	if not IsServer() then return end
	if params.attacker~=self:GetParent() then return end

	local caster = self:GetCaster()
	local origin = caster:GetOrigin()

	-- function in utility_functions
	local point = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z)

	local radius = self:GetAbility():GetSpecialValueFor("radius")
    local direction = caster:GetForwardVector()
    local final_position = caster:GetAbsOrigin()

    local damage = self:GetAbility():GetSpecialValueFor("damage")

    -- load data
    local duration = self:GetAbility():GetSpecialValueFor( "duration" )

	-- function in utility_functions
	local enemies = FindUnitsInCone(
		caster:GetTeamNumber(),
		direction,
		origin,
		5,
		radius,
		self:GetAbility():GetCastRange(Vector(0,0,0), nil),
		nil,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		FIND_ANY_ORDER,
		false)

	for _, enemy in pairs(enemies) do

		local dmgTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
        }

        -- add modifier
        enemy:AddNewModifier(
            caster, -- player source
            self:GetAbility(), -- ability source
            "e_swallow_potion_modifier_debuff", -- modifier name
            { duration = duration } -- kv
        )

		EmitSoundOn( "Hero_PhantomAssassin.Attack", self:GetCaster() )

        ApplyDamage(dmgTable)

	end

	if enemies ~= nil and #enemies ~= 0 then
        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self:GetAbility(), -- ability source
            "e_swallow_potion_modifier", -- modifier name
            { 
                duration = -1, 
                energy_regen_bonus = self:GetAbility():GetSpecialValueFor( "energy_regen_bonus" )
            } -- kv
        )
	end

	local particle_cast = "particles/rogue/rogue_m2_pa_arcana_attack_blinkb.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effect_cast, 0, final_position)
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

    EmitSoundOn( "Hero_PhantomAssassin.FanOfKnives", self:GetCaster() )

    self:Destroy()
end