
class ImageFinder {

	var game : Game;
	var bmp : h2d.Bitmap;
	var stop = false;

	public function new( r : hxd.res.Image, scale : Float, px : Int, py : Int, w : Int, h : Int, onEnd ) {
		game = Game.inst;
		bmp = new h2d.Bitmap(r.toTile(), game.s2d);
		bmp.setScale(scale);
		game.event.waitUntil(update);

		var b = new h2d.filter.Bloom(1, 1);
		bmp.filters = [b];
		bmp.alpha = 0;

		var i = new h2d.Interactive(w, h, bmp);
		i.x = px;
		i.y = py;

		//i.backgroundColor = 0x10FF0000;

		i.onClick = function(_) {
			i.remove();

			hxd.Res.sfx.button.play();

			bmp.colorAdd = new h3d.Vector();
			game.event.waitUntil(function(dt) {
				bmp.colorAdd.r += dt * 0.0015;
				bmp.colorAdd.g += dt * 0.0015;
				bmp.colorAdd.b += dt * 0.0015;
				b.amount += dt;
				if( b.amount > 100 ) {
					bmp.remove();
					onEnd();
					return true;
				}
				return false;
			});
			stop = true;
		};
	}

	function update(dt:Float) {

		bmp.alpha += 0.1 * dt;
		if( bmp.alpha > 1 )
			bmp.alpha = 1;

		var x = game.s2d.mouseX / game.s2d.width;
		var y = game.s2d.mouseY / game.s2d.height;

		bmp.x = -(x * (bmp.tile.width * bmp.scaleX - game.s2d.width));
		bmp.y = -(y * (bmp.tile.height * bmp.scaleY - game.s2d.height));

		return stop;
	}

}