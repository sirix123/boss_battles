function CDOTA_BaseNPC:Initialize(data)
  self.direction = {}
  self.direction.x = 0
  self.direction.y = 0
  self.direction.z = 0

  self.mouse = {}
  self.mouse.x = 0
  self.mouse.y = 0
  self.mouse.z = 0

  self.bFirstSpawned = true

  self.animation_modifiers = {}

  self.playerId = self:GetPlayerID()
  print("core functions self.playerId ", self.playerId)

  self.playerLives = BOSS_BATTLES_PLAYER_LIVES
  self.playerHP = 0
  self.playerEnergy = 0
  self.playerDmgDone = 0

  self:SetHullRadius(50)

end

function CDOTA_BaseNPC:GetDirection()

  return Vector(self.direction.x, self.direction.y, nil)
end

function CDOTA_BaseNPC:IsWalking()
	local is_walking = false
	local direction = self:GetDirection()

	if direction.x ~= 0 or direction.y ~= 0 then
		if self:IsStunned() or self:IsCommandRestricted() or self:IsRooted() then
			return false
		else
			return true
		end
	else
		return false
	end
end

function CDOTA_BaseNPC:ManaOnHit(percentAmount)
	self:GiveMana(self:GetMaxMana() * percentAmount/100)
end
