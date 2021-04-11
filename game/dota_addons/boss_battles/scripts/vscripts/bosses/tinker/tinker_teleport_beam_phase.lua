tinker_teleport_beam_phase = class({})

function tinker_teleport_beam_phase:OnAbilityPhaseStart()
    if IsServer() then

        return true
    end
end

function tinker_teleport_beam_phase:OnSpellStart()
    if IsServer() then

        StopSoundOn("NeutralItem.TeleportToStash", self:GetCaster())

        -- move to loc
        --[[ pick one of 4 spots and teleport there
        local centre_point = Vector(-10633,11918,130.33)
        local radius = 1800
        local x = RandomInt(centre_point.x - radius - 100, centre_point.x + radius + 100)
        local y = RandomInt(centre_point.y - radius - 100, centre_point.y + radius + 100)
        local move_pos = Vector(x,y,0)]]

        FindClearSpaceForUnit(self:GetCaster(), Vector(0,0,0), true)


	end
end