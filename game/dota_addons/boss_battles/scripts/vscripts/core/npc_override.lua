function CDOTA_BaseNPC:Initialize(data)
  self.direction = {}
  self.direction.x = 0
  self.direction.y = 0
  self.direction.z = 0

  self.mouse = {}
  self.mouse.x = 0
  self.mouse.y = 0
  self.mouse.z = 0
  self.left_mouse_up_down = nil

  self.bFirstSpawned = true

  self.animation_modifiers = {}

  self.playerId = self:GetPlayerID()

  self.arcana_equipped = false

  self.playerLives = BOSS_BATTLES_PLAYER_LIVES
  self.playerDeaths = 0
  self.playerHP = 0
  self.playerEnergy = 0

  self.hp = self:GetHealth()
  self.maxHp = self:GetMaxHealth()
  self.hpPercent = self:GetHealthPercentCustom()
  self.mp = self:GetMana()
  self.maxMp = self:GetMaxMana()
  self.mpPercent = self:GetManaPercentCustom()

  self.type = nil
  self.command = nil
  self.previousType = nil
  self.previousCommand = nil
  self.playerLagging = false

  self.playerName = ""
  self.steamId = PlayerResource:GetSteamID(self.playerId)
  self.class_name = ""
  self.hero_name = self:GetUnitName()

  self.dmgDoneAttempt = 0
  self.dmgTakenAttempt = 0

  self.spell_interupt = false

  self.dmgDetails = {}
  self.dmgTakenDetails = {}
  self.deathsDetails = {}

  self.ready_up = false

  self:SetHullRadius(50)

end

function CDOTA_BaseNPC:GetDirection()
  --print("core functions, diretion ", Vector(self.direction.x, self.direction.y, nil))
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

function CDOTA_BaseNPC:GetManaPercentCustom()
	return self:GetManaPercent()
end

function CDOTA_BaseNPC:GetHealthPercentCustom()
	return self:GetHealthPercent()
end