blast_off = class({})

LinkLuaModifier( "blast_off_modifier", "bosses/techies/modifiers/blast_off_modifier", LUA_MODIFIER_MOTION_BOTH  )
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

function blast_off:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        --[[local radius = self:GetSpecialValueFor( "radius" )
		self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCursorPosition() )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
		ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( 0.8, 0, 0 ) );
		ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )]]

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function blast_off:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        -- find a random point inside the map arena
        local vTargetPos = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z) -- for testing
        --local vTargetPos = Vector(Rand)

        -- references
        local distance = (caster:GetAbsOrigin() - vTargetPos):Length2D()
        local speed = 1500 -- special value
        local height = 300

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
		--caster:AddParticle( nFXIndex, false, false, -1, false, false )

        -- leap
        local arc = caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = vTargetPos.x,
                target_y = vTargetPos.y,
                distance = distance,
                speed = speed,
                height = height,
                fix_end = true,
                fix_height = false,
                isStun = true,
                activity = ACT_DOTA_FLAIL,
            } -- kv
        )

        arc:SetEndCallback( function()
            self:GetCaster():RemoveGesture(ACT_DOTA_FLAIL)
            ParticleManager:DestroyParticle(nFXIndex,false)

            -- blowup
            self:BlowUp()

        end)

        --[[caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "blast_off_modifier", -- modifier name
            {
                duration = 5,
                x = vTargetPos.x,
                y = vTargetPos.y,
                z = vTargetPos.z,
            } -- kv
        )]]

    end
end

function blast_off:BlowUp()
    if IsServer() then

        -- dmg


        -- particle effect
        local radius = 200
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, 0.0, 1.0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector( radius, 0.0, 1.0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

        -- fog of war



    end
end