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
			
			var glyphStyleHasField = Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			var glyphStyleHasMeta = Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			
			var rangeMappingType:ComplexType;
			var rangeType:ComplexType;
			var textureType:ComplexType;
			
			if (glyphStyleHasMeta.gl3Font)
			{
				textureType = macro: peote.view.utils.TextureCache;
				if (glyphStyleHasMeta.multiTexture) {
					if (glyphStyleHasMeta.multiRange) {
						rangeType = macro:{unit:Int, slot:Int, fontData:peote.text.Gl3FontData};
						rangeMappingType = macro:haxe.ds.Vector<$rangeType>;
					}
					else {
						Context.error("@multiTexture is only useful for using @multiRange also", Context.currentPos());
					}
				}
				else {
					textureType = macro: peote.view.Texture;
					if (glyphStyleHasMeta.multiRange) {
						rangeType = macro: {slot:Int, fontData:peote.text.Gl3FontData};
						rangeMappingType = macro:haxe.ds.Vector<$rangeType>;
					}
					else {
						rangeType = macro: peote.text.Gl3FontData;
						rangeMappingType = macro:peote.text.Gl3FontData;
					}
				}
			}
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			var c = macro		
			
			class $className 
			{
				var path:String;

				// TODO: generate after
				//var rangeMapping:haxe.ds.Vector<{unit:Int, slot:Int, fontData:peote.text.Gl3FontData}>;				
				var rangeMapping:$rangeMappingType;				
				public var textureCache:$textureType;

				var maxTextureSize:Int;
				
				// from json
				var ranges:Array<peote.text.Range>;
				var imageNames = new Array<String>();
				var rangeSize = 0x1000;      // amount of unicode range-splitting
				var textureSlotSize = 2048;  // size of textureslot per image in pixels (must match overall image-sizes)
				
				public var kerning = false;
				
				public var width:Float = 20;
				public var height:Float = 20;
				public var color:peote.view.Color = peote.view.Color.GREEN;
				
				var rParseFolder = new EReg("/*$", "gm");
				
				public function new(fontPath:String, ranges:Array<peote.text.Range>=null, kerning:Bool=true, maxTextureSize:Int=16384) 
				{
					path = rParseFolder.replace(fontPath, '');
					this.ranges = ranges;
					this.kerning = kerning;
					this.maxTextureSize = maxTextureSize;
				}

				public inline function getRange(charcode:Int):$rangeType
				{
					${switch (glyphStyleHasMeta.multiRange) {
						case true: macro return rangeMapping.get(Std.int(charcode/rangeSize));
						default: macro return rangeMapping;
					}}
				}

				// --------------------------- Loading -------------------------

				public function load(?onProgressOverall:Int->Int->Void, onLoad:Void->Void)
				{
					utils.Loader.json(path+"/config.json", true, function(json:haxe.Json) {
						
						var rangeSize = Std.parseInt(Reflect.field(json, "rangeSize"));
						if (rangeSize != null) this.rangeSize = rangeSize;
						
						var type = Reflect.field(json, "type");
						if (type != null)
						${switch (glyphStyleHasMeta.gl3Font) {
							case true: macro {
								if (type != "gl3") throw('Error, type of font "' + path + '/config.json" has to be "gl3"');
							}
							case false: macro {
								if (type == "gl3") throw('Error, metadata of $styleName class has to be "@gl3Font" for font "' + path + '/config.json" type "gl3"');
							}
						}}
						
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
						var found_ranges = new Array<peote.text.Range>();
						
						${switch (glyphStyleHasMeta.multiRange) {
							case true: macro {}
							default: macro {
								if (ranges == null && Reflect.fields(_ranges).length > 1) {
									throw('Error, set GlyphStyle to @multiRange or define a single range inside "new font()" or config.json');
								}
							}
						}}
						
						for( fn in Reflect.fields(_ranges) )
						{
							var ra:Array<String> = Reflect.field(_ranges, fn);
							var min = Std.parseInt(ra[0]);
							var max = Std.parseInt(ra[1]);
							
							if (ranges != null) {
								for (r in ranges) {
									if ((r.min >= min && r.min <= max) || (r.max >= min && r.max <= max)) {
										found_ranges.push(new peote.text.Range(min, max));
										imageNames.push(fn);
										break;
									}
								}
							}
							else {
								found_ranges.push(new peote.text.Range(min, max));
								imageNames.push(fn);
							}
							${switch (glyphStyleHasMeta.multiRange) {
								case true: macro {}
								default: macro if (found_ranges.length == 1) break;
							}}
						}
						if (found_ranges.length == 0) {
							if (ranges != null) {
								throw('Error, can not found any ranges inside font-config "'+path+'/config.json" that fit '+ranges);
							} else throw('Error, can not found any ranges inside font-config "'+path+'/config.json"');
						}
						else ranges = found_ranges;

						init(onProgressOverall, onLoad);
					});		
				}
				
				private function init(onProgressOverall:Int->Int->Void, onLoad:Void->Void)
				{
					${switch (glyphStyleHasMeta.multiRange) {
						case true: macro
							rangeMapping = new haxe.ds.Vector<$rangeType>(Std.int(0x1000 * 20 / rangeSize));// TODO: is ( 0x1000 * 20) the greatest charcode for unicode ?
						default: macro {}
					}}
					
					${switch (glyphStyleHasMeta.multiTexture && glyphStyleHasMeta.multiRange) {
						case true: macro {
							textureCache = new peote.view.utils.TextureCache(
								[{width:textureSlotSize, height:textureSlotSize, slots:ranges.length}],
								4, // colors -> TODO
								false, // mipmaps
								1,1, // min/mag-filter
								maxTextureSize
							);
						}
						default: macro {
							textureCache = new peote.view.Texture(textureSlotSize, textureSlotSize, ranges.length, 4, false, 1, 1, maxTextureSize);
						}
					}}
				
					loadFontData(onProgressOverall, onLoad);	
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
							
							${switch (glyphStyleHasMeta.multiTexture) {
								case true: macro {
									var p = textureCache.addImage(image); trace( image.width+"x"+image.height, "texture-unit:" + p.unit, "texture-slot" + p.slot);							
									for (i in Std.int(range.min / rangeSize)...Std.int(range.max / rangeSize)+1) {
										rangeMapping.set(i, {unit:p.unit, slot:p.slot, fontData:gl3font});
									}
								}
								default: switch (glyphStyleHasMeta.multiRange) {
									case true: macro {
										textureCache.setImage(image, index);
										for (i in Std.int(range.min / rangeSize)...Std.int(range.max / rangeSize)+1) {
											rangeMapping.set(i, {slot:index, fontData:gl3font});
										}
									}
									default: macro {
										textureCache.setImage(image);
										rangeMapping = gl3font;
									}
								}
							}}
							
							
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
			
/*			if (glyphStyleHasMeta.gl3Font)
			{
				
				
				// ------ TODO: generate 
				if (glyphStyleHasMeta.multiTexture) {
					if (glyphStyleHasMeta.multiRange) {
						
					}
					else {
					}
				}
				else {
					if (glyphStyleHasMeta.multiRange) {
						
					}
					else {
						
					}
				}
				
			}
*/			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
