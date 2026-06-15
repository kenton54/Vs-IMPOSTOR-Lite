package objects;

import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;

// Part of the code taken from kenton's vs impostor pixel mod which you should totally check out!!!
// VS IMPOSTOR Pixel: https://gamebanana.com/mods/506768

class SnowEmitter extends FlxEmitter
{
    public var snowScrollFactor:Dynamic = {x: {x: 1, y: 1}, y: {x: 1, y: 1}};
    public var snowEmitterAlpha:Float = 1;

    var isSnowEmitterAdded:Bool = false;

    public function new(x:Float = 0, y:Float = 0, size:Int = 50, width:Float = 1200)
    {
        super(x, y, size);
        this.width = width;

        this.makeParticles(5, 5, FlxColor.WHITE, size);
        this.launchMode = (FlxG.random.bool(50) ? SQUARE : CIRCLE);
        this.launchAngle.set(100, 160);
        this.angularVelocity.set(-80, 100);
        this.speed.set(500, 700);
        this.scale.set(1, 1, 3, 3);
        this.lifespan.set(1800, 1800);
        this.keepScaleRatio = true;

        isSnowEmitterAdded = true;
        updateScrollFactor();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(isSnowEmitterAdded && this != null)
        {
            this.alpha.set(snowEmitterAlpha);
            for(snow in this.members)
            {
                if(snow == null) continue;
                snow.alpha = snowEmitterAlpha;
            }
        }
    }

    public function updateScrollFactor()
    {
        for(snow in this.members)
        {
            var scrollX:Float = FlxG.random.float(snowScrollFactor.x.x, snowScrollFactor.x.y);
            var scrollY:Float = FlxG.random.float(snowScrollFactor.y.x, snowScrollFactor.y.y);
            snow.scrollFactor.set(scrollX, scrollY);
        }
    }

    public function startSnowEmitter(speed:Float = 0.05)
    {
        this.start(false, speed);
    }

    public function tweenSnowEmitterAlpha(?alphaa:Float = 1, ?time:Float = 1, ?startDelay:Float = 0)
    {
        FlxTween.num(snowEmitterAlpha, alphaa, time, {startDelay: startDelay}, (f) -> {
            snowEmitterAlpha = f;
        });
    }
}