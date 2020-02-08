package peote.text;

#if !macro
@:genericBuild(peote.text.FontProgram.FontProgramMacro.build())
class FontProgram<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class FontProgramMacro
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
							"FontProgram", style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(t)
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
			
			var charDataType:ComplexType;
			if (glyphStyleHasMeta.packed) {
				if (glyphStyleHasMeta.multiTexture && glyphStyleHasMeta.multiSlot) charDataType = macro: {unit:Int, slot:Int, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
				else if (glyphStyleHasMeta.multiTexture) charDataType = macro: {unit:Int, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
				else if (glyphStyleHasMeta.multiSlot) charDataType = macro: {slot:Int, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
				else charDataType = macro: {fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
			}
			else  {
				if (glyphStyleHasMeta.multiTexture && glyphStyleHasMeta.multiSlot) charDataType = macro: {unit:Int, slot:Int, min:Int, max:Int};
				else if (glyphStyleHasMeta.multiTexture) charDataType = macro: {unit:Int, min:Int, max:Int};
				else if (glyphStyleHasMeta.multiSlot) charDataType = macro: {slot:Int, min:Int, max:Int};
				else charDataType = macro: {min:Int, max:Int};
			}

			// -------------------------------------------------------------------------------------------
			var c = macro		

			class $className extends peote.view.Program
			{
				public var font:peote.text.Font<$styleType>; // TODO peote.text.Font<$styleType>
				public var fontStyle:$styleType;
				
				public var penX:Float = 0.0;
				public var penY:Float = 0.0;
				
				var prev_charcode = -1;
				
				var _buffer:peote.view.Buffer<$glyphType>;
				
				public function new(font:peote.text.Font<$styleType>, fontStyle:$styleType)
				{
					_buffer = new peote.view.Buffer<$glyphType>(1024,1024,true);
					super(_buffer);	
					
					setFont(font);
					setFontStyle(fontStyle);
				}
				
				// -----------------------------------------
				// ---------------- Font  ------------------
				// -----------------------------------------
				public inline function setFont(font:Font<$styleType>):Void
				{
					this.font = font;
					autoUpdateTextures = false;

					${switch (glyphStyleHasMeta.multiTexture) {
						case true: macro setMultiTexture(font.textureCache.textures, "TEX");
						default: macro setTexture(font.textureCache, "TEX");
					}}
				}
				
				public inline function setFontStyle(fontStyle:$styleType):Void
				{
					this.fontStyle = fontStyle;
					
					var color:String;
					${switch (glyphStyleHasField.local_color) {
						case true: macro color = "color";
						default: switch (glyphStyleHasField.color) {
							case true: macro color = Std.string(fontStyle.color.toGLSL());
							default: macro color = Std.string(font.config.color.toGLSL());
					}}}
					
					// check distancefield-rendering
					if (font.config.distancefield) {
						var weight = "0.5";
						${switch (glyphStyleHasField.local_weight) {
							case true:  macro weight = "weight";
							default: switch (glyphStyleHasField.weight) {
								case true: macro weight = peote.view.utils.Util.toFloatString(fontStyle.weight);
								default: macro {}
							}
						}}
						var sharp = peote.view.utils.Util.toFloatString(0.5); // TODO
						setColorFormula(color + " * smoothstep( "+weight+" - "+sharp+" * fwidth(TEX.r), "+weight+" + "+sharp+" * fwidth(TEX.r), TEX.r)");							
					}
					else {
						// TODO: bold for no distancefields needs some more spice inside fragmentshader (access to neightboar pixels!)

						// TODO: dirty outline
/*						injectIntoFragmentShader(
						"
							float outline(float t, float threshold, float width)
							{
								return clamp(width - abs(threshold - t) / fwidth(t), 0.0, 1.0);
							}						
						");
						//setColorFormula("mix("+color+" * TEX.r, vec4(1.0,1.0,1.0,1.0), outline(TEX.r, 1.0, 5.0))");							
						//setColorFormula("mix("+color+" * TEX.r, "+color+" , outline(TEX.r, 1.0, 2.0))");							
						//setColorFormula(color + " * mix( TEX.r, 1.0, outline(TEX.r, 0.3, 1.0*uZoom) )");							
						//setColorFormula("mix("+color+"*TEX.r, vec4(1.0,1.0,0.0,1.0), outline(TEX.r, 0.0, 1.0*uZoom) )");							
*/						
						setColorFormula(color + " * TEX.r");							
					}

					alphaEnabled = true;
					
					${switch (glyphStyleHasField.zIndex && !glyphStyleHasField.local_zIndex) {
						case true: macro setFormula("zIndex", peote.view.utils.Util.toFloatString(fontStyle.zIndex));
						default: macro {}
					}}
					
					${switch (glyphStyleHasField.rotation && !glyphStyleHasField.local_rotation) {
						case true: macro setFormula("rotation", peote.view.utils.Util.toFloatString(fontStyle.rotation));
						default: macro {}
					}}
					

					var tilt:String = "0.0";
					${switch (glyphStyleHasField.local_tilt) {
						case true:  macro tilt = "tilt";
						default: switch (glyphStyleHasField.tilt) {
							case true: macro tilt = peote.view.utils.Util.toFloatString(fontStyle.tilt);
							default: macro {}
						}
					}}
					
					
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- packed font -------
						{
							// tilting
							if (tilt != "0.0") setFormula("x", "x + (1.0-aPosition.y)*w*" + tilt);
						}
						default: macro // ------- simple font -------
						{
							// make width/height constant if global
							${switch (glyphStyleHasField.local_width) {
								case true: macro {}
								default: switch (glyphStyleHasField.width) {
									case true:
										macro setFormula("width", peote.view.utils.Util.toFloatString(fontStyle.width));
									default:
										macro setFormula("width", peote.view.utils.Util.toFloatString(font.config.width));
							}}}
							${switch (glyphStyleHasField.local_height) {
								case true: macro {}
								default: switch (glyphStyleHasField.height) {
									case true:
										macro setFormula("height", peote.view.utils.Util.toFloatString(fontStyle.height));
									default:
										macro setFormula("height", peote.view.utils.Util.toFloatString(font.config.height));
							}}}
							
							// mixing alpha while use of zIndex
							${switch (glyphStyleHasField.zIndex) {
								case true: macro {discardAtAlpha(0.5);}
								default: macro {}
							}}
							
							if (tilt != "" && tilt != "0.0") setFormula("x", "x + (1.0-aPosition.y)*width*" + tilt);
							
						}
						
					}}
					
					updateTextures();
				}
				
				// -------------------------------------------------------------------------------------------------
				// -------------------------------------------------------------------------------------------------
				// -------------------------------------------------------------------------------------------------
				
				inline function getLineMetric(glyph:$glyphType, fontData:peote.text.Gl3FontData): {asc:Float, base:Float, desc:Float}
				{
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							var height = ${switch (glyphStyleHasField.local_height) {
								case true: macro glyph.height;
								default: switch (glyphStyleHasField.height) {
									case true: macro fontStyle.height;
									default: macro font.config.height;
							}}}
							return {
								asc: height *(fontData.height + fontData.descender - (1 + fontData.ascender - fontData.height)),
								base:height *(fontData.height + fontData.descender),
								desc:height * fontData.height
							};
							
						}
						default: macro // ------- simple font -------
						{
							return null; // TODO: baseline from fontconfig!!!
						}
					}}
					
				}
				
				// returns range, fontdata and metric in dependend of font-type
				inline function getCharData(charcode:Int):$charDataType 
				{
					${switch (glyphStyleHasMeta.packed) {
						// ------- Gl3Font -------
						case true: 
							if (glyphStyleHasMeta.multiTexture && glyphStyleHasMeta.multiSlot) {
								macro {
									var range = font.getRange(charcode);
									if (range != null) {
										var metric = range.fontData.getMetric(charcode);
										if (metric == null) return null;
										else return {unit:range.unit, slot:range.slot, fontData:range.fontData, metric:metric};
									}
									else return null;
								}
							}
							else if (glyphStyleHasMeta.multiTexture) 
								macro {
									var range = font.getRange(charcode);
									if (range != null) {
										var metric = range.fontData.getMetric(charcode);
										if (metric == null) return null;
										else return {unit:range.unit, fontData:range.fontData, metric:metric};
									}
									else return null;
								}
							else if (glyphStyleHasMeta.multiSlot)
								macro {
									var range = font.getRange(charcode);
									if (range != null) {
										var metric = range.fontData.getMetric(charcode);
										if (metric == null) return null;
										else return {slot:range.slot, fontData:range.fontData, metric:metric};
									}
									else return null;
								}
							else macro {
									var metric = font.getRange(charcode).getMetric(charcode);
									if (metric == null) return null;
									else return {fontData:font.getRange(charcode), metric:metric};
								}
						// ------- simple font -------
						default:macro return font.getRange(charcode);
					}}
				}
				
				// -------------------------------------------------
				
				inline function rightGlyphPos(glyph:$glyphType, charData:$charDataType):Float
				{
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							${switch (glyphStyleHasField.local_width) {
								case true: macro return glyph.x + (charData.metric.advance - charData.metric.left) * glyph.width;
								default: switch (glyphStyleHasField.width) {
									case true: macro return glyph.x + (charData.metric.advance - charData.metric.left) * fontStyle.width;
									default: macro return glyph.x + (charData.metric.advance - charData.metric.left) * font.config.width;
							}}}
						}
						default: macro // ------- simple font -------
						{
							return glyph.x + glyph.width;
						}
					}}
				}
				
				inline function leftGlyphPos(glyph:$glyphType, charData:$charDataType):Float
				{
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							${switch (glyphStyleHasField.local_width) {
								case true: macro return glyph.x - (charData.metric.left) * glyph.width;
								default: switch (glyphStyleHasField.width) {
									case true: macro return glyph.x - (charData.metric.left) * fontStyle.width;
									default: macro return glyph.x - (charData.metric.left) * font.config.width;
							}}}
						}
						default: macro // ------- simple font -------
						{
							return glyph.x;
						}
					}}
					
				}
				
				inline function nextGlyphOffset(glyph:$glyphType, charData:$charDataType):Float
				{
					${switch (glyphStyleHasMeta.packed)
					{	case true: macro // ------- Gl3Font -------
						{
							${switch (glyphStyleHasField.local_width) {
								case true: macro return charData.metric.advance * glyph.width;
								default: switch (glyphStyleHasField.width) {
									case true: macro return charData.metric.advance * fontStyle.width;
									default: macro return charData.metric.advance * font.config.width;
							}}}
						}
						default: macro {
							return glyph.width;//TODO: - width / font.config.width * (font.config.paddingRight - font.config.paddingLeft);
						}
					}}					
				}
				
				inline function kerningOffset(prev_glyph:$glyphType, glyph:$glyphType, kerning:Array<Array<Float>>):Float
				{
					${switch (glyphStyleHasMeta.packed)
					{	case true: macro // ------- Gl3Font -------
						{	
							if (font.kerning && prev_glyph != null) 
							{	trace("kerning: ", prev_glyph.char, glyph.char, " -> " + kerning[prev_glyph.char][glyph.char]);
								${switch (glyphStyleHasField.local_width) {
									case true: macro return kerning[prev_glyph.char][glyph.char] * (glyph.width + prev_glyph.width)/2;
									default: switch (glyphStyleHasField.width) {
										case true: macro return kerning[prev_glyph.char][glyph.char] * fontStyle.width;
										default: macro return kerning[prev_glyph.char][glyph.char] * font.config.width;
								}}}
							} else return 0.0;
						}
						default: macro {
							return 0.0;
						}
					}}					
				}
				
				// -------------------------------------------------

				inline function setPosition(glyph:$glyphType, charData:$charDataType, x:Float, y:Float)
				{					
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							${switch (glyphStyleHasField.local_width) {
								case true: macro glyph.x = x + charData.metric.left * glyph.width;
								default: switch (glyphStyleHasField.width) {
									case true: macro glyph.x = x + charData.metric.left * fontStyle.width;
									default: macro glyph.x = x + charData.metric.left * font.config.width;
							}}}
							${switch (glyphStyleHasField.local_height) {
								case true: macro glyph.y = y + (charData.fontData.height + charData.fontData.descender - charData.metric.top) * glyph.height;
								default: switch (glyphStyleHasField.height) {
									case true: macro glyph.y = y + (charData.fontData.height + charData.fontData.descender - charData.metric.top) * fontStyle.height;
									default: macro glyph.y = y + (charData.fontData.height + charData.fontData.descender - charData.metric.top) * font.config.height;
							}}}							
						}
						default: macro // ------- simple font -------
						{
							glyph.x = x;
							glyph.y = y;
						}
					}}
				}
				
				inline function setSize(glyph:$glyphType, charData:$charDataType)
				{
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							${switch (glyphStyleHasField.local_width) {
								case true: macro glyph.w = charData.metric.width * glyph.width;
								default: switch (glyphStyleHasField.width) {
									case true: macro glyph.w = charData.metric.width * fontStyle.width;
									default: macro glyph.w = charData.metric.width * font.config.width;
							}}}
							${switch (glyphStyleHasField.local_height) {
								case true: macro glyph.h = charData.metric.height * glyph.height;
								default: switch (glyphStyleHasField.height) {
									case true: macro glyph.h = charData.metric.height * fontStyle.height;
									default: macro glyph.h = charData.metric.height * font.config.height;
							}}}
						}
						default: macro {} // ------- simple font have no metric
					}}
				}
				
				inline function setCharcode(glyph:$glyphType, charcode:Int, charData:$charDataType)
				{
					glyph.char = charcode;
					
					${switch (glyphStyleHasMeta.multiTexture) {
						case true: macro glyph.unit = charData.unit;
						default: macro {}
					}}
					${switch (glyphStyleHasMeta.multiSlot) {
						case true: macro glyph.slot = charData.slot;
						default: macro {}
					}}
					
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							// TODO: let glyphes-width also include metrics with tex-offsets on need
							glyph.tx = charData.metric.u; // TODO: offsets for THICK letters
							glyph.ty = charData.metric.v;
							glyph.tw = charData.metric.w;
							glyph.th = charData.metric.h;							
						}
						default: macro // ------- simple font -------
						{
							glyph.tile = charcode - charData.min;
						}
					}}
				
				}
				
				// -----------------------------------------
				// ---------------- Glyphes ----------------
				// -----------------------------------------
								
				public inline function createGlyph(charcode:Int, x:Float, y:Float, glyphStyle:$styleType = null):$glyphType {
					var charData = getCharData(charcode);
					if (charData != null) {
						var glyph = new peote.text.Glyph<$styleType>();
						glyphSetStyle(glyph, glyphStyle);
						setCharcode(glyph, charcode, charData);
						setSize(glyph, charData);
						glyph.x = x;
						glyph.y = y;
						_buffer.addElement(glyph);
						return glyph;
					} else return null;
				}
				
				public inline function setGlyph(glyph:$glyphType, charcode:Int, x:Float, y:Float, glyphStyle:$styleType = null):Bool {
					var charData = getCharData(charcode);
					if (charData != null) {
						glyphSetStyle(glyph, glyphStyle);
						setCharcode(glyph, charcode, charData);
						setSize(glyph, charData);
						glyph.x = x;
						glyph.y = y;
						_buffer.addElement(glyph);
						return true;
					} else return false;
				}
								
				public inline function addGlyph(glyph:$glyphType):Void {
						_buffer.addElement(glyph);
				}
								
				public inline function removeGlyph(glyph:$glyphType):Void {
					_buffer.removeElement(glyph);
				}
								
				public inline function updateGlyph(glyph:$glyphType):Void {
					_buffer.updateElement(glyph);
				}
				
				public inline function glyphSetStyle(glyph:$glyphType, glyphStyle:$styleType) {
					glyph.setStyle((glyphStyle != null) ? glyphStyle : fontStyle);
				}

				// sets position in depend of metrics-data
				// TODO: put at a baseline and special for simple font
				public inline function glyphSetPosition(glyph:$glyphType, x:Float, y:Float) {
					var charData = getCharData(glyph.char);
					setPosition(glyph, charData, x, y);
				}

				public inline function glyphSetChar(glyph:$glyphType, charcode:Int):Bool
				{
					var charData = getCharData(charcode);
					if (charData != null) {
						setCharcode(glyph, charcode, charData);
						setSize(glyph, charData);
						return true;
					} else return false;
				}
				
				// -----------------------------------------
				// ---------------- Lines ------------------
				// -----------------------------------------
				public function createLine(chars:String, x:Float=0, y:Float=0, glyphStyle:$styleType = null):peote.text.Line<$styleType>
				{
					var line = new peote.text.Line<$styleType>();
					if (setLine(line, chars, x, y, glyphStyle)) return line else return null;
				}
				
				public function addLine(line:Line<$styleType>)
				{
					//for (glyph in line.glyphes) addGlyph(glyph);
					for (i in line.visibleFrom...line.visibleTo) addGlyph(line.glyphes[i]);
				}
				
				public function removeLine(line:Line<$styleType>)
				{
					//for (glyph in line.glyphes) removeGlyph(glyph);
					for (i in line.visibleFrom...line.visibleTo) removeGlyph(line.glyphes[i]);
				}
				
				public inline function setLine(line:Line<$styleType>, chars:String, x:Float=0, y:Float=0, glyphStyle:$styleType = null):Bool
				{
					trace("setLine");
					
					line.x = x;
					line.y = y;
//TODO					
					x += line.xOffset;					
					y += line.yOffset;					
						
					if (line.glyphes.length == 0)
					{
						if (_lineAppend(line, chars, x, y, null, glyphStyle, true) == null) return false else return true;
					}
					else
					{
						if (line.glyphes.length > chars.length) {
							lineDeleteChars(line, chars.length);
							for (i in Std.int(Math.max(chars.length, line.visibleFrom))...Std.int(Math.min(line.glyphes.length, line.visibleTo))) {
								removeGlyph(line.glyphes[i]);
							}
							line.glyphes.splice(chars.length, line.glyphes.length - chars.length);							
						}
						line.updateFrom = 0;
						line.updateTo = line.glyphes.length;
						
						var prev_glyph:peote.text.Glyph<$styleType> = null;
						var i = 0;
						var ret = true;
						var charData:$charDataType = null;
						
						var visibleFrom:Int = 0;
						var visibleTo:Int = 0;
						
						haxe.Utf8.iter(chars, function(charcode)
						{
							charData = getCharData(charcode);
							if (charData != null)
							{
								if (i == line.glyphes.length) { // append
									line.glyphes.push(new peote.text.Glyph<$styleType>());
									glyphSetStyle(line.glyphes[i], glyphStyle);
									setCharcode(line.glyphes[i], charcode, charData);
									setSize(line.glyphes[i], charData);
									${switch (glyphStyleHasMeta.packed) {
										case true: macro x += kerningOffset(prev_glyph, line.glyphes[i], charData.fontData.kerning);
										default: macro {}
									}}
									setPosition(line.glyphes[i], charData, x, y);
//TODO
									if (line.glyphes[i].x + ${switch(glyphStyleHasMeta.packed) {case true: macro line.glyphes[i].w; default: macro line.glyphes[i].width;}} >= line.x) {														
										if (line.glyphes[i].x < line.maxX) {
											_buffer.addElement(line.glyphes[i]);
											visibleTo ++;
										}
									}
									else {
										visibleFrom ++;
										visibleTo ++;
									}

									x += nextGlyphOffset(line.glyphes[i], charData);
								}
								else { // set over
									if (glyphStyle != null) glyphSetStyle(line.glyphes[i], glyphStyle);
									setCharcode(line.glyphes[i], charcode, charData);
									setSize(line.glyphes[i], charData);
									${switch (glyphStyleHasMeta.packed) {
										case true: macro x += kerningOffset(prev_glyph, line.glyphes[i], charData.fontData.kerning);
										default: macro {}
									}}
									setPosition(line.glyphes[i], charData, x, y);
//TODO								
									if (line.glyphes[i].x + ${switch(glyphStyleHasMeta.packed) {case true: macro line.glyphes[i].w; default: macro line.glyphes[i].width;}} >= line.x) {														
										if (line.glyphes[i].x < line.maxX) {
											if (i < line.visibleFrom || i >= line.visibleTo) _buffer.addElement(line.glyphes[i]);
											visibleTo ++;
										} else if (i < line.visibleTo) _buffer.removeElement(line.glyphes[i]);
									}
									else {
										if (i >= line.visibleFrom) _buffer.removeElement(line.glyphes[i]);
										visibleFrom ++;
										visibleTo ++;
									}
									
									x += nextGlyphOffset(line.glyphes[i], charData);
								}
								prev_glyph = line.glyphes[i];
							}
							else ret = false;
							i++;
						});
						
						line.visibleFrom = visibleFrom;
						line.visibleTo = visibleTo;
						
						line.fullWidth = x - line.x - line.xOffset;

						${switch (glyphStyleHasMeta.packed) {
							case true: macro {
								if (prev_glyph != null) {
									var lm = getLineMetric(prev_glyph, charData.fontData);
									line.asc = lm.asc;
									line.desc = lm.desc;
									line.base = lm.base;
									trace("line metric:", line.asc, line.desc, line.base);
								}
							}
							default: macro {}
						}}
						return ret;
					}
				}
				
				// ----------- change Line Style and Position ----------------
				
				public function lineSetStyle(line:Line<$styleType>, glyphStyle:$styleType, from:Int = 0, to:Null<Int> = null)
				{
					if (to == null) to = line.glyphes.length;
					//else if (to <= from) throw('lineSetStyle parameter "from" has to be greater then "to"');
					
					if (from < line.updateFrom) line.updateFrom = from;
					if (to > line.updateTo) line.updateTo = to;
					
					var prev_glyph:peote.text.Glyph<$styleType> = null;
					
					var x = line.x;
					var y = line.y;
					
					if (from > 0) {
						x = rightGlyphPos(line.glyphes[from - 1], getCharData(line.glyphes[from - 1].char));
						prev_glyph = line.glyphes[from - 1];
					}
					
					// first
					line.glyphes[from].setStyle(glyphStyle);
					var charData = getCharData(line.glyphes[from].char);
					${switch (glyphStyleHasMeta.packed) {
						case true: macro {
							var lm = getLineMetric(line.glyphes[from], charData.fontData);
							if (line.desc != lm.desc) y += (line.base - lm.base);
						}
						default: macro {
							// TODO: baseline for simplefont
						}
					}}
					setPosition(line.glyphes[from], charData, x, y);
					x += nextGlyphOffset(line.glyphes[from], charData);
					prev_glyph = line.glyphes[from];
					
					for (i in from+1...to)
					{
						line.glyphes[i].setStyle(glyphStyle);
						charData = getCharData(line.glyphes[i].char);
						${switch (glyphStyleHasMeta.packed) {
							case true: macro x += kerningOffset(prev_glyph, line.glyphes[i], charData.fontData.kerning);
							default: macro {}
						}}
						setPosition(line.glyphes[i], charData, x, y);
						x += nextGlyphOffset(line.glyphes[i], charData);
						prev_glyph = line.glyphes[i];
					}

					if (to < line.glyphes.length) // rest
					{
						${switch (glyphStyleHasMeta.packed) {
							case true: macro x += kerningOffset(prev_glyph, line.glyphes[to], charData.fontData.kerning);
							default: macro {}
						}}
						var offset = x - leftGlyphPos(line.glyphes[to], getCharData(line.glyphes[to].char));
						if (offset != 0.0) {
							//trace("REST:"+String.fromCharCode(line.glyphes[to]), x, line.glyphes[to].x);
							_setLinePositionOffset(line, offset, to);
						}
					}
					
				}
				
				// TODO: optimized lineSetXPosition and lineSetYPosition
				public function lineSetPosition(line:Line<$styleType>, xNew:Float, yNew:Float)
				{
					line.updateFrom = 0;
					line.updateTo = line.glyphes.length;
					for (i in 0...line.updateTo) {
						line.glyphes[i].x += xNew - line.x;
						line.glyphes[i].y += yNew - line.y;
					}
					line.x = xNew;
					line.y = yNew;
				}
				
				inline function _setLinePositionOffset(line:Line<$styleType>, deltaX:Float, from:Int)
				{
					trace("------ _setLinePositionOffset: ------",deltaX,from);
					var visibleFrom = line.visibleFrom;
					var visibleTo = line.visibleTo;
					//trace("FROM:", from);
					for (i in from...line.glyphes.length) {
						line.glyphes[i].x += deltaX;
						
						if (line.glyphes[i].x + ${switch(glyphStyleHasMeta.packed) {case true: macro line.glyphes[i].w; default: macro line.glyphes[i].width; }} >= line.x)
						{	//trace("AAAA",i,(line.glyphes[i].x < line.maxX),(i < line.visibleTo));
							if (line.glyphes[i].x < line.maxX) {
								if (i < line.visibleFrom || i >= line.visibleTo) {
									_buffer.addElement(line.glyphes[i]);
									if (visibleFrom > i) visibleFrom = i;
									if (visibleTo < i + 1) visibleTo = i + 1;
								}
							} else if (i < line.visibleTo) { // i >= line.visibleFrom &&       <------ CHECK if this is need !!!
								//trace("KK", i, visibleTo);
								_buffer.removeElement(line.glyphes[i]);
								if (visibleTo > i) visibleTo = i;
							}
						}
						else {
							//trace("BBBB",i,(i >= line.visibleFrom && i < line.visibleTo));
							if (i >= line.visibleFrom && i < line.visibleTo) {
								_buffer.removeElement(line.glyphes[i]);
							}
							visibleFrom = i + 1;
						}
						//trace(i, "visibleFrom:"+visibleFrom + " visibleTo:"+visibleTo);
					}
					line.visibleFrom = visibleFrom;
					line.visibleTo = visibleTo;
						
					line.fullWidth += deltaX;
				}
				
				// ------------ set/insert/delete chars from a line ---------------
				
				public function lineSetChar(line:Line<$styleType>, charcode:Int, position:Int=0, glyphStyle:$styleType = null):Bool
				{
					var charData = getCharData(charcode);
					if (charData != null)
					{
						if (position < line.updateFrom) line.updateFrom = position;
						if (position + 1 > line.updateTo) line.updateTo = position + 1;
						
						var prev_glyph:peote.text.Glyph<$styleType> = null;
						
						var x = line.x;
						var y = line.y;
						
						if (position > 0) {
							x = rightGlyphPos(line.glyphes[position - 1], getCharData(line.glyphes[position - 1].char));
							prev_glyph = line.glyphes[position - 1];
						}
					
						if (glyphStyle != null) {
							glyphSetStyle(line.glyphes[position], glyphStyle);
							${switch (glyphStyleHasMeta.packed) {
								case true: macro {
									var lm = getLineMetric(line.glyphes[position], charData.fontData);
									if (line.desc != lm.desc) y += (line.base - lm.base);
								}
								default: macro {
									// TODO: baseline for simplefont
								}
							}}
						}
						setCharcode(line.glyphes[position], charcode, charData);
						setSize(line.glyphes[position], charData);
						${switch (glyphStyleHasMeta.packed) {
							case true: macro x += kerningOffset(prev_glyph, line.glyphes[position], charData.fontData.kerning);
							default: macro {}
						}}
						setPosition(line.glyphes[position], charData, x, y);
						
						if (position+1 < line.glyphes.length) // rest
						{	
							x += nextGlyphOffset(line.glyphes[position], charData);
							${switch (glyphStyleHasMeta.packed) {
								case true: macro x += kerningOffset(line.glyphes[position], line.glyphes[position+1], charData.fontData.kerning);
								default: macro {}
							}}
							var offset = x - leftGlyphPos(line.glyphes[position+1], getCharData(line.glyphes[position+1].char));
							if (offset != 0.0) {
								//trace("REST:"+String.fromCharCode(line.glyphes[position+1].char), x, line.glyphes[position+1].x);
								_setLinePositionOffset(line, offset, position+1);
							}
						}
						return true;
					} 
					else return false;					
				}
				
				public function lineSetChars(line:Line<$styleType>, chars:String, position:Int=0, glyphStyle:$styleType = null):Bool
				{
					if (position < line.updateFrom) line.updateFrom = position;
					if (position + chars.length > line.updateTo) line.updateTo = Std.int(Math.min(position + chars.length, line.glyphes.length));
					
					var prev_glyph:peote.text.Glyph<$styleType> = null;
					var x = line.x;
					var y = line.y;
					
					if (position > 0) {
						x = rightGlyphPos(line.glyphes[position - 1], getCharData(line.glyphes[position - 1].char));
						prev_glyph = line.glyphes[position - 1];
					}

					var i = position;
					var ret = true;
					var charData:$charDataType = null;
					
					haxe.Utf8.iter(chars, function(charcode)
					{
						if (i < line.glyphes.length) 
						{							
							charData = getCharData(charcode);
							if (charData != null)
							{
								if (glyphStyle != null) {
									glyphSetStyle(line.glyphes[i], glyphStyle);
									if (i == position) // first
									{
										${switch (glyphStyleHasMeta.packed) {
											case true: macro {
												var lm = getLineMetric(line.glyphes[i], charData.fontData);
												if (line.desc != lm.desc) y += (line.base - lm.base);
											}
											default: macro {
												// TODO: baseline for simplefont
											}
										}}										
									}
								}
								setCharcode(line.glyphes[i], charcode, charData);
								setSize(line.glyphes[i], charData);
								${switch (glyphStyleHasMeta.packed) {
									case true: macro x += kerningOffset(prev_glyph, line.glyphes[i], charData.fontData.kerning);
									default: macro {}
								}}
								setPosition(line.glyphes[i], charData, x, y);
								x += nextGlyphOffset(line.glyphes[i], charData);
								prev_glyph = line.glyphes[i];
							}
							else ret = false;
						}
						else if (! lineInsertChar(line, charcode, i, glyphStyle)) ret = false; // TODO: optimize if much use of
						i++;
					});
					
					if (i < line.glyphes.length) // rest
					{	
						${switch (glyphStyleHasMeta.packed) {
							case true: macro x += kerningOffset(line.glyphes[i-1], line.glyphes[i], charData.fontData.kerning);
							default: macro {}
						}}
						var offset = x - leftGlyphPos(line.glyphes[i], getCharData(line.glyphes[i].char));
						if (offset != 0.0) {
							//trace("REST:"+String.fromCharCode(line.glyphes[i].char), x, line.glyphes[i].x);
							_setLinePositionOffset(line, offset, i);
						}
					}
					
					return ret;
				}
				
				public function lineInsertChar(line:Line<$styleType>, charcode:Int, position:Int = 0, glyphStyle:$styleType = null):Bool
				{
					var charData = getCharData(charcode);
					if (charData != null)
					{
						var prev_glyph:peote.text.Glyph<$styleType> = null;
						
						var x = line.x + line.xOffset;
						var y = line.y + line.yOffset;
						
						if (position > 0) {
							x = rightGlyphPos(line.glyphes[position - 1], getCharData(line.glyphes[position - 1].char));
							prev_glyph = line.glyphes[position - 1];
						}
						var x_start = x;
						
						var glyph = new peote.text.Glyph<$styleType>();
						
						glyphSetStyle(glyph, glyphStyle);
						${switch (glyphStyleHasMeta.packed) {
							case true: macro {
								var lm = getLineMetric(glyph, charData.fontData);
								if (line.desc != lm.desc) y += (line.base - lm.base);
							}
							default: macro {
								// TODO: baseline for simplefont
							}
						}}

						setCharcode(glyph, charcode, charData);
						setSize(glyph, charData);
						${switch (glyphStyleHasMeta.packed) {
							case true: macro x += kerningOffset(prev_glyph, glyph, charData.fontData.kerning);
							default: macro {}
						}}
						setPosition(glyph, charData, x, y);						
						
						x += nextGlyphOffset(glyph, charData);
						line.fullWidth += x - x_start;

						if (position < line.glyphes.length) {
							if (position < line.updateFrom) line.updateFrom = position+1;
							line.updateTo = line.glyphes.length+1;
							_setLinePositionOffset(line, x - x_start, position);
						}
						
						line.glyphes.insert(position, glyph);
						
						if (glyph.x + ${switch(glyphStyleHasMeta.packed) {case true: macro glyph.w; default: macro glyph.width; }} >= line.x)
						{
							if (glyph.x < line.maxX)	{
								_buffer.addElement(glyph);
								line.visibleTo++;
							}
						} 
						else {
							line.visibleFrom++;
							line.visibleTo++;
						}
						return true;
					}
					else return false;
				}
				
				public function lineInsertChars(line:Line<$styleType>, chars:String, position:Int = 0, glyphStyle:$styleType = null):Bool 
				{					
					var prev_glyph:peote.text.Glyph<$styleType> = null;
					var x = line.x + line.xOffset;
					var y = line.y + line.yOffset;
					if (position > 0) {
						x = rightGlyphPos(line.glyphes[position - 1], getCharData(line.glyphes[position - 1].char));
						prev_glyph = line.glyphes[position - 1];
					}
					var x_start = x;
					var rest = line.glyphes.splice(position, line.glyphes.length - position);
					
					if (rest.length > 0) {
						var oldFrom = line.visibleFrom - line.glyphes.length;
						var oldTo = line.visibleTo - line.glyphes.length;
						if (line.visibleFrom > line.glyphes.length) line.visibleFrom = line.glyphes.length;
						if (line.visibleTo > line.glyphes.length) line.visibleTo = line.glyphes.length;
						var x = _lineAppend(line, chars, x, y, prev_glyph, glyphStyle);
						if (x != null) {
							if (line.glyphes.length < line.updateFrom) line.updateFrom = line.glyphes.length;
							
							var deltaX = x - x_start;
							//trace("after append:", line.visibleFrom, line.visibleTo );
							//trace("old:",oldFrom, oldTo);
							//trace("------ insertChars: setLinePositionOffset: ------");
							for (i in 0...rest.length) {
								rest[i].x += deltaX;
								
								if (rest[i].x + ${switch(glyphStyleHasMeta.packed) {case true: macro rest[i].w; default: macro rest[i].width; }} >= line.x)
								{	//trace("AAAA",i,(rest[i].x < line.maxX),(i < oldTo));
									if (rest[i].x < line.maxX) {
										if (i < oldFrom || i >= oldTo) {
											_buffer.addElement(rest[i]);
										}
										line.visibleTo++;
									} else if (i >= oldFrom && i < oldTo) {
										 //trace("KK", i, oldTo);
										_buffer.removeElement(rest[i]);
									}
								}
								else {
									//trace("BBBB",i,(i >= oldFrom && i < oldTo));
									if (i >= oldFrom && i < oldTo) {
										_buffer.removeElement(rest[i]);
									}
									line.visibleFrom++;
									line.visibleTo++;
								}
							}
							//trace("--B", line.visibleFrom, line.visibleTo);
								
							line.fullWidth += deltaX;
							
							line.glyphes = line.glyphes.concat(rest);
							line.updateTo = line.glyphes.length;
							
							return true;
						} 
						else return false;
					}
					else if (_lineAppend(line, chars, x, y, prev_glyph, glyphStyle) == null) return false else return true;
				}

				public function lineAppendChars(line:Line<$styleType>, chars:String, glyphStyle:$styleType = null):Bool 
				{					
					var prev_glyph:peote.text.Glyph<$styleType> = null;
					var x = line.x;
					var y = line.y;					
					if (line.glyphes.length > 0) {
						x = rightGlyphPos(line.glyphes[line.glyphes.length - 1], getCharData(line.glyphes[line.glyphes.length - 1].char));
						prev_glyph = line.glyphes[line.glyphes.length - 1];
					}
					if (_lineAppend(line, chars, x, y, prev_glyph, glyphStyle) == null) return false else return true;
				}
				
				public inline function _lineAppend(line:Line<$styleType>, chars:String, x:Float, y:Float, prev_glyph:peote.text.Glyph<$styleType>, glyphStyle:$styleType, setNewLineMetrics:Bool = false):Null<Float>
				{
					var ret = true;
					var first = ! setNewLineMetrics;
					var glyph:peote.text.Glyph<$styleType> = null;
					var charData:$charDataType = null;
					
					haxe.Utf8.iter(chars, function(charcode)
					{
						charData = getCharData(charcode);
						if (charData != null)
						{
							glyph = new peote.text.Glyph<$styleType>();
							line.glyphes.push(glyph);
							glyphSetStyle(glyph, glyphStyle);
							if (first) {
								first = false;
								${switch (glyphStyleHasMeta.packed) {
									case true: macro {
										var lm = getLineMetric(glyph, charData.fontData);
										if (line.desc != lm.desc) y += (line.base - lm.base);
									}
									default: macro {
										// TODO: baseline for simplefont
									}
								}}
							}
							setCharcode(glyph, charcode, charData);
							setSize(glyph, charData);
							${switch (glyphStyleHasMeta.packed) {
								case true: macro x += kerningOffset(prev_glyph, glyph, charData.fontData.kerning);
								default: macro {}
							}}
							setPosition(glyph, charData, x, y);
							
//TODO
							if (glyph.x + ${switch(glyphStyleHasMeta.packed) {case true: macro glyph.w; default: macro glyph.width;}} >= line.x)  {
								if (glyph.x < line.maxX)	{
									_buffer.addElement(glyph);
									line.visibleTo ++;
								}
							}
							else {
								line.visibleFrom ++;
								line.visibleTo ++;
							}

							x += nextGlyphOffset(glyph, charData);

							prev_glyph = glyph;
						}
						else ret = false;
					});

					line.fullWidth = x - line.x - line.xOffset;
					
					// sets new line-metrics
					${switch (glyphStyleHasMeta.packed) {
						case true: macro {
							if (setNewLineMetrics && prev_glyph != null) {
								var lm = getLineMetric(prev_glyph, charData.fontData);
								line.asc = lm.asc;
								line.desc = lm.desc;
								line.base = lm.base;
								trace("line metric:", line.asc, line.desc, line.base);
							}
						}
						default: macro {}
					}}
					
					return (ret) ? x : null;
				}

				public function lineDeleteChar(line:Line<$styleType>, position:Int = 0)
				{
					if (position >= line.visibleFrom && position < line.visibleTo) {
						removeGlyph(line.glyphes[position]);
					}
					
					_lineDeleteCharsOffset(line, position, position + 1);
					
					if (position < line.visibleFrom) {
						line.visibleFrom--; line.visibleTo--;
					} 
					else if (position < line.visibleTo) {
						line.visibleTo--;
					}
					
					line.glyphes.splice(position, 1);
				}
				
				public function lineDeleteChars(line:Line<$styleType>, from:Int = 0, to:Null<Int> = null)
				{
					if (to == null) to = line.glyphes.length;
					
					for (i in ((from < line.visibleFrom) ? line.visibleFrom : from)...((to < line.visibleTo) ? to : line.visibleTo)) {
						removeGlyph(line.glyphes[i]);
					}
					
					_lineDeleteCharsOffset(line, from, to);
					
					if (from < line.visibleFrom) {
						line.visibleFrom = (to < line.visibleFrom) ? line.visibleFrom - to + from : from;
						line.visibleTo = (to < line.visibleTo) ? line.visibleTo - to + from : from;
					}
					else if (from < line.visibleTo) {
						line.visibleTo = (to < line.visibleTo) ? line.visibleTo - to + from : from;
					}
					
					line.glyphes.splice(from, to - from);
				}
				
				inline function _lineDeleteCharsOffset(line:Line<$styleType>, from:Int, to:Int)
				{
					if (to < line.glyphes.length) {
						var charData = getCharData(line.glyphes[to].char);
						var offset:Float = 0.0;
						if (from == 0) offset = line.x + line.xOffset - leftGlyphPos(line.glyphes[to], charData);
						else {
							offset = rightGlyphPos(line.glyphes[from-1], getCharData(line.glyphes[from-1].char)) - leftGlyphPos(line.glyphes[to], charData);
							${switch (glyphStyleHasMeta.packed) {
								case true: macro offset -= kerningOffset(line.glyphes[from-1], line.glyphes[to], charData.fontData.kerning);
								default: macro {}
							}}
						}
						if (line.updateFrom > from) line.updateFrom = from;
						line.updateTo = line.glyphes.length - to + from;
						_setLinePositionOffset(line, offset, to);
					}
					else { // delete from end
						if ( line.updateFrom >= line.glyphes.length - to + from ) {
							line.updateFrom = 0x1000000;
							line.updateTo = 0;
						}
						else if ( line.updateTo > line.glyphes.length - to + from) {
							line.updateTo = line.glyphes.length - to + from;
						}				
					}
				}
				
				// ------------- update line ---------------------
				
				public function updateLine(line:Line<$styleType>, from:Null<Int> = null, to:Null<Int> = null)
				{
					if (from != null) line.updateFrom = from;
					if (to != null) line.updateTo = to;
					
					trace("visibleFrom: " + line.visibleFrom+ "-" +line.visibleTo);
					trace("updateFrom : " +  line.updateFrom + "-" +line.updateTo);
					if (line.updateTo > 0 )
					{
						if (line.visibleFrom > line.updateFrom) line.updateFrom = line.visibleFrom;
						if (line.visibleTo < line.updateTo) line.updateTo = line.visibleTo;
						trace("update from " + line.updateFrom + " to " +line.updateTo);
						
						for (i in line.updateFrom...line.updateTo) updateGlyph(line.glyphes[i]);

						line.updateFrom = 0x1000000;
						line.updateTo = 0;
					} else trace("nothing to update");
				}
			
			} // end class

			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
