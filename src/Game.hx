class Game extends hxd.App {

	public var test = true;

	public var event : hxd.WaitEvent;
	var script : Script;
	var log : Array<h2d.HtmlText> = [];
	var buttons : h2d.Sprite;
	var greenText : h2d.HtmlText;
	var redText : h2d.HtmlText;
	var askCallback : Bool -> Void;
	var randomLetters : Array<h2d.Tile>;

	public function new() {
		super();
		inst = this;
		event = new hxd.WaitEvent();
	}

	public function newText( text, ?parent ) {
		var tf = new h2d.HtmlText(hxd.Res.ua_squared22.toFont(), parent);
		tf.loadImage = loadImage;
		tf.text = text;
		return tf;
	}

	function loadImage( src : String ) {
		if( StringTools.startsWith(src, "letter") )
			return randomLetters[Std.parseInt(src.substr(6))];
		return null;
	}

	function playEnv( volume = 1. ) {
		hxd.Res.load("sfx/envSfx" + (1 + Std.random(5)) + ".mp3").toSound().play(false, volume);
	}

	public function clearText( onEnd ) {
		var hasText = false;
		for( l in log.copy() )
			if( l.y < -20 ) {
				l.remove();
				log.remove(l);
			} else if( l.text != "" )
				hasText = true;
		if( !hasText ) {
			onEnd();
			return;
		}
		talk("", function() { } );
		event.wait(0.25, function() clearText(onEnd));
	}


	public function reboot( onEnd ) {
		clearText(function() {
			hxd.Res.sfx.envSfx4.play();
			new BlueScreen(function() {
				hxd.Res.sfx.over.play();
				event.wait(1, onEnd);
			});
		});
	}


	function start() {
		script.call("main", [], function() trace("END"));
	}

	override function init() {

		hxd.Res.sfx.envLoop.play(true);

		var font = newText("").font;
		var letters = [for( i in 0...26 ) font.getChar("A".code + i).t.clone()];
		for( l in letters ) l.dy -= 4;
		randomLetters = [for( l in letters ) l.clone()];
		function switchLetters(_) {
			for( i in 0...26 ) {
				if( Std.random(3) != 0 ) continue;
				var r = randomLetters[i];
				var o = letters[Std.random(26)];
				r.setPos(o.x, o.y);
				r.setSize(o.width, o.height);
			}
			return false;
		}
		event.waitUntil(switchLetters);

		var wait = 1.;
		event.waitUntil(function(dt) {
			wait -= dt / 60;
			if( wait < 0 ) {
				playEnv(0.1 + Math.random() * 0.2);
				wait += 1 + hxd.Math.random(2);
			}
			return false;
		});

		var l = new h2d.Bitmap(hxd.Res.logo.toTile(), s2d);
		l.x = (s2d.width - l.tile.width) >> 1;
		l.y = (s2d.height - l.tile.height) >> 1;
		l.alpha = 0.25;


		buttons = new h2d.Sprite(s2d);

		var green = new h2d.Bitmap(hxd.Res.buttonGreen.toTile(), buttons);
		green.x = 30;
		green.y = 350;
		var tf = newText("", green);
		tf.textColor = 0x38d930;
		tf.x = 52;
		tf.y = 10;
		greenText = tf;

		var red = new h2d.Bitmap(hxd.Res.buttonRed.toTile(), buttons);
		red.x = 400;
		red.y = 350;
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
			hxd.Res.sfx.over.play(false,0.5);
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
			hxd.Res.sfx.over.play(false,0.5);
		};
		rint.onOut = function(_) {
			red.color.set(1., 1., 1.);
		};
		rint.onClick = function(_) {
			askCallback(false);
		};

		buttons.visible = false;

		script = new Script("");
		script.load(hxd.Res.scenario.entry.getText());


		start();
	}

	override function update(dt:Float) {
		event.update(dt);
	}

	public function talk( text : String, onEnd : Void -> Void ) {

		var alpha = 0.6;
		while( log.length > 10 )
			log.pop().remove();
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

		text = format(text);

		var tf = newText(text, s2d);
		tf.x = Std.int((s2d.width - tf.textWidth) * 0.5);
		tf.text = "";
		tf.y = 150;
		log.unshift(tf);
		var pos = 0.;
		var last = 0;
		var rand = text.length == 0 ? 1 : 0;
		event.waitUntil(function(dt) {
			pos += dt * (test ? 2 : 0.5);
			var ipos = Std.int(pos);
			if( ipos != last ) {
				var char = text.charCodeAt(last);
				if( (++rand) & 1 == 1 ) {
					if( char == " ".code )
						rand = 0;
					else
						hxd.Res.load("sfx/keyb" + (1 + Std.random(5)) + ".mp3").toSound().play();
				}
				// skip HTML
				if( char == '<'.code ) {
					while( text.charCodeAt(ipos) != '>'.code )
						ipos++;
					ipos++;
					pos = ipos;
					last = ipos - 1;
				}
				last++;
				tf.text = text.substr(0, last);
				if( last >= text.length ) {
					onEnd();
					return true;
				}
			}
			return false;
		});
	}

	public function format( text : String ) {
		var prevs = [];
		function urand() {
			var x;
			do {
				x = Std.random(26);
			} while( prevs.indexOf(x) >= 0 );
			prevs.push(x);
			if( prevs.length > 20 ) prevs.shift();
			return x;
		}
		text = ~/\$\{([^}]+)\}/g.map(text, function(r) return [for( l in r.matched(1).split("") ) '<img src="letter${urand()}"/>'].join(""));
		text = text.split(" !").join("!").split(" ?").join("?");
		return text;
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
		function setText( tf : h2d.Text, txt : String ) {
			tf.text = format(txt);
			tf.filter = true;
			var s = 110 / tf.textWidth;
			if( s > 1 ) s = 1;
			tf.setScale(s);
		}
		setText(greenText, yes);
		setText(redText, no);
		askCallback = function(b) {
			hxd.Res.sfx.button.play();
			askCallback = function(b) { };
			event.waitUntil(function(dt) {
				buttons.alpha -= 0.2 * dt;
				if( buttons.alpha < 0 ) {
					buttons.visible = false;
					event.wait(test ? 0.1 : 0.5, function() onChoice(b));
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