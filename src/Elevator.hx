class Elevator extends ImageFinder {

	var light : h2d.Bitmap;
	var targetAlpha = 0.;
	var alpha = 0.;

	public function new( onEnd : Null<Int> -> Void ) {
		super(hxd.Res.elevator, 2., 518, 605, 42, 41, function() onEnd(null));

		light = new h2d.Bitmap(hxd.Res.levelButton.toTile(), bmp);
		light.alpha = targetAlpha = 0.;
		light.blendMode = Add;

		int.onOver = function(_) {
			hxd.Res.sfx.buttonLight.play();
			light.color.set(0, 1, 0, 1);
			light.alpha = alpha = 0;
			targetAlpha = 0.3;
			light.x = int.x - 5;
			light.y = int.y - 5;
		};
		int.onOut = function(_) {
			targetAlpha = 0.;
		};

		function addStage(x, y, k) {
			var i = addButton(x, y, 40, 40, function() {
				hxd.Res.sfx.button.play();
				exit(function() onEnd(k));
			});
			i.isEllipse = true;
			i.onOver = function(_) {
				light.color.set(1, 1, k == 666 ? 0 : 1, 1);
				light.alpha = alpha = 0;
				targetAlpha = 0.3;
				light.scaleY = k <= 0 ? 0.85 : 1;
				light.x = x - 5;
				light.y = y - 5;
				hxd.Res.sfx.buttonLight.play();
			};
			i.onOut = function(_) {
				targetAlpha = 0.;
			};
			return i;
		}

		addStage(510, 819, 3);
		addStage(662, 807, 4);
		addStage(508, 907, 1);
		addStage(654, 891, 2);
		addStage(505, 987, -1);
		addStage(647, 972, 0);

		addStage(680, 597, 666).onClick = function(_) {
			hxd.Res.sfx.alarm.play();
		};
	}

	override function update(dt:Float) {
		var r = super.update(dt);
		alpha = hxd.Math.lerp(alpha, targetAlpha, 1 - Math.pow(0.3, dt));
		light.alpha = alpha * (1 + hxd.Math.srand(0.1));
		return r;
	}

}