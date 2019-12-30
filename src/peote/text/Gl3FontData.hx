package peote.text;


/**
 * by semmi
 */

// thanks to deltalucas gl3font lib -> https://github.com/deltaluca/gl3font

import haxe.ds.Vector;
import lime.utils.Bytes;

class Gl3FontData 
{
	public var rangeMin:Int;
	public var rangeMax:Int;
	
    public var metrics:Vector<Metric>;
    public var kerning:Array<Array<Float>>;

    public var height:Float;
    public var ascender:Float;
    public var descender:Float;

    public function new(bytes:Bytes, rangeMin:Int, rangeMax:Int, isKerning:Bool = true)
	{
		this.rangeMin = rangeMin;
		this.rangeMax = rangeMax;
	
		metrics = new Vector<Metric>(rangeMax-rangeMin+1);

		var pos:Int = 0;
		var N:Int = bytes.getInt32(pos); pos += 4; trace('number of glyphes: $N');
		height    = bytes.getFloat(pos); pos += 4; trace('height: $height');
		ascender  = bytes.getFloat(pos); pos += 4; trace('ascender: $ascender');
		descender = bytes.getFloat(pos); pos += 4; trace('descender: $descender');
		
		for (i in 0...N) {
			var charcode = bytes.getInt32(pos); pos += 4;
			var m:Metric = {
				kerning : i,
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
			setMetric(charcode, m); if (charcode > 65000) trace(charcode);
		}
		
		if (isKerning)
		{
			var y = 0; var x = 0;
			var kern = []; kerning = [kern];				
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
	
	public inline function getMetric(charcode:Int):Metric
	{
		return metrics.get(charcode-rangeMin);
	}
	
	public inline function setMetric(charcode:Int, metric:Metric):Void
	{
		metrics.set(charcode-rangeMin, metric);
	}
	
}

typedef Metric = {
	kerning:Int,
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
