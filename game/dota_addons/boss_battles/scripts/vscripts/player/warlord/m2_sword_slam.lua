m2_sword_slam = class({})

--------------------------------------------------------------------------------

function m2_sword_slam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_sword", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "blade_attachment", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(nfx)

        return true
    end
end
---------------------------------------------------------------------------

function m2_sword_slam:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------
function m2_sword_slam:OnSpellStart()
	self.caster = self:GetCaster()
	local origin = self.caster:GetOrigin()

	-- remove casting animation
	self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

	-- function in utility_functions
	local point = Clamp(origin, self:GetCursorPosition(), self:GetCastRange(Vector(0,0,0), nil), self:GetCastRange(Vector(0,0,0), nil))

    -- projectile init
    local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

    local vTargetPos = nil
    vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
    local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

    local projectile = {
        EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
        vSpawnOrigin = origin + Vector(0, 0, 100),
        fDistance = self:GetCastRange(Vector(0,0,0), nil),
        fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
        Source = self.caster,
        vVelocity = projectile_direction * projectile_speed,
        UnitBehavior = PROJECTILES_NOTHING,
        TreeBehavior = PROJECTILES_NOTHING,
        WallBehavior = PROJECTILES_NOTHING,
        GroundBehavior = PROJECTILES_NOTHING,
        fGroundOffset = 80,
        UnitTest = function(_self, unit)
            return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
        end,
        OnUnitHit = function(_self, unit)

            -- init icelance dmg table
            local dmgTable = {
                victim = unit,
                attacker = self.caster,
                damage = self:GetSpecialValueFor( "dmg" ),
                damage_type = self:GetAbilityDamageType(),
            }

            -- applys base dmg icelance regardles of stacks
            ApplyDamage(dmgTable)

        end,
        OnFinish = function(_self, pos)

        end,
    }

    -- create projectile and launch it
    Projectiles:CreateProjectile(projectile)

end
--------------------------------------------------------------------------------
