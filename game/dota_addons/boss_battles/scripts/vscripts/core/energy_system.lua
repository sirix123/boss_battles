function FullManaOnSpawn( event ) 
    local hero = event.caster
    Timers:CreateTimer(.01, function()
    -- Set Mana to 0 on created
    hero:SetMana(100)
  end)
end

