class XBox extends ImageFinder {

	var code = "";
	var off : h2d.Bitmap;
	var bar : h2d.Bitmap;
	var tf : h2d.Text;

	public function new(onEnd) {
		super(hxd.Res.xbox, 1., 820, 210, 90, 77, function() onEnd(code));
		int.isEllipse = true;
		off = new h2d.Bitmap(hxd.Res.xboxOff.toTile(), bmp);
		off.x = 800 - 5;
		off.y = 187 + 2;

		bar = new h2d.Bitmap(h2d.Tile.fromColor(0xCAC0E0, game.s2d.width, 32, 0.4), game.s2d);
		bar.y = game.s2d.height - bar.tile.height;

		tf = game.newText("", bar);
		tf.font = hxd.Res.liquid22.toFont();
		tf.scale(1.5);
		tf.filter = true;
		tf.dropShadow = { dx : 0, dy : 1, color : 0, alpha : 0.2 };

		bar.visible = false;

		var html = [];

		function addCode(c,color) {
			code += c;

			var color = h3d.Vector.fromColor(color, 1.5).toColor();

			html.push('<font color="#${StringTools.hex(color,6)}">$c</font>');
			if( code.length > 5 ) {
				code = code.substr(1);
				html.shift();
			}
			tf.text = html.join("");
			tf.y = 0;
			tf.x = game.s2d.width - (tf.textWidth  * tf.scaleX + 8);
			bar.visible = true;

			if( code == "XBABY" ) {
				hxd.Res.sfx.alarm.play();
				off.visible = false;
			} else
				off.visible = true;

		}

		function addXButton(x, y, w, h, onClick) {

			var b = new h2d.Bitmap(bmp.tile.sub(x, y, w, h), bmp);
			b.x = x;
			b.y = y;

			var i = addButton(x, y, w, h, null);
			i.isEllipse = true;
			i.onPush = function(_) {
				b.y = y + 3;
				hxd.Res.sfx.xboxButton.play();
				onClick();
			};
			i.onRelease = function(_) {
				b.y = y;
			};
		}

		addXButton(1010, 264, 69, 66, function() addCode("X", 0x1539bd));
		addXButton(1097, 243, 66, 60, function() addCode("Y", 0xba8900));
		addXButton(1066, 346, 70, 64, function() addCode("A", 0x457d1d));
		addXButton(1152, 317, 70, 70, function() addCode("B", 0x690e00));
	}

	override function exit(onEnd) {
		super.exit(onEnd);
		game.event.waitUntil(function(dt) {
			bar.alpha -= dt * 0.03;
			if( bar.alpha < 0 ) {
				bar.remove();
				return true;
			}
			return false;
		});
	}

}