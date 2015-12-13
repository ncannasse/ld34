class Interphone extends ImageFinder {

	var nightMode : Bool;
	var videoMask : h2d.Bitmap;
	var videoZoom : h2d.Bitmap;
	var videoOn : Bool;
	var bl : h2d.Bitmap;

	public function new( onEnd ) {
		super(hxd.Res.interphone, 1., 1045, 777, 140, 145, function() onEnd("off"));

		videoZoom = new h2d.Bitmap(hxd.Res.interzoom.toTile(), bmp);
		videoZoom.x = 280 - 13 + 5;
		videoZoom.y = 180 - 10;
		videoZoom.scaleY = 1.1;
		videoZoom.scaleX = 0.95;
		videoZoom.alpha = 0;

		videoMask = new h2d.Bitmap(hxd.Res.interzoom.toTile(), bmp);
		videoMask.x = 280 - 13;
		videoMask.y = 180 - 10;
		videoMask.color.set(0, 0, 0);
		videoMask.scaleY = 1.1;

		bl = new h2d.Bitmap(h2d.Tile.fromColor(0, 13, 25), bmp);
		bl.x = 803;
		bl.y = 608;
		var bt = new h2d.Bitmap(bmp.tile.sub(804, 608, 108 - 13, 30), bl);
		bt.x = 1;
		bt.y = 0;

		// toggle
		addButton(803, 608, 107, 30, function() {
			hxd.Res.sfx.buttonMecanic.play();
			nightMode = !nightMode;
			bt.x = (nightMode ? 13 : 0);
			if( videoOn ) updateVideo();
		});


		// talk
		addButton(811, 765, 228, 145, function() {
			hxd.Res.sfx.button.play();
			videoOn = !videoOn;
			updateVideo();
		});

		// zoom
		addButton(946, 566, 129, 123, function() {
			if( !videoOn ) return;
			hxd.Res.sfx.button.play();


			videoZoom.alpha = 1 - videoZoom.alpha;

		}).isEllipse = true;

		// key
		addButton(307, 756, 145, 140, function() {
			hxd.Res.sfx.annoying.play();
			exit(function() onEnd("key"));
		});

		// option
		addButton(447, 761, 145, 140, function() {
			hxd.Res.sfx.over.play();
		});

		// guard
		addButton(588, 761, 145, 140, function() {
			hxd.Res.sfx.alarm.play();
		});

	}

	function updateVideo() {
		videoMask.colorAdd = new h3d.Vector(0.5, 0.5, 0.5, 0);
		if( videoOn ) {
			if( !nightMode )
				videoMask.colorAdd = null;
			game.event.waitUntil(function(dt) {
				videoMask.alpha -= 0.05 * dt;
				var min = nightMode ? 0 : 0.9;
				if( videoMask.alpha < min ) {
					videoMask.alpha = min;
					return true;
				}
				return false;
			});
		} else {
			videoZoom.alpha = 0;
			videoMask.alpha = 1;
			game.event.waitUntil(function(dt) {
				if( videoMask.colorAdd == null )
					return true;
				videoMask.colorAdd.x = videoMask.colorAdd.y = videoMask.colorAdd.z -= 0.05 * dt;
				if( videoMask.colorAdd.x < 0 ) {
					videoMask.colorAdd = null;
					return true;
				}
				return false;
			});
		}
	}

}