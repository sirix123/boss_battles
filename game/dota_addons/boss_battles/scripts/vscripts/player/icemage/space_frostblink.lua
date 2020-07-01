space_frostblink = class({})
--LinkLuaModifier( "space_frostblink_modifier_thinker", "player/icemage/modifiers/space_frostblink_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function space_frostblink:OnSpellStart()
    local caster = self:GetCaster()
	local origin = caster:GetOrigin()
    local point = nil
    point = Clamp(caster:GetOrigin(), GameMode.mouse_positions[caster:GetPlayerID()], self:GetCastRange(Vector(0,0,0), nil), 0)

    -- chill puddle
    -- apply chill to enemies around in a radius
    -- chill effect

    -- blink
    self:PlayEffects(0)
	FindClearSpaceForUnit(caster, point , true)
    self:PlayEffects(1)
end
---------------------------------------------------------------------------

function space_frostblink:PlayEffects(mode)
    if mode == 0 then
        local sound_cast = "DOTA_Item.BlinkDagger.Activate"
        EmitSoundOn(sound_cast, self:GetCaster())

	    local particle_cast = "particles/items_fx/blink_dagger_start.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

	local particle_cast = "particles/items_fx/blink_dagger_end.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end
---------------------------------------------------------------------------