saw_blade_return = class({})

function saw_blade_return:OnSpellStart()
    print("are we here)")
    for _, v in pairs(tSummonedSawBlades) do
        if v and not v:IsNull() then
            v:ReturnChakram()
        end
    end

    --reset tSummonedSawBlades as they're no longer 'active' and are being returned
    tSummonedSawBlades = {}
end
--------------------------------------------------------------------------------