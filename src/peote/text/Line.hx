package peote.text;

/**
 * ...
 * @author 
 */
class Line 
{

	public function new() 
	{
		
	}

	public function renderTextLine(x:Float, y:Float, scale:Float, gl3font:Gl3FontData, imgWidth:Int, imgHeight:Int, isKerning:Bool, text:String)
	{
		var penX:Float = x;
		var penY:Float = y;
		
		var prev_id:Int = -1;
		
		try{
			haxe.Utf8.iter(text, function(charcode)
			{
				//trace("charcode", charcode);
				var id:Null<Int> = gl3font.idmap.get(charcode);
				
				if (id != null)
				{
					#if isInt
					if (isKerning && prev_id != -1) { // KERNING
						penX += Math.ceil(gl3font.kerning[prev_id][id] * scale);
						//trace("kerning to left letter: " + Math.round(gl3font.kerning[prev_id][id]* scale) );
					}
					prev_id = id;
					
					//trace(charcode, "h:"+gl3font.metrics[id].height, "t:"+gl3font.metrics[id].top );
					element  = new Elem(
						Math.floor((penX + gl3font.metrics[id].left * scale )),
						Math.floor((penY + ( gl3font.height - gl3font.metrics[id].top ) * scale ))
					);
					
					penX += Math.ceil(gl3font.metrics[id].advance * scale);

					element.w  = Math.ceil( gl3font.metrics[id].width  * scale );
					element.h  = Math.ceil( gl3font.metrics[id].height * scale );
					element.tx = Math.floor(gl3font.metrics[id].u * imgWidth );
					element.ty = Math.floor(gl3font.metrics[id].v * imgHeight);
					element.tw = Math.floor(1+gl3font.metrics[id].w * imgWidth );
					element.th = Math.floor(1+gl3font.metrics[id].h * imgHeight);
					#else
					if (isKerning && prev_id != -1) { // KERNING
						penX += gl3font.kerning[prev_id][id] * scale;
						//trace("kerning to left letter: " + Math.round(gl3font.kerning[prev_id][id]* scale) );
					}
					prev_id = id;
					
					//trace(charcode, "h:"+gl3font.metrics[id].height, "t:"+gl3font.metrics[id].top );
					element  = new Elem(
						penX + gl3font.metrics[id].left * scale,
						penY + ( gl3font.height - gl3font.metrics[id].top ) * scale
					);
					
					penX += gl3font.metrics[id].advance * scale;

					element.w  = gl3font.metrics[id].width  * scale;
					element.h  = gl3font.metrics[id].height * scale;
					element.tx = gl3font.metrics[id].u * imgWidth;
					element.ty = gl3font.metrics[id].v * imgHeight;
					element.tw = gl3font.metrics[id].w * imgWidth;
					element.th = gl3font.metrics[id].h * imgHeight;
					#end
					buffer.addElement(element);     // element to buffer
				}
			});
		} catch (e:Dynamic) trace("ERR", e); // <-- problem with utf8 and neko breaks haxe.Utf8.iter()
	}
	
	
}