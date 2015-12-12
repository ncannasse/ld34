class BlueScreen extends h2d.Bitmap {

	public function new( onEnd ) {
		var game = Game.inst;
		super(h2d.Tile.fromColor(0x0000AA, game.s2d.width, game.s2d.height));
		var tf = new h2d.Text(hxd.Res._8bit.toFont(), this);
		var text = StringTools.trim("
			(C)2015 Nicolas Cannasse
			Registred Trademark of Ludum Dare

			Available Memory: 512MB

			USB Hotplugging
			Configuring Network interfaces
			Random number generator
			System Logger
			Kernel Logger
			Cron Daemon

			Boot complete
		");
		var text = [for( l in text.split("\n") ) StringTools.trim(l)].join("\n");
		tf.x = tf.y = 2;
		tf.text = "";
		var pos = 0.;
		var b = new h2d.filter.Bloom(1, 5);
		this.filters = [b];
		game.event.waitUntil(function(dt) {
			pos += dt * 3;
			tf.text = text.substr(0, Std.int(pos));
			if( pos >= text.length ) {
				this.colorAdd = new h3d.Vector();
				game.event.waitUntil(function(dt) {
					this.colorAdd.r += dt * 0.002;
					this.colorAdd.g += dt * 0.002;
					b.amount += dt;
					if( b.amount > 50 ) {
						remove();
						onEnd();
						return true;
					}
					return false;
				});
				return true;
			}
			return false;
		});
		game.s2d.add(this, 1);
	}

}