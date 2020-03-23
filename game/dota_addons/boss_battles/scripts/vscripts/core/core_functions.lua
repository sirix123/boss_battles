function CDOTA_BaseNPC:GiveManaPercent( percentage, source )
  --if source ~= nil and (source:IsAmethyst() or source:IsObstacle()) then
    --  return
  --end

  self:GiveMana(self:GetMaxMana() * percentage/100)
end