class Title extends h2d.Object {

	static var TITLE = "Heisenberg";
	var font : h2d.Font;
	var bitmaps : Array<h2d.Bitmap>;
	var distort : h3d.shader.SinusDeform;

	public function new(onEnd) {
		var game = Game.inst;
		super(game.s2d);

		distort = new h3d.shader.SinusDeform(100, 0.005, 10);

		font = hxd.Res.ua_squared128.toFont();
		var px = 0;
		var bmps = new h2d.Object(this);
		bitmaps = [for( i in 0...TITLE.length ) {
			var c = font.getChar(TITLE.charCodeAt(i));
			var b = new h2d.Bitmap(c.t, bmps);
			b.x = px;
			px += c.width;
			b;
		}];
		bmps.x = Std.int((game.s2d.width - px) * 0.5);
		bmps.y = 200;

		var tf = new h2d.Text(hxd.Res._8bit.toFont(), this);
		tf.text = "@ncannasse / LD#34";
		tf.x = tf.y = 8;


		var tf = new h2d.Text(hxd.Res._8bit.toFont(), this);
		tf.text = "Please turn Sound ON\nClick to Start";
		tf.maxWidth = Std.int(game.s2d.width / tf.scaleX);
		tf.textAlign = Center;
		tf.y = 400;
		tf.alpha = 0.5;

		var i = new h2d.Interactive(game.s2d.width, game.s2d.height, this);
		i.onClick = function(_) {
			hxd.Res.sfx.button.play();
			i.remove();
			tf.remove();
			game.event.waitUntil(function(dt) {
				alpha -= dt * 0.003;
				if( alpha < 0 ) {
					remove();
					game.event.wait(60, onEnd);
					return true;
				}
				return false;
			});
		};
	}

	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		for( i in 0...bitmaps.length ) {
			var code;
			var b = bitmaps[i];
			b.removeShader(distort);
			if( Std.random(7 - Std.int((1 - alpha) * 10)) == 0 ) {
				code = "A".code + Std.random(26);
				b.addShader(distort);
			} else {
				code = TITLE.charCodeAt(i);
			}
			b.tile = font.getChar(code).t;
		}
	}

}