class TransformShader extends hxsl.Shader {


	static var SRC = {
		@:import h3d.shader.Base2d;

		@param var matrix : Mat4;

		@param var fov : Float;
		@param var camPosX : Float;
		@param var camPosY : Float;
		@param var camPosZ : Float;
		@param var xScale : Float;
		@param var yScale : Float;
		@param var recalX : Float;
		@param var recalY : Float;

		function vertex() {
			var transp = vec4(spritePosition.xy, (spritePosition.x * xScale + spritePosition.y * yScale) / 1000, 1.) * matrix;
			spritePosition.xy = transp.xy * vec2( -1, 1) / transp.w;
			spritePosition.xy += vec2(recalX, recalY) * spritePosition.yx;
		}

	}

	public function new() {
		super();
		fov = 58.32;
		xScale = 0.2888;
		yScale = 0.845;
		camPosX = -10.46;
		camPosY = -11.85;
		camPosZ = 16.42;
		recalY = -0.568;
	}

}


class Note extends ImageFinder {

	var t : TransformShader;


	public function new( onEnd, text:String ) {
		super(hxd.Res.note, 1., 546, 461, 33, 320, onEnd);

		var blood = text.indexOf("!!!") > 0;
		if( blood ) {
			var b = new h2d.Bitmap(hxd.Res.noteBlood.toTile(), bmp);
			b.x = 333;
			b.y = 329;
		}

		int.rotation = 0.15;
		var tf = new h2d.Text(hxd.Res._8bit.toFont(), bmp);
		tf.textColor = 0x101030;
		tf.maxWidth = 200;
		tf.text = text;
		tf.scale(2.2);
		tf.x = 280;
		tf.y = 340;
		tf.filter  = true;
		tf.alpha = 0.8;
		t = new TransformShader();
		tf.addShader(t);
	}

	override function update(dt:Float) 	{
		var cam = new h3d.Camera(t.fov);
		cam.pos.set(t.camPosX,t.camPosY,t.camPosZ);
		cam.target.set(0, 0, 0);
		cam.zNear = 1;
		cam.zFar = 100;
		cam.update();
		t.matrix = cam.getInverseViewProj();
		return super.update(dt);
	}

}