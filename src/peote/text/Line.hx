package peote.text;

#if !macro
@:genericBuild(peote.text.Line.LineMacro.build())
class Line<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class LineMacro
{
	public static var cache = new Map<String, Bool>();
	
	static public function build()
	{	
		switch (Context.getLocalType()) {
			case TInst(_, [t]):
				switch (t) {
					case TInst(n, []):
						var style = n.get();
						var styleSuperName:String = null;
						var styleSuperModule:String = null;
						var s = style;
						while (s.superClass != null) {
							s = s.superClass.t.get(); trace("->" + s.name);
							styleSuperName = s.name;
							styleSuperModule = s.module;
						}
						return buildClass(
							"Line", style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(t)
						);	
					default: Context.error("Type for GlyphStyle expected", Context.currentPos());
				}
			default: Context.error("Type for GlyphStyle expected", Context.currentPos());
		}
		return null;
	}
		
	static public function buildClass(className:String, stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType):ComplexType
	{		
		var styleMod = styleModule.split(".").join("_");
		
		className += "__" + styleMod;
		if (styleModule.split(".").pop() != styleName) className += ((styleMod != "") ? "_" : "") + styleName;
		
		var classPackage = Context.getLocalClass().get().pack;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var styleField:Array<String>;
			//if (styleSuperName == null) styleField = styleModule.split(".").concat([styleName]);
			//else styleField = styleSuperModule.split(".").concat([styleSuperName]);
			styleField = styleModule.split(".").concat([styleName]);
			
			var glyphType = Glyph.GlyphMacro.buildClass("Glyph", stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			
			#if peoteview_debug_macro
			trace('generating Class: '+classPackage.concat([className]).join('.'));	
			
			trace("ClassName:"+className);           // FontProgram__peote_text_GlypStyle
			trace("classPackage:" + classPackage);   // [peote,text]	
			
			trace("StylePackage:" + stylePack);  // [peote.text]
			trace("StyleModule:" + styleModule); // peote.text.GlyphStyle
			trace("StyleName:" + styleName);     // GlyphStyle			
			trace("StyleType:" + styleType);     // TPath(...)
			trace("StyleField:" + styleField);   // [peote,text,GlyphStyle,GlyphStyle]
			#end
			
			var glyphStyleHasMeta = Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			var glyphStyleHasField = Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			
			// -------------------------------------------------------------------------------------------
			var c = macro		

			class $className
			{

				public var x:Int = 0;
				public var y:Int = 0;
				
				public var length:Int = 0; // number of glyphes
				public var xDirection:Int = 1;
				public var yDirection:Int = 0;
				
				// TODO: optimize here for js/neko
				public var glyphes:Array<$glyphType>;
				
				public function new() 
				{
					
				}
				
				public function setStyle(glyphStyle:$styleType , from:Int=0, to:Int=0) {
					
				}
						

			/*	public function renderTextLine(x:Float, y:Float, scale:Float, gl3font:Gl3FontData, imgWidth:Int, imgHeight:Int, isKerning:Bool, text:String)
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
								
								buffer.addElement(element);     // element to buffer
							}
						});
					} catch (e:Dynamic) trace("ERR", e); // <-- problem with utf8 and neko breaks haxe.Utf8.iter()
				}
			*/	
				
			}
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
