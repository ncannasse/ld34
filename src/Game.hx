class Game extends hxd.App {

	public var event : hxd.WaitEvent;
	var script : Script;
	var log : Array<h2d.Text> = [];
	var buttons : h2d.Sprite;
	var greenText : h2d.Text;
	var redText : h2d.Text;
	var askCallback : Bool -> Void;

	public function new() {
		super();
		inst = this;
		event = new hxd.WaitEvent();
	}

	function newText( text, ?parent ) {
		var tf = new h2d.Text(hxd.Res.ua_squared22.toFont(), parent);
		tf.text = text;
		return tf;
	}

	function playEnv( volume = 1. ) {
		hxd.Res.load("sfx/envSfx" + (1 + Std.random(5)) + ".mp3").toSound().play(false, volume);
	}


	override function init() {

		hxd.Res.sfx.envLoop.play(true);

		var wait = 1.;
		event.waitUntil(function(dt) {
			wait -= dt / 60;
			if( wait < 0 ) {
				playEnv(0.1 + Math.random() * 0.2);
				wait += 1 + hxd.Math.random(2);
			}
			return false;
		});


		buttons = new h2d.Sprite(s2d);

		var green = new h2d.Bitmap(hxd.Res.buttonGreen.toTile(), buttons);
		green.x = 30;
		green.y = 300;
		var tf = newText("", green);
		tf.textColor = 0x38d930;
		tf.x = 52;
		tf.y = 10;
		greenText = tf;

		var red = new h2d.Bitmap(hxd.Res.buttonRed.toTile(), buttons);
		red.x = 400;
		red.y = 300;
		tf = redText = newText("", red);
		tf.textColor = 0xd93232;
		tf.x = 52;
		tf.y = 10;

		var gbloom = new h2d.filter.Bloom(1, 0, 4, 3, 0.1);
		var rbloom = new h2d.filter.Bloom(1, 0, 4, 3, 0.1);
		green.filters = [gbloom];
		red.filters = [rbloom];
		var bloomTime = 0.;
		event.waitUntil(function(dt) {
			bloomTime += dt * 0.1;
			gbloom.amount = 1 * Math.abs(Math.sin(bloomTime) * Math.cos(bloomTime * 0.3));
			rbloom.amount = 2.5 * Math.abs(Math.sin(bloomTime * 0.5) * Math.sin(bloomTime * 1.2));
			return false;
		});

		var gint = new h2d.Interactive(green.tile.width, green.tile.height, green);
		gint.onOver = function(_) {
			green.color.set(1.2, 1.2, 1.2);
			hxd.Res.sfx.over.play();
		};
		gint.onOut = function(_) {
			green.color.set(1., 1., 1.);
		};
		gint.onClick = function(_) {
			askCallback(true);
		};

		var rint = new h2d.Interactive(red.tile.width, red.tile.height, red);
		rint.onOver = function(_) {
			red.color.set(1.2, 1.2, 1.2);
			hxd.Res.sfx.over.play();
		};
		rint.onOut = function(_) {
			red.color.set(1., 1., 1.);
		};
		rint.onClick = function(_) {
			askCallback(false);
		};

		buttons.visible = false;

		script = new Script("");
		script.load(hxd.Res.Script.entry.getText());
		script.call("main", [], function() trace("END"));
	}

	override function update(dt:Float) {
		event.update(dt);
	}

	public function talk( text : String, onEnd : Void -> Void ) {

		var alpha = 0.6;
		for( l in log ) {
			l.y -= 30;
			var a = alpha;
			event.waitUntil(function(dt) {
				l.alpha -= dt * 0.02;
				if( l.alpha < a )
					return true;
				return false;
			});
			alpha *= 0.6;
		}

		var tf = newText(text, s2d);
		tf.x = Std.int((s2d.width - tf.textWidth) * 0.5);
		tf.text = "";
		tf.y = 150;
		log.unshift(tf);
		var pos = 0.;
		var last = 0;
		var first = true;
		var rand = 0;
		event.waitUntil(function(dt) {
			pos += dt * 0.5;
			var ipos = Std.int(pos);
			if( ipos != last ) {
				if( (++rand) & 1 == 1 ) {
					if( text.charCodeAt(ipos - 1) == " ".code )
						rand = 0;
					else
						hxd.Res.load("sfx/keyb" + (1 + Std.random(5)) + ".mp3").toSound().play();
				}
				tf.text = text.substr(0, ipos);
				last = ipos;
				if( last >= text.length ) {
					onEnd();
					return true;
				}
			}
			return false;
		});
	}

	public function ask( yes : String, no : String, onChoice : Bool -> Void ) {
		buttons.visible = true;
		buttons.alpha = 0;
		event.waitUntil(function(dt) {
			buttons.alpha += 0.1 * dt;
			if( buttons.alpha > 1 ) {
				buttons.alpha = 1;
				return true;
			}
			return false;
		});
		redText.text = yes;
		greenText.text = no;
		askCallback = function(b) {
			hxd.Res.sfx.button.play();
			askCallback = function(b) { };
			event.waitUntil(function(dt) {
				buttons.alpha -= 0.2 * dt;
				if( buttons.alpha < 0 ) {
					buttons.visible = false;
					event.wait(0.5, function() onChoice(b));
					return true;
				}
				return false;
			});
		};
	}

	public static var inst : Game;

	static function main() {
		hxd.Res.initEmbed({ compressSounds : true });
		new Game();
	}

}