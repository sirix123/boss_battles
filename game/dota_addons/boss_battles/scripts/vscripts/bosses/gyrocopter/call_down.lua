call_down = class({})





function call_down:OnSpellStart()


end



function call_down:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end