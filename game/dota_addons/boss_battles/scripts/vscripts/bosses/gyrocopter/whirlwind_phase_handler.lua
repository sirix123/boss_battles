
whirlwind_phase_handler = class({})


-----------------------------------------------------------------------------

function whirlwind_phase_handler:OnCreated(  )
    if IsServer() then
    end
end

function whirlwind_phase_handler:OnRemoved()
    if IsServer() then
    end
end

function whirlwind_phase_handler:OnDestroy()
    if IsServer() then
    end
end

-----------------------------------------------------------------------------