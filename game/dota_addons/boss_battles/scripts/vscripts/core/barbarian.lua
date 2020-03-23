 -- lua code inside barbarian.lua
 function ZeroManaOnSpawn( event ) 
    local hero = event.caster
    Timers:CreateTimer(.01, function()
    -- Set Mana to 0 on created
    hero:SetMana(0)
  end)
end

--function ManaOnAttack( event )
  --local hero = event.caster
  --local level = hero:GetLevel()

  --hero:GiveMana(10 * level + 3)
--end

function ManaOnAttacked( event )
  local hero = event.caster
  local level = hero:GetLevel()

  hero:GiveMana(6 * level + 0.4)
end
