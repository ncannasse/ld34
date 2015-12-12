class Digicode extends ImageFinder {

	var code = "";

	var tf : h2d.Text;
	var time = 0.;
	var cursor : Bool;

	public function new( onEnd ) {
		super(hxd.Res.digicode, 1.5, 375, 720, 50, 30, function() onEnd(code));

		tf = new h2d.Text(hxd.Res._8bit.toFont(), bmp);
		tf.text = "";
		tf.x = 302;
		tf.y = 470;
		tf.rotation = 0.08;
		tf.scale(3);

		var clear = new h2d.Interactive(33, 33, bmp);
		clear.x = 385;
		clear.y = 685;
		clear.onClick = function(_) {
			hxd.Res.sfx.button.play();
			code = "";
			refresh();
		};

		for( x in 0...3 )
			for( y in 0...4 ) {
				var p = new h2d.Interactive(35, 33, bmp);
				p.x = [253, 295, 336][x];
				p.y = [600, 636, 675, 712][y] + x * 3;
				p.onClick = function(_) {
					if( code.length == 4 ) {
						hxd.Res.sfx.over.play();
						return;
					}
					hxd.Res.sfx.button.play();
					code += "123456789*0#".charAt(x + y * 3);
					refresh();
				};
			}
	}

	function refresh() {
		tf.text = code+(cursor && code.length < 4 ? "_" : "");
	}

	override function update(dt:Float) {
		var r = super.update(dt);
		time += dt / 10;
		if( time > 1 ) {
			time--;
			cursor = !cursor;
			refresh();
		}
		return r;
	}

}