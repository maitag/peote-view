package peote.text;

#if !macro
@:genericBuild(peote.text.Font.FontMacro.build())
class Font<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class FontMacro
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
							"Font", style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(t)
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
			
			var glyphType = peote.text.Glyph.GlyphMacro.buildClass("Glyph", stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			
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
			
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			var c = macro		
			
			class $className 
			{
				var path:String;

				var rangeMapping:haxe.ds.Vector<{unit:Int, slot:Int, fontData:peote.text.Gl3FontData}>;
				public var textureCache:peote.view.utils.TextureCache;
				var maxTextureSize:Int;
				
				// from json
				var ranges = new Array<{min:Int, max:Int}>();
				var imageNames = new Array<String>();
				var rangeSize = 0x1000;      // amount of unicode range-splitting
				var textureSlotSize = 2048;   // size of textureslot per image in pixels (must match overall image-sizes)
				
				var kerning = false;
				
				public var width:Float = 20;
				public var height:Float = 20;
				public var color:peote.view.Color = peote.view.Color.GREEN;
				
				var rParseFolder = new EReg("/*$", "gm");
				
				public function new(fontPath:String, kerning:Bool=true, maxTextureSize:Int=16384) 
				{
					path = rParseFolder.replace(fontPath, '');
					this.kerning = kerning;
					this.maxTextureSize = maxTextureSize;
				}

				public inline function getRange(charcode:Int):{unit:Int, slot:Int, fontData:peote.text.Gl3FontData}
				{
					return rangeMapping.get(Std.int(charcode/rangeSize));
				}

				// --------------------------- Loading -------------------------

				public function load(?onProgressOverall:Int->Int->Void, onLoad:Void->Void)
				{
					utils.Loader.json(path+"/config.json", true, function(json:haxe.Json) {
						
						var rangeSize = Std.parseInt(Reflect.field(json, "rangeSize"));
						if (rangeSize != null) this.rangeSize = rangeSize;
						
						var type = Reflect.field(json, "type");
						if (type != null) if (type != "gl3") throw('Error, type of font "'+path+'/config.json" has to be "gl3"');
						
						var textureSlotSize = Std.parseInt(Reflect.field(json, "textureSlotSize"));
						if (textureSlotSize != null) this.textureSlotSize = textureSlotSize;
						
						if (kerning) {
							var k:Null<Bool> = Reflect.field(json, "kerning");
							if (k != null) this.kerning = k;
						}
						
						var c = Reflect.field(json, "color"); if (c != null) color = Std.parseInt(c);
						var w = Reflect.field(json, "width"); if (w != null) width = Std.parseInt(w);
						var h = Reflect.field(json, "height"); if (h != null) height = Std.parseInt(h);
						
						var _ranges = Reflect.field(json, "ranges");
						for( fn in Reflect.fields(_ranges) )
						{
							var r:Array<String> = Reflect.field(_ranges, fn);
							ranges.push({min:Std.parseInt(r[0]), max:Std.parseInt(r[1])});
							imageNames.push(fn);
						}
						
						rangeMapping = new haxe.ds.Vector<{unit:Int, slot:Int, fontData:peote.text.Gl3FontData}>(Std.int(0x1000 * 20 / rangeSize));// TODO: is ( 0x1000 * 20) the greatest charcode for unicode ?
						
						textureCache = new peote.view.utils.TextureCache(
							[{width:textureSlotSize, height:textureSlotSize, slots:ranges.length}],
							4, // colors -> TODO
							false, // mipmaps
							1,1, // min/mag-filter
							maxTextureSize
						);
					
						loadFontData(onProgressOverall, onLoad);
					});		
				}
				
				private function loadFontData(onProgressOverall:Int->Int->Void, onLoad:Void->Void):Void
				{		
					var gl3FontData = new Array<peote.text.Gl3FontData>();		
					utils.Loader.bytesArray(
						imageNames.map(function (v) return path+"/"+v+".dat"),
						true,
						function(index:Int, bytes:haxe.io.Bytes) { // after .dat is loaded
							gl3FontData[index] = new peote.text.Gl3FontData(bytes, ranges[index].min, ranges[index].max, kerning);	
						},
						function(bytes:Array<haxe.io.Bytes>) { // after all .dat is loaded
							loadImages(gl3FontData, onProgressOverall, onLoad);
						}
					);
				}
				
				public function embed()
				{
					// TODO
				}
				
				private function loadImages(gl3FontData:Array<peote.text.Gl3FontData>, onProgressOverall:Int->Int->Void, onLoad:Void->Void):Void
				{		
					trace("load images");
					utils.Loader.imageArray(
						imageNames.map(function (v) return path+"/"+v+".png"),
						true,
						function(index:Int, loaded:Int, size:Int) {
							trace(' loading G3Font-Images progress ' + Std.int(loaded / size * 100) + "%" , " ("+loaded+" / "+size+")");
							if (onProgressOverall != null) onProgressOverall(loaded, size);
						},
						function(index:Int, image:peote.view.PeoteGL.Image) { // after every image is loaded
							//trace('File number $index loaded completely.');
							var p = textureCache.addImage(image);
							trace( image.width+"x"+image.height, "texture-unit:" + p.unit, "texture-slot" + p.slot);
							
							// recalc texture-coords
							var gl3font = gl3FontData[index];
							for (charcode in gl3font.rangeMin...gl3font.rangeMax+1) {
								var m = gl3font.getMetric(charcode);
								if (m != null) {
									m.u *= image.width;
									m.v *= image.height;
									m.w *= image.width;
									m.h *= image.height;
									gl3font.setMetric(charcode, m);
								}
							}
							
							// sort ranges into rangeMapping
							var range = ranges[index];
							for (i in Std.int(range.min / rangeSize)...Std.int(range.max / rangeSize)+1) {
								rangeMapping.set(i, {unit:p.unit, slot:p.slot, fontData:gl3font});
							}
							
						},
						function(images:Array<peote.view.PeoteGL.Image>) { // after all images is loaded
							trace(' --- all images loaded ---');
							onLoad();
						}
					);
					
				}
				
				// --------------------------- Embedding -------------------------
			}

			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			var glyphStyleHasField = Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			var glyphStyleHasMeta = Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			
			if (glyphStyleHasMeta.gl3Font)
			{
								
				// ------ TODO: generate 
				
			}
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
