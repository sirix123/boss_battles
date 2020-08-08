clock_hookshot_modifier = class({})

function clock_hookshot_modifier:IsHidden()
	return true
end

function clock_hookshot_modifier:IsDebuff()
	return false
end

function clock_hookshot_modifier:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function clock_hookshot_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.duration = kv.duration
        self.location = Vector( kv.target_x, kv.target_y, kv.target_z )
        self.latch_radius = kv.latch_radius
        self.speed = kv.speed

        self.distance = (self.location - self:GetCaster():GetAbsOrigin()):Normalized()

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
        end

	end
end
---------------------------------------------------------------------------

function clock_hookshot_modifier:UpdateHorizontalMotion(me, dt)
    if IsServer() then

        self.distance	= (self.location - self:GetCaster():GetAbsOrigin()):Normalized()

        me:SetOrigin( me:GetAbsOrigin() + self.distance * self.speed * dt )

        if (self:GetCaster():GetAbsOrigin() - self.location):Length2D() <= self.latch_radius then
            FindClearSpaceForUnit(self:GetParent(), self.location - self.distance * (self:GetParent():GetHullRadius()), true)
            self:Destroy()
        end

    end
end
---------------------------------------------------------------------------

function clock_hookshot_modifier:OnDestroy( kv )
    if IsServer() then

        self:GetParent():RemoveHorizontalMotionController( self )
        self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Damage")

        -- add generic stun to target
        -- just to disable abilities and give a bit of flavour
        local enemies = FindUnitsInRadius(
            DOTA_TEAM_BADGUYS,
            self.parent:GetAbsOrigin(),
            nil,
            100,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )

        if #enemies > 0 then
            for _,enemy in pairs(enemies) do
                enemy:AddNewModifier(self:GetCaster(), self, "stunned_modifier", { duration = self:GetAbility():GetSpecialValueFor( "knock_stun_duration" ) } )

                -- arc modifier
                -- references
                local distance = self:GetAbility():GetSpecialValueFor( "knock_distance" ) -- special value 1000
                local speed = self:GetAbility():GetSpecialValueFor( "knock_speed" ) -- special value500 
                local height = self:GetAbility():GetSpecialValueFor( "knock_height" )

                -- leap
                local arc = enemy:AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "modifier_generic_arc_lua", -- modifier name
                    {
                        distance = distance,
                        speed = speed,
                        height = height,
                        fix_end = false,
                        isForward = false,
                    } -- kv
                )

                arc:SetEndCallback( function()
                end)
            end
        end
	end
end
---------------------------------------------------------------------------

function clock_hookshot_modifier:OnHorizontalMotionInterrupted()
	self:Destroy()
end
---------------------------------------------------------------------------