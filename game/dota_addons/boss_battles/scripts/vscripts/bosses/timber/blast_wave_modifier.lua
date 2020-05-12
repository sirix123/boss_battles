blast_wave_modifier = class({})

function blast_wave_modifier:IsHidden()
	return false
end
---------------------------------------------------------------------

function blast_wave_modifier:IsDebuff()
	return true
end
---------------------------------------------------------------------

function blast_wave_modifier:OnCreated( kv )

	--print(self:GetParent():GetUnitName())

end
--------------------------------------------------------------------------------

function blast_wave_modifier:OnDestroy()

end
--------------------------------------------------------------------------------

function blast_wave_modifier:GetEffectName()
	return "particles/timber/batrider_ti8_immortal_firefly_path_blast_wave.vpcf"
end

