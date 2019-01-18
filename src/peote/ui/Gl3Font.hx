package peote.ui;

/**
 * by semmi
 */

// thanks to deltalucas gl3font lib -> https://github.com/deltaluca/gl3font

class Gl3Font 
{
    public var idmap:Map<Int,Int>; // map glyph to id

    public var metrics:Array<Metric>;
    public var kerning:Array<Array<Float>>;

    public var height:Float;
    public var ascender:Float;
    public var descender:Float;

    public function new(bytes:haxe.io.Bytes, isKerning:Bool = true) {
			
			var pos:Int = 0;
			var N:Int = bytes.getInt32(pos); pos += 4; trace('number of glyphes: $N');
			height    = bytes.getFloat(pos); pos += 4; trace('height: $height');
			ascender  = bytes.getFloat(pos); pos += 4; trace('ascender: $ascender');
			descender = bytes.getFloat(pos); pos += 4; trace('descender: $descender');
			idmap = new Map<Int,Int>();
			metrics = [for (i in 0...N) {
				var charcode = bytes.getInt32(pos);
				idmap.set(charcode, i); pos += 4;
				var m:Metric = {
					advance : bytes.getFloat(pos),
					left    : bytes.getFloat(pos+4),
					top     : bytes.getFloat(pos+8),
					width   : bytes.getFloat(pos+12),
					height  : bytes.getFloat(pos+16),
					u       : bytes.getFloat(pos+20),
					v       : bytes.getFloat(pos+24),
					w       : bytes.getFloat(pos+28),
					h       : bytes.getFloat(pos+32)
				};
				pos += 36;
				m;
			}];
			var y = 0; var x = 0;
			var kern = []; kerning = [kern];
			if (isKerning)
				while (x < N && y < N) {
					var k = bytes.getFloat(pos); pos += 4;
					var amount:Int = bytes.getInt32(pos); pos += 4;
					//trace("kerning:" + k + " amount:"+amount);
					for (i in 0...amount) {
						kern[x++] = k;
						if (x == N) {
							x = 0;
							kerning.push(kern = []);
							y++;
						}
					}
				}
	}
}

typedef Metric = {
    advance:Float,
    left:Float,
    top:Float,
    width:Float,
    height:Float,
    u:Float,
    v:Float,
    w:Float,
    h:Float
}