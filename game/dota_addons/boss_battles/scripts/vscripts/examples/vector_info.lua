vector_info = class({})

function vector_info:OnSpellStart()
    
    local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()

    
    local vFrontDirection = caster:GetForwardVector()
    --local vBackDirection = -caster:GetForwardVector()
    local vRightDirection = caster:GetRightVector()
    --local vLeftDirection = -caster:GetRightVector()

    --local vFrontRightDirection 	=	Vector(	RandomFloat( 0 	, 1 ), RandomFloat( 0 , 1 ), 0 )
    --local vFrontLeftDirection 	=	Vector(	RandomFloat( -1 , 0 ), RandomFloat( 0 , 1 ), 0 )
    --local vBackRightDirection 	=	Vector(	RandomFloat( 0 	, 1 ), RandomFloat( -1 , 0 ), 0 )
    --local vBackLeftDirection 	=	Vector(	RandomFloat( -1 , 0 ), RandomFloat( -1 , 0 ), 0 )

    --local vFrontDirection 		=	Vector(	RandomFloat( -1 , 1 ), 1, 0 )
    --local vBackDirection 		=	Vector(	RandomFloat( -1 , 1 ), -1, 0 )
    --local vRightDirection 		=	Vector(	1, RandomFloat( -1 , 1 ), 0 )
    --local vLeftDirection 		=	Vector(	-1, RandomFloat( -1 , 1 ), 0 )

   -- DebugDrawCircle(    origin + (Vector(randomFrontRightLocationX,randomFrontRightLocationY,0)   * 80)        , Vector(0,255,255), 128, 20, true, 2)

    DebugDrawCircle(    origin + (vFrontDirection     * 80)        , Vector(0,255,255), 128, 20, true, 2)
    DebugDrawCircle(    origin + (vRightDirection      * 80)        , Vector(0,255,0), 128, 20, true, 2)
    --DebugDrawCircle(    origin + (vBackRightDirection     * 80)        , Vector(255,0,255), 128, 20, true, 2)
    --DebugDrawCircle(    origin + (vBackLeftDirection      * 80)        , Vector(255,0,0), 128, 20, true, 2)

    --DebugDrawCircle(    origin + (vFrontDirection     * 80)        , Vector(0,255,255), 128, 20, true, 2)
    --DebugDrawCircle(    origin + (vBackDirection      * 80)        , Vector(0,255,0), 128, 20, true, 2)
    --DebugDrawCircle(    origin + (vRightDirection     * 80)        , Vector(255,0,255), 128, 20, true, 2)
    --DebugDrawCircle(    origin + (vLeftDirection      * 80)        , Vector(255,0,0), 128, 20, true, 2)

    print("-----------------------")
    print(vFrontDirection)
    --print(vBackDirection)
    print(vRightDirection)
    --print(vLeftDirection)



end


