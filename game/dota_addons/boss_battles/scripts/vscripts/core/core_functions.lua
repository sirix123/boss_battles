function CDOTA_BaseNPC:Initialize(data)
  self.direction = {}
  self.direction.x = 0
  self.direction.y = 0
  self.direction.z = 0

end

function CDOTA_BaseNPC:GetDirection()
  print("cdotastarted")
  return Vector(self.direction.x, self.direction.y, nil)
end

function CDOTA_BaseNPC:IsWalking()
	local direction = self:GetDirection()

	if direction.x ~= 0 or direction.y ~= 0 then
		return true
	else
		return false
	end
end