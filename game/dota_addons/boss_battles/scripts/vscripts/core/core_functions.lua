function CDOTA_BaseNPC:Initialize(data)
  self.direction = {}
  self.direction.x = 0
  self.direction.y = 0
  self.direction.z = 0

end

function CDOTA_BaseNPC:GetDirection()

  return Vector(self.direction.x, self.direction.y, nil)
end

function CDOTA_BaseNPC:IsWalking()
	local is_walking = false
	local direction = self:GetDirection()

	if direction.x ~= 0 or direction.y ~= 0 then
		return true
	else
		return false
	end
end

-- animations
MODIFIER_DISPLACEMENT = 1
MODIFIER_COUNTER = 2
MODIFIER_REFLECT = 3
MODIFIER_ANIMATION = 4
MODIFIER_CHANNELING = 5 
MODIFIER_CHARGES = 6 

function CDOTA_BaseNPC:IsAnimating()
	return self.animation_modifiers and #self.animation_modifiers > 0
end

function CDOTA_BaseNPC:AddModifierTracker(modifier_name, type) 	
	local key = nil

	if type == MODIFIER_DISPLACEMENT then key = "displacement_modifiers" end
	if type == MODIFIER_COUNTER then key = "counter_modifiers" end
	if type == MODIFIER_REFLECT then key = "reflect_modifiers" end
	if type == MODIFIER_ANIMATION then key = "animation_modifiers" end
	if type == MODIFIER_CHANNELING then key = "channeling_modifiers" end
	if type == MODIFIER_CHARGES then key = "charges_modifiers" end
	if type == MODIFIER_FEAR then key = "fear_modifiers" end

	table.insert(self[key], modifier_name)
end

function CDOTA_BaseNPC:RemoveModifierTracker(modifier_name, type)
	local key = nil
	
	if type == MODIFIER_DISPLACEMENT then key = "displacement_modifiers" end
	if type == MODIFIER_COUNTER then key = "counter_modifiers" end
	if type == MODIFIER_REFLECT then key = "reflect_modifiers" end
	if type == MODIFIER_ANIMATION then key = "animation_modifiers" end
	if type == MODIFIER_CHANNELING then key = "channeling_modifiers" end
	if type == MODIFIER_CHARGES then key = "charges_modifiers" end
	if type == MODIFIER_FEAR then key = "fear_modifiers" end

	for _,m_modifier_name in pairs(self[key]) do
		if m_modifier_name == modifier_name then
			self[key][_] = nil
		end
	end
end