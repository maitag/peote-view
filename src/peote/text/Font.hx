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
			
			if (glyphStyleHasMeta.multiTexture) {
				textureType = macro: peote.view.utils.TextureCache;
				if (glyphStyleHasMeta.multiSlot) {
					if (glyphStyleHasMeta.packed) {
						rangeType = macro: {unit:Int, slot:Int, fontData:peote.text.Gl3FontData};
					}
					else {
						rangeType = macro: {unit:Int, slot:Int, min:Int, max:Int};
					}
				}
				else {
					if (glyphStyleHasMeta.packed) {
						rangeType = macro: {unit:Int, fontData:peote.text.Gl3FontData};
					}
					else {
						rangeType = macro: {unit:Int, min:Int, max:Int};
					}
				}
				rangeMappingType = macro: haxe.ds.Vector<$rangeType>;
			}
			else {
				textureType = macro: peote.view.Texture;
				if (glyphStyleHasMeta.multiSlot) {
					if (glyphStyleHasMeta.packed) {
						rangeType = macro: {slot:Int, fontData:peote.text.Gl3FontData};
					}
					else {
						rangeType = macro: {slot:Int, min:Int, max:Int };
					}
					rangeMappingType = macro: haxe.ds.Vector<$rangeType>;
				}
				else {
					if (glyphStyleHasMeta.packed) {
						rangeType = rangeMappingType = macro: peote.text.Gl3FontData;
					}
					else {
						rangeType = rangeMappingType = macro: {min:Int, max:Int};
					}
				}
			}
			
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			var c = macro		
			
			class $className 
			{
				var path:String;
				var config:String;

				public var fontConfig:peote.text.FontConfig;
				
				var rangeMapping:$rangeMappingType;				
				public var textureCache:$textureType;

				var maxTextureSize:Int;
				
				// from json
				var ranges:Array<peote.text.Range>;
				var rangeSize = 0x1000;      // amount of unicode range-splitting
				
				public var kerning = false;
								
				var rParsePathConfig = new EReg("^(.*?)([^/]+)$", "");
				var rParseEnding = new EReg("\\.[a-z]+$", "i");
				var rComments = new EReg("//.*?$", "gm");
				var rHexToDec = new EReg("(\"\\s*)?(0x[0-9a-f]+)(\\s*\")?", "gi");
				
				public function new(configJsonPath:String, ranges:Array<peote.text.Range>=null, kerning:Bool=true, maxTextureSize:Int=16384) 
				{
					if (rParsePathConfig.match(configJsonPath)) {
						path = rParsePathConfig.matched(1);
						config = rParsePathConfig.matched(2);
					} else throw("Can't load font, error in path to jsonfile: "+'"'+configJsonPath+'"');
					
					this.ranges = ranges;
					this.kerning = kerning;
					this.maxTextureSize = maxTextureSize;
				}

				public inline function getRange(charcode:Int):$rangeType
				{
						${switch (glyphStyleHasMeta.packed) {
							case true:
								switch (glyphStyleHasMeta.multiTexture || glyphStyleHasMeta.multiSlot) {
									case true: macro return rangeMapping.get(Std.int(charcode/rangeSize));
									default: macro return rangeMapping;
								}
							default:
								switch (glyphStyleHasMeta.multiTexture || glyphStyleHasMeta.multiSlot) {
									case true: macro {
										var range = rangeMapping.get(Std.int(charcode / rangeSize));
										if (range != null) {
											if (charcode >= range.min && charcode <= range.max) return range;
											else return null;
										} else return null;
									}
									default: macro {
										if (charcode >= rangeMapping.min && charcode <= rangeMapping.max) return rangeMapping;
										else return null;
									}
								}						
						}}
				}

				// --------------------------- Loading -------------------------
				public function load(?onProgressOverall:Int->Int->Void, onLoad:Void->Void)
				{
					utils.Loader.text(path + config, true, function(jsonString:String)
					{	
						jsonString = rComments.replace(jsonString, "");
						jsonString = rHexToDec.map(jsonString, function(r) return Std.string(Std.parseInt(r.matched(2))));
						
						var parser = new json2object.JsonParser<peote.text.FontConfig>();
						fontConfig = parser.fromJson(jsonString, path + config);
						
						for (e in parser.errors) {
							var pos = switch (e) {case IncorrectType(_, _, pos) | IncorrectEnumValue(_, _, pos) | InvalidEnumConstructor(_, _, pos) | UninitializedVariable(_, pos) | UnknownVariable(_, pos) | ParserError(_, pos): pos;}
							trace(pos.lines[0].number);
							if (pos != null) haxe.Log.trace(json2object.ErrorUtils.convertError(e), {fileName:pos.file, lineNumber:pos.lines[0].number,className:"",methodName:""});
						}

						var rangeSize = fontConfig.rangeSplitSize;
						
						${switch (glyphStyleHasMeta.packed) {
							case true: macro {
								if (!fontConfig.packed) {
									var error = 'Error, for $styleName "@packed" in "' + path + config +'" set "packed":true';
									haxe.Log.trace(error, {fileName:path+config, lineNumber:0,className:"",methodName:""});
									throw(error);
								}
							}
							default: macro {
								if (fontConfig.packed) {
									var error = 'Error, metadata of $styleName class has to be "@packed" for "' + path + config + '" and "packed":true';
									haxe.Log.trace(error, {fileName:path+config, lineNumber:0,className:"",methodName:""});
									throw(error);
								}
							}
						}}
						
						if (kerning && fontConfig.kerning != null) kerning = fontConfig.kerning;
						
						${switch (glyphStyleHasMeta.multiTexture || glyphStyleHasMeta.multiSlot) {
							case true: macro {}
							default: macro {
								if (ranges == null && fontConfig.ranges.length > 1) {
									var error = 'Error, set $styleName to @multiSlot and/or @multiTexture or define a single range while Font creation or inside "' + path + config +'"';
									haxe.Log.trace(error, {fileName:path+config, lineNumber:0,className:"",methodName:""});
									throw(error);
								}
							}
						}}

						var found_ranges = new Array<{image:String,data:String,slot:{width:Int, height:Int},range:Range}>();
						
						for( item in fontConfig.ranges )
						{
							var min = item.range.min;
							var max = item.range.max;
							
							if (ranges != null) {
								for (r in ranges) {
									if ((r.min >= min && r.min <= max) || (r.max >= min && r.max <= max)) {
										found_ranges.push(item);
										break;
									}
								}
							}
							else found_ranges.push(item);
							
							${switch (glyphStyleHasMeta.multiTexture || glyphStyleHasMeta.multiSlot) {
								case true: macro {}
								default: macro if (found_ranges.length == 1) break;
							}}
						}
						if (found_ranges.length == 0) {
							var error = 'Error, can not found any ranges inside font-config "'+path+config+'" that fit '+ranges;
							haxe.Log.trace(error, {fileName:path+config, lineNumber:0,className:"",methodName:""});
							throw(error);
						}
						else fontConfig.ranges = found_ranges;

						init(onProgressOverall, onLoad);
					});		
				}
				
				private function init(onProgressOverall:Int->Int->Void, onLoad:Void->Void)
				{
					${switch (glyphStyleHasMeta.multiTexture || glyphStyleHasMeta.multiSlot) {
						case true: macro
							rangeMapping = new haxe.ds.Vector<$rangeType>(Std.int(0x1000 * 20 / rangeSize));// TODO: is ( 0x1000 * 20) the greatest charcode for unicode ?
						default: macro {}
					}}
					
					${switch (glyphStyleHasMeta.multiTexture) {
						case true: macro {
							var sizes = new Array<{width:Int, height:Int, slots:Int}>();
							for (item in fontConfig.ranges) {
								var found = false;
								${switch (glyphStyleHasMeta.multiSlot) {
									case true: macro {
										for (i in 0...sizes.length) {
											if (sizes[i].width == item.slot.width && sizes[i].height == item.slot.height) {
												sizes[i].slots++;
												found = true;
											}
										}
									}
									default: macro {}
								}}
								if (!found) sizes.push({width:item.slot.width, height:item.slot.height, slots:1});
							}
							textureCache = new peote.view.utils.TextureCache(
								sizes,
								4, // colors -> TODO
								false, // mipmaps
								1,1, // min/mag-filter
								maxTextureSize
							);
							${switch (!glyphStyleHasMeta.packed)	{
								case true: macro {
									for (texture in textureCache.textures) {
										texture.tilesX = fontConfig.tilesX;
										texture.tilesY = fontConfig.tilesY;
									}
								}
								default: macro {}
							}}
						}
						default: macro {
							var w:Int = 0;
							var h:Int = 0;
							for (item in fontConfig.ranges) {
								if (item.slot.width > w) w = item.slot.width;
								if (item.slot.height > h) h = item.slot.height;
							}
							textureCache = new peote.view.Texture(w, h, fontConfig.ranges.length,
								4,// colors -> TODO
								false, // mipmaps
								1, 1, // min/mag-filter
								maxTextureSize
							);
							${switch (!glyphStyleHasMeta.packed)	{
								case true: macro {
									textureCache.tilesX = fontConfig.tilesX;
									textureCache.tilesY = fontConfig.tilesY;
								}
								default: macro {}
							}}
						}
					}}
				
					${switch (glyphStyleHasMeta.packed)	{
						case true: macro loadFontData(onProgressOverall, onLoad);
						default: macro loadImages(onProgressOverall, onLoad);
					}}
				}
				
				private function loadFontData(onProgressOverall:Int->Int->Void, onLoad:Void->Void):Void
				{		
					var gl3FontData = new Array<peote.text.Gl3FontData>();		
					utils.Loader.bytesArray(
						fontConfig.ranges.map(function (v) {
							if (v.data != null) return path + "/" + v.data;
							else return path + "/" + rParseEnding.replace(v.image, ".dat");
						}),
						true,
						function(index:Int, bytes:haxe.io.Bytes) { // after .dat is loaded
							gl3FontData[index] = new peote.text.Gl3FontData(bytes, fontConfig.ranges[index].range.min, fontConfig.ranges[index].range.max, kerning);
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
				
				private function loadImages(?gl3FontData:Array<peote.text.Gl3FontData>, onProgressOverall:Int->Int->Void, onLoad:Void->Void):Void
				{		
					trace("load images");
					utils.Loader.imageArray(
						fontConfig.ranges.map(function (v) return path+"/"+v.image),
						true,
						function(index:Int, loaded:Int, size:Int) {
							trace(' loading G3Font-Images progress ' + Std.int(loaded / size * 100) + "%" , " ("+loaded+" / "+size+")");
							if (onProgressOverall != null) onProgressOverall(loaded, size);
						},
						function(index:Int, image:peote.view.PeoteGL.Image) { // after every image is loaded
							//trace('File number $index loaded completely.');
							
							${switch (glyphStyleHasMeta.packed)
							{
								case true: macro // ------- Gl3Font -------
								{
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
									var range = fontConfig.ranges[index].range;
									
									${switch (glyphStyleHasMeta.multiTexture) {
										case true: macro {
											var p = textureCache.addImage(image); 
											//trace( image.width+"x"+image.height, "texture-unit:" + p.unit, "texture-slot:" + p.slot);							
											for (i in Std.int(range.min / rangeSize)...Std.int(range.max / rangeSize) + 1) {
												${switch (glyphStyleHasMeta.multiSlot) {
													case true: macro rangeMapping.set(i, {unit:p.unit, slot:p.slot, fontData:gl3font});
													default: macro rangeMapping.set(i, {unit:p.unit, fontData:gl3font});
												}}
											}
										}
										default: switch (glyphStyleHasMeta.multiSlot) {
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
								}
								default: macro // ------- simple font -------
								{
									// sort ranges into rangeMapping
									var range = fontConfig.ranges[index].range;
									
									${switch (glyphStyleHasMeta.multiTexture) {
										case true: macro {
											var p = textureCache.addImage(image); 
											//trace( image.width+"x"+image.height, "texture-unit:" + p.unit, "texture-slot:" + p.slot);							
											for (i in Std.int(range.min / rangeSize)...Std.int(range.max / rangeSize) + 1) {
												${switch (glyphStyleHasMeta.multiSlot) {
													case true: macro rangeMapping.set(i, {unit:p.unit, slot:p.slot, min:range.min, max:range.max});
													default: macro rangeMapping.set(i, {unit:p.unit, min:range.min, max:range.max});
												}}
											}
										}
										default: switch (glyphStyleHasMeta.multiSlot) {
											case true: macro {
												textureCache.setImage(image, index);
												for (i in Std.int(range.min / rangeSize)...Std.int(range.max / rangeSize)+1) {
													rangeMapping.set(i, {slot:index, min:range.min, max:range.max});
												}
											}
											default: macro {
												textureCache.setImage(image);
												rangeMapping = {min:range.min, max:range.max};
											}
										}
									}}
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
					if (glyphStyleHasMeta.multiSlot) {
						
					}
					else {
					}
				}
				else {
					if (glyphStyleHasMeta.multiSlot) {
						
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
