item_rock = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "green_cube_on_attacked", "bosses/techies/modifiers/green_cube_on_attacked", LUA_MODIFIER_MOTION_NONE )

function item_rock:OnSpellStart()
    local caster = self:GetCaster()
    local origin = caster:GetOrigin()

    local vTargetPos = nil
    vTargetPos = self:GetCursorPosition()

    -- create it at players location, then throw it... in an arc...
    local rock = CreateUnitByName("npc_rock_techies", origin, true, caster, caster, DOTA_TEAM_GOODGUYS)
    rock:AddNewModifier(caster, self, "modifier_phased", {duration = -1})
    rock:SetForwardVector( Vector( RandomFloat(-1, 1) , RandomFloat(-1, 1), RandomFloat(-1, 1) ) )
    rock:SetRenderColor(255,0,255)

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
            speed = 1500,
            distance = ( origin - vTargetPos):Length2D(),
            height = 300,
            fix_end = true,
            fix_height = false,
            isStun = true,
        } -- kv
    )

    arc:SetEndCallback( function()
        ParticleManager:DestroyParticle(nFXIndex,false)
        --rock:AddNewModifier( caster, self, "green_cube_on_attacked", { duration = -1 } )
    end)

    self:SpendCharge(1)

end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

function item_rock:GetAOERadius()
	return 150
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------