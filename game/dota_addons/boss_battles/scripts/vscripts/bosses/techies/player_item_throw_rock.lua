item_rock = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

function item_rock:OnSpellStart()
    local caster = self:GetCaster()
    local origin = caster:GetOrigin()

    local vTargetPos = nil
    vTargetPos = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    -- create it at players location, then throw it... in an arc...
    local rock = CreateUnitByName("npc_rock_techies", origin, true, nil, nil, DOTA_TEAM_GOODGUYS)

    local nFXIndex = ParticleManager:CreateParticle( "particles/techies/rock_throwtechies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, rock )
    ParticleManager:SetParticleControl(nFXIndex, 1, rock:GetAbsOrigin())

    -- arc the rock
    local arc = rock:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_generic_arc_lua", -- modifier name
        {
            target_x = vTargetPos.x,
            target_y = vTargetPos.y,
            speed = 800,
            distance = ( origin - vTargetPos):Length2D(),
            height = 300,
            fix_end = true,
            fix_height = false,
            isStun = true,
        } -- kv
    )

    arc:SetEndCallback( function()
        ParticleManager:DestroyParticle(nFXIndex,false)
    end)

    self:SpendCharge()

end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

function item_rock:GetAOERadius()
	return 150
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------