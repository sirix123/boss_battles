var targetingIndicators = {};

var playerId = Players.GetLocalPlayer();
var heroIndex = null;
var mouse_position_screen = null;
var mouse_position = null;
var particle_line = null;

function UpdateTargetIndicator(){
    var active = null;
    
    //var playerEnt = Players.GetPlayerHeroEntityIndex( playerId );
    //var abilityCount = Entities.GetAbilityCount( playerEnt )
    //$.Msg(abilityCount)

    if(!heroIndex){
        heroIndex = Players.GetPlayerHeroEntityIndex(playerId);
        $.Schedule(1/144, UpdateTargetIndicator);
        return
    }

    for(var i = 0; i < 10; i++){
        var abilityIndex = Entities.GetAbility(heroIndex, i);
        if(Abilities.IsInAbilityPhase(abilityIndex)){
            active = abilityIndex;
        }
    }

    if(active){
        var data = targetingIndicators[Abilities.GetAbilityName(active)];
        if(data){
            var heroOrigin = Entities.GetAbsOrigin(heroIndex)
            mouse_position_screen = GameUI.GetCursorPosition();
            mouse_position = Game.ScreenXYToWorld(mouse_position_screen[0], mouse_position_screen[1])
            var direction = Game.Normalized([
                (mouse_position[0] - heroOrigin[0]),
                (mouse_position[1] - heroOrigin[1]),
                (mouse_position[2] - heroOrigin[2])
            ])	

            if(data.Type == "TARGETING_INDICATOR_LINE" ){
                if(!particle_line){
                    particle_line = Particles.CreateParticle("particles/ui_mouseactions/range_finder_tower_line.vpcf", ParticleAttachment_t.PATTACH_WORLDORIGIN, heroIndex);
                }

                var max_range = Abilities.GetCastRange(active);
                var min_range = Abilities.GetSpecialValueFor(active, "min_range");
                var radius = Abilities.GetSpecialValueFor(active, "radius")
                var length = 0;
                var target = [];
                
                if(data.Fixed == "1"){
                    length = max_range;
                } else {
                    length = Clamp(Game.Length2D(mouse_position, heroOrigin), min_range, max_range);
                }

                length = length - radius;

                var target = [
                    heroOrigin[0] + (direction[0] * length),
                    heroOrigin[1] + (direction[1] * length),
                    heroOrigin[2] + (direction[2] * length)
                ]

                var target_offset = [
                    target[0] + (direction[0] * 150),
                    target[1] + (direction[1] * 150),
                    target[2] + (direction[2] * 150)
                ]	

                Particles.SetParticleControl(particle_line, 0, heroOrigin)
                Particles.SetParticleControl(particle_line, 1, target);
                Particles.SetParticleControl(particle_line, 2, target_offset);
            }
        }
    } else 
    {
        if(particle_line){
            Particles.DestroyParticleEffect(particle_line, false)
            Particles.ReleaseParticleIndex(particle_line)
            particle_line = null
        }
    }
    
    $.Schedule(1/144, UpdateTargetIndicator);
}

UpdateTargetIndicator();

targetingIndicators = CustomNetTables.GetTableValue("main", "targetingIndicators");
$.Msg(targetingIndicators)

function Clamp(num, min, max) {
    return num < min ? min : num > max ? max : num;
}

//SubscribeToNetTableKey("main", "targetingIndicators", true, function(data){
  //  targetingIndicators = data;
//});

//$.Msg("hello")
