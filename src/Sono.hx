class Sono extends ImageFinder {

	var isON : Bool;
	var screen : h2d.Text;
	var toType = [];
	var typeTime = 0.;
	var screenText : String;

	public function new(onEnd) {
		super(hxd.Res.sono, 1.5, 0, 0, 0, 0, onEnd);
		var b = new h2d.Bitmap(hxd.Res.sonoButton.toTile(), bmp);
		b.tile.dx = -(b.tile.width >> 1);
		b.tile.dy = -(b.tile.height >> 1);
		b.x = 816 + (b.tile.width>>1);
		b.y = 61 + (b.tile.height >> 1);
		b.filter = true;

		game.event.waitUntil(function(dt) {
			if( isON ) b.rotation += dt * 0.02;
			return stop;
		});

		function addPush(x:Int, y:Int, w:Int, h:Int, ?onClick, ?isPower) {
			if( onClick == null ) onClick = function() { };
			if( !isPower ) {
				var old = onClick;
				onClick = function() {
					if( !isON ) return;
					old();
				};
			}
			var i = addButton(x, y, w, h, onClick );
			var s = new h2d.ScaleGrid(bmp.tile.sub(x, y, w, h), 0, 4, i);
			s.width = w;
			s.height = h;
			s.filter = true;
			var dh = h < 20 ? 2 : (isPower ? 6 : 4);
			i.onOver = function(_) {
				s.height = h - dh;
				s.y = dh;
			};
			i.onOut = function(_) {
				s.height = h;
				s.y = 0;
			};
		}

		// power
		addPush(90, 78, 64, 50, function() {
			isON = !isON;
			if( isON ) {
				hxd.Res.sfx.button.play();
				initScreen();
			} else {
				hxd.Res.sfx.over.play();
				var s = screen;
				screen = null;
				game.event.waitUntil(function(dt) {
					s.alpha -= 0.1 * dt;
					if( s.alpha < 0 ) {
						s.remove();
						return true;
					}
					return false;
				});
			}
		}, true);

		// set, clear, tuning
		addPush(277, 330, 54, 28);
		addPush(332, 330, 63, 28);
		addPush(390, 330, 110, 28);

		// Down / up
		addPush(527, 330, 62, 28);
		addPush(590, 330, 65, 28);

		// Rock, Pop, Jazz
		addPush(805, 326, 57, 30);
		addPush(872, 324, 57, 30);
		addPush(940, 324, 57, 30);

		// tape etc
		addPush(247, 250, 84, 15);
		addPush(360, 250, 84, 15);
		addPush(474, 250, 94, 15);
		addPush(592, 250, 94, 15);

	}

	function type( text : String ) {
		toType.push(text);
		typeTime = 0;
	}

	function initScreen() {
		screen = new h2d.Text(hxd.Res.liquid22.toFont(), bmp);
		screen.x = 240;
		screen.y = 85;
		screen.alpha = 0;
		screen.filters = [new h2d.filter.Bloom(1, 200,3,3,100)];
		screen.textColor = 0x00FFFF;

		screenText = "";

		game.event.wait(0.5, function() type("I AM ALICE"));

		game.event.waitUntil(function(dt) {
			if( screen == null )
				return true;
			screen.alpha += 0.05 * dt;
			if( screen.alpha > 0.5 ) {
				screen.alpha = 0.5;
				return true;
			}
			return false;
		});
	}

	override function update(dt:Float) {

		if( screen == null )
			toType = [];

		typeTime += dt / 60;
		while( toType.length > 0 && typeTime > 0.1 ) {
			typeTime -= 0.1;
			var t = toType.shift();
			if( t.charCodeAt(0) != " ".code )
				game.playKeyb();
			if( t == "" ) {
				screenText += "\n";
				toType.shift();
			} else {
				screenText += t.charAt(0);
				toType.unshift(t.substr(1));
			}
		}
		if( screen != null )
			screen.text = screenText + (Std.random(10) == 0 && toType.length > 0 ? String.fromCharCode("A".code + Std.random(26)) : Std.random(2) == 0 ? "_" : "");

		return super.update(dt);
	}


}