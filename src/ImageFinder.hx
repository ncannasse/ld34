
class ImageFinder {

	var game : Game;
	var bmp : h2d.Bitmap;
	var stop = false;
	var bloom : h2d.filter.Bloom;
	var int : h2d.Interactive;

	public function new( r : hxd.res.Image, scale : Float, px : Int, py : Int, w : Int, h : Int, onEnd ) {
		game = Game.inst;
		bmp = new h2d.Bitmap(r.toTile(), game.s2d);
		bmp.setScale(scale);
		game.event.waitUntil(update);

		var b = new h2d.filter.Bloom(1, 1);
		bmp.filters = [b];
		bmp.alpha = 0;
		bloom = b;

		var i = new h2d.Interactive(w, h, bmp);
		i.x = px;
		i.y = py;
		//i.backgroundColor = 0x10FF0000;
		i.onPush = function(_) {
			i.remove();
			hxd.Res.sfx.button.play();
			exit(onEnd);
		};
		int = i;
	}

	function exit( onEnd ) {
		if( stop ) return;
		var m = new h3d.Matrix();
		m.identity();
		bmp.filters.unshift( new h2d.filter.ColorMatrix(m) );
		game.event.waitUntil(function(dt) {
			m._41 += dt * 0.0015;
			m._42 += dt * 0.0015;
			m._43 += dt * 0.0015;
			bloom.amount += dt;
			if( bloom.amount > 100 ) {
				bmp.remove();
				onEnd();
				return true;
			}
			return false;
		});
		stop = true;
	}

	function addButton( x, y, w, h, onClick ) {
		var p = new h2d.Interactive(w, h, bmp);
		p.x = x;
		p.y = y;
		p.onPush = function(_) onClick();
		//p.backgroundColor = 0x20FF0000;
		return p;
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