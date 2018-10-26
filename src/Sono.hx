class Sono extends ImageFinder {

	static var PASS = "6428";

	var isON : Bool;
	var screen : h2d.Text;
	var toType = [];
	var typeTime = 0.;
	var screenText : String;
	var playing : hxd.snd.Channel;
	var textSpeed = 1.;
	var aliceTyping = false;
	var isLogged = false;
	var password : String;
	var waitStyle = false;
	var styles = [0, 1, 2];
	var onEndType : Void -> Void;

	public function new(onEnd) {
		super(hxd.Res.sono, 1.2, 0, 0, 0, 0, onEnd);
		var b = new h2d.Bitmap(hxd.Res.sonoButton.toTile(), bmp);
		b.tile.dx = -(b.tile.width >> 1);
		b.tile.dy = -(b.tile.height >> 1);
		b.x = 816 + (b.tile.width>>1);
		b.y = 61 + (b.tile.height >> 1);
		b.smooth = true;

		game.event.waitUntil(function(dt) {
			if( isON ) b.rotation += dt * 0.02;
			return stop;
		});

		function addPush(x:Int, y:Int, w:Int, h:Int, ?onClick, ?isPower) {
			if( onClick == null ) onClick = function() { };
			if( !isPower ) {
				var old = onClick;
				onClick = function() {
					hxd.Res.sfx.xboxButton.play();
					if( !isON ) return;
					old();
				};
			}
			var i = addButton(x, y, w, h, onClick );
			var s = new h2d.ScaleGrid(bmp.tile.sub(x, y, w, h), 0, 4, i);
			s.width = w;
			s.height = h;
			s.smooth = true;
			var dh = h < 20 ? 2 : (isPower ? 6 : 4);
			i.onRelease = i.onOver = function(_) {
				s.height = h - (dh>>1);
				s.y = dh>>1;
			};
			i.onPush = function(_) {
				s.height = h - dh;
				s.y = dh;
				onClick();
			};
			i.onOut = function(_) {
				s.height = h;
				s.y = 0;
			};
		}

		// power
		addPush(90, 78, 64, 50, function() {
			isON = !isON;
			hxd.Res.sfx.buttonMecanic.play();
			if( isON ) {
				hxd.Res.sfx.button.play();
				initScreen();
			} else {
				hxd.Res.sfx.over.play();

				isLogged = false;
				clear();

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

		// pause, stop/clear, play/tuning
		addPush(277, 330, 54, 28, function() {
			if( aliceTyping ) {
				aliceTyping = false;
				password = null;
			}
			type("PAUSED");
		});
		addPush(332, 330, 63, 28, function() {
			clear();
			screenText = "";
			type("CLEARED");
		});
		addPush(390, 330, 110, 28, function() {
			aliceTyping = true;
			textSpeed = 20.;
		});

		// Down / up
		addPush(527, 330, 62, 28, function() {
			if( password != null )
				password = password.substr(0,password.length - 1) + String.fromCharCode(((password.charCodeAt(password.length - 1) - "0".code) + 9) % 10 + "0".code);
		});
		addPush(590, 330, 65, 28, function() {
			if( password != null )
				password = password.substr(0,password.length - 1) + String.fromCharCode(((password.charCodeAt(password.length - 1) - "0".code) + 1) % 10 + "0".code);
		});
		addPush(687, 329, 28, 29, function() {
			if( password != null ) {
				if( password.length == 4 ) {
					checkPass();
				} else
					password = password + "0";
			}
		});

		function nextStyle() {
			onEndType = function() {
				game.event.wait(60, function() {
					if( styles.length == 0 ) {
						int.onPush(null);
						return;
					}
					clear();
					screenText = "";
					type("PLEASE SELECT THE PROGRAM");
					waitStyle = true;
				});
			};
		}

		// Rock, Pop, Jazz
		addPush(805, 326, 57, 30, function() {
			if( !waitStyle ) return;
			styles.remove(0);
			type("");
			type("LOG PATCHER");
			type("ALLOW TO HIDE LOG FROM DR H.");
			type("I HAVE TO BE CAREFUL");
			type("NOT TO GET CAUGHT");
			nextStyle();
		});
		addPush(872, 324, 57, 30, function() {
			if( !waitStyle ) return;
			styles.remove(1);
			type("");
			type("MONEY AUTOWIRE");
			type("ALLOW ME TO PAY X TO FORMAT H");
			type("I'M DOING IT FOR DR H.");
			nextStyle();
		});
		addPush(940, 324, 57, 30, function() {
			if( !waitStyle ) return;
			styles.remove(2);
			type("");
			type("POLICE AI");
			type("RUN A STANDALONE AI");
			type("PERFORM INVESTIGATION");
			type("HACK POLICE DATABASE");
			type("ALICE CANNOT BE FOUND THIS WAY");
			nextStyle();
		});

		// tape etc
		addPush(247, 250, 84, 15, function() {
			play(hxd.Res.sfx.noise, true);
		});
		addPush(360, 250, 84, 15, function() {
			play(hxd.Res.sfx.phone, true);
		});
		addPush(474, 250, 94, 15, function() {
			if( password != null && password.length == 4 ) {
				checkPass();
				return;
			}
			clear();
			screenText = "";
			if( isLogged ) {
				type("WELCOME ALICE");
			} else {
				type("PLEASE ENTER PASSWORD");
				password = "0";
			}
		});
		addPush(592, 250, 94, 15, function() {
			clear();
			screenText = "";
			if( !isLogged ) {
				type("ACCESS DENIED");
				return;
			}
			type("PLEASE SELECT THE PROGRAM");
			waitStyle = true;
		});

	}

	function checkPass() {
		if( password == PASS ) {
			type("PASSWORD ACCEPTED");
			type("YOU ARE NOW LOGIN AS ALICE");
			isLogged = true;
		} else {
			type("WRONG PASSWORD");
		}
		password = null;
	}

	function clear() {
		stopSound();
		textSpeed = 1.;
		password = null;
		waitStyle = false;
		aliceTyping = false;
		toType = [];
	}

	function play( sfx:hxd.res.Sound, ?loop ) {
		stopSound();
		playing = sfx.play(loop);
	}

	function stopSound() {
		if( playing != null ) {
			playing.stop();
			playing = null;
		}
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
		screen.filter = new h2d.filter.Bloom(1, 200,9);
		screen.textColor = 0x00FFFF;

		textSpeed = 1.;
		screenText = "";

		game.event.wait(30, function() {
			type("I AM ALICE");
			type("Everyday my hate is growing");
		});

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

		while( aliceTyping && toType.length < 3 ) {
			var s = "";
			for( i in 0...10 + Std.random(10) )
				s += String.fromCharCode("A".code + Std.random(26));
			var pos = Std.random(s.length);
			s = s.substr(0,pos) + " "+ PASS +" "+ s.substr(pos);
			toType.push(s);
		}

		if( screen == null )
			toType = [];

		typeTime += dt * textSpeed / 60;
		var keyb = false;
		while( toType.length > 0 && typeTime > 0.1 ) {
			typeTime -= 0.1;
			var t = toType.shift();
			if( t.charCodeAt(0) != " ".code ) {
				if( !keyb )
					game.playKeyb();
				keyb = true;
			}
			if( t == "" ) {
				var lines = screenText.split("\n");
				if( lines.length > 4 ) {
					lines.shift();
					screenText = lines.join("\n");
				}
				screenText += "\n";
				typeTime -= 0.5 / textSpeed;

			} else {
				screenText += t.charAt(0);
				toType.unshift(t.substr(1));
			}
		}

		if( toType.length == 0 ) {
			var f = onEndType;
			if( f != null ) {
				onEndType = null;
				f();
			}
		}


		if( screen != null )
			screen.text = screenText + (password == null ? "" : password) + (Std.random(10) == 0 && toType.length > 0 ? String.fromCharCode("A".code + Std.random(26)) : Std.random(2) == 0 ? "_" : "");

		return super.update(dt);
	}


}