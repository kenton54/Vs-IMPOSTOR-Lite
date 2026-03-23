package states.stages;

import backend.BaseStage;
import objects.BGSprite;

class StageWeek1 extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('bg/stage/stage', -1460, -1200, 1, 1);
		bg.scale.set(2.2, 2.2);
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);
	}
}