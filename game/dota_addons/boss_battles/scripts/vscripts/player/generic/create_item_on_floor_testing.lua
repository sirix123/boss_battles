create_item_on_floor_testing = class({})

---------------------------------------------------------------------------

function create_item_on_floor_testing:OnSpellStart()
    if IsServer() then

        local vTargetPos = nil
        vTargetPos = Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z)
      
        -- basic dota item that works
        --local newItem = CreateItem("item_tango", nil, nil)

        -- create test item
        local newItem = CreateItem("item_rock", nil, nil)
        local obj = CreateItemOnPositionForLaunch( vTargetPos, newItem )

        obj:SetModelScale(0.4)

        -- add that item particle glow
        local particle = "particles/techies/etherial_targetglow_repeat.vpcf"
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, obj)
        ParticleManager:SetParticleControl(nfx, 1, obj:GetAbsOrigin())

        --- add direction to it
        obj:SetForwardVector( Vector( RandomFloat(-1, 1) , RandomFloat(-1, 1), RandomFloat(-1, 1) ) )


        --[[ add spin effect
        Timers:CreateTimer(function()
            --print("obj ",obj:GetContainedItem())
            print("obj ",PrintTable(obj))

            if obj == nil then
                return false
            end

            local currentAngle = (GameRules:GetGameTime() % (math.pi * 2)) * 2.0
            obj:SetForwardVector(Vector(math.cos(currentAngle), math.sin(currentAngle)))

            return 0.03
        end)]]

	end
end
----------------------------------------------------------------------------------------------------------------
