
@:keep
class ScriptGlobals {

	var game : Game;
	var script : Script;

	public function new( script ) {
		this.script = script;
		this.game = Game.inst;
	}

	function a_wait( onEnd : Dynamic -> Void, ?time = 1.) {
		game.event.wait(time, function() onEnd(null));
	}

	function a_talk( onEnd : Dynamic -> Void, text : String, ?options ) {
		var lines = [for( l in StringTools.trim(text).split("\n") ) StringTools.trim(l)];
		function next() {
			var l = lines.shift();
			if( l == null ) {
				onEnd(null);
				return;
			}
			game.talk(l, function() {
				if( lines.length >= 0 )
					game.event.wait(game.test ? 0.2 : 0.6, next);
				else
					next();
			},options);
		}
		next();
	}

	function a_ask( onEnd : Dynamic -> Void, ?yes : String, ?no : String ) {
		if( yes == null ) yes = "Yes";
		if( no == null ) no = "No";
		game.ask(yes, no, function(b) onEnd(b));
	}

	function a_reboot( onEnd : Dynamic -> Void ) {
		game.reboot(function() onEnd(null));
	}

	function a_findImage( onEnd : Dynamic -> Void, name, s : Float, x, y, w, h ) {
		game.clearText(function() {
			new ImageFinder(hxd.Res.load(name+".jpg").toImage(), s, x, y, w, h, function() onEnd(null));
		});
	}

	function a_inputCode( onEnd : Dynamic -> Void ) {
		game.clearText(function() {
			new Digicode(onEnd);
		});
	}

	public function initVariables( variables : Map<String,Dynamic> ) {
		variables.set("global", this);
	}

	function a_interPhone( onEnd : Dynamic -> Void ) {
		new Interphone(onEnd);
	}

	function a_xbox( onEnd : Dynamic -> Void ) {
//		new XBox(onEnd);
	}

	function sfx( name, ?vol = 1. ) {
		var r = try
			hxd.Res.load("sfx/" + name+".mp3")
		catch( e : hxd.res.NotFound )
			hxd.Res.load("sfx/" + name+".wav");
		r.toSound().play(false, vol);
	}

	function a_clearText(onEnd) {
		game.clearText(function() onEnd(null));
	}

}