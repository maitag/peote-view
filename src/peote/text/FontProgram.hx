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
			
			// -------------------------------------------------------------------------------------------
			var c = macro		

			class $className extends peote.view.Program
			{
				public var font:peote.text.Font<$styleType>; // TODO peote.text.Font<$styleType>
				public var fontStyle:$styleType;
				
				public var penX:Float = 0;
				public var penY:Float = 0;
				
				var prev_charcode = -1;
				
				var _buffer:peote.view.Buffer<$glyphType>;
				
				public function new(font:peote.text.Font<$styleType>, fontStyle:$styleType)
				{
					_buffer = new peote.view.Buffer<$glyphType>(100);
					super(_buffer);	
					
					setFont(font);
					setFontStyle(fontStyle);
				}
				
				public inline function addGlyph(glyph:$glyphType, charcode:Int, x:Null<Float>=null, y:Null<Float>=null, glyphStyle:$styleType = null):Bool {
					glyph.setStyle((glyphStyle != null) ? glyphStyle : fontStyle);
					if (setCharcode(glyph, charcode, x, y)) {
						_buffer.addElement(glyph);
						return true;
					} else return false;
				}
								
				public inline function removeGlyph(glyph:$glyphType):Void {
					_buffer.removeElement(glyph);
				}
								
				public inline function updateGlyph(glyph:$glyphType):Void {
					_buffer.updateElement(glyph);
				}
				
				// -------------------------------------------------
								
				inline function setXW(glyph:$glyphType, charcode:Int, x:Null<Float>, width:Float, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric):Void {
					${switch (glyphStyleHasMeta.packed)
					{	case true: macro // ------- Gl3Font -------
						{
							glyph.w = metric.width * width;
							if (x == null) {
								glyph.x = penX + metric.left * width;
								if (font.kerning && prev_charcode != -1) { // KERNING
									penX += fontData.kerning[prev_charcode][charcode] * width;
								}
								prev_charcode = charcode;
								penX += metric.advance * width;
							}
						}
						default: macro {}
					}}
				}
								
				inline function setYW(glyph:$glyphType, charcode:Int, y:Null<Float>, height:Float, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric):Void {
					${switch (glyphStyleHasMeta.packed)
					{	case true: macro // ------- Gl3Font -------
						{
							glyph.h = metric.height * height;
							if (y == null) {
								glyph.y = penY + (fontData.height - metric.top) * height;
							}					
						}
						default: macro {}
					}}
				}
				
				// -------------------------------------------------
				
				inline function setXWsimple(glyph:$glyphType, charcode:Int, x:Null<Float>, width:Float):Void {
					${switch (glyphStyleHasField.local_width) {
						case true: macro {
							glyph.width = width;
						}
						default: macro {}
					}}
					if (x == null) {
						glyph.x = penX;
						penX += width;
					}					
				}
								
				inline function setYWsimple(glyph:$glyphType, charcode:Int, y:Null<Float>, height:Float):Void {
					${switch (glyphStyleHasField.local_height) {
						case true: macro {
							glyph.height = height;
						}
						default: macro {}
					}}
					if (y == null) {
						glyph.y = penY;
					}					
				}
								
				public inline function setCharcode(glyph:$glyphType, charcode:Int, x:Null<Float>=null, y:Null<Float>=null):Bool
				{
					if (x != null) glyph.x = x;
					if (y != null) glyph.y = y;
					
					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
							var range = font.getRange(charcode);
							var metric:peote.text.Gl3FontData.Metric = null;
							var fontData:Gl3FontData = null;
							
							${switch (glyphStyleHasMeta.multiTexture || glyphStyleHasMeta.multiSlot) {
								case true: macro {
									if (range != null) {
										${switch (glyphStyleHasMeta.multiTexture) {
											case true: macro glyph.unit = range.unit;
											default: macro {}
										}}
										${switch (glyphStyleHasMeta.multiSlot) {
											case true: macro glyph.slot = range.slot;
											default: macro {}
										}}
										fontData = range.fontData;
										metric = fontData.getMetric(charcode);
									}
								}
								default: macro {
									fontData = range;
									metric = fontData.getMetric(charcode);
								}
							}}
							
							if (metric != null) {
								glyph.tx = metric.u;
								glyph.ty = metric.v;
								glyph.tw = metric.w;
								glyph.th = metric.h;
								${switch (glyphStyleHasField.local_width) {
									case true: macro setXW(glyph, charcode, x, glyph.width, fontData, metric);
									default: switch (glyphStyleHasField.width) {
										case true: macro setXW(glyph, charcode, x, fontStyle.width, fontData, metric);
										default: macro setXW(glyph, charcode, x, font.fontConfig.width, fontData, metric);
								}}}
								${switch (glyphStyleHasField.local_height) {
									case true: macro setYW(glyph, charcode, y, glyph.height, fontData, metric);
									default: switch (glyphStyleHasField.height) {
										case true: macro setYW(glyph, charcode, y, fontStyle.height, fontData, metric);
										default: macro setYW(glyph, charcode, y, font.fontConfig.height, fontData, metric);
								}}}
								return true;
							}
							else return false;
							
						}
						default: macro // ------- simple font -------
						{
							var range = font.getRange(charcode);
							if (range != null)
							{
								${switch (glyphStyleHasMeta.multiTexture) {
									case true: macro glyph.unit = range.unit;
									default: macro {}
								}}
								${switch (glyphStyleHasMeta.multiSlot) {
									case true: macro glyph.slot = range.slot;
									default: macro {}
								}}
					
								glyph.tile = charcode-range.min;
								
								${switch (glyphStyleHasField.local_width) {
									case true: macro setXWsimple(glyph, charcode, x, glyph.width);
									default: switch (glyphStyleHasField.width) {
										case true: macro setXWsimple(glyph, charcode, x, fontStyle.width);
										default: macro setXWsimple(glyph, charcode, x, font.fontConfig.width);
								}}}
								${switch (glyphStyleHasField.local_height) {
									case true: macro setYWsimple(glyph, charcode, y, glyph.height);
									default: switch (glyphStyleHasField.height) {
										case true: macro setYWsimple(glyph, charcode, y, fontStyle.height);
										default: macro setYWsimple(glyph, charcode, y, font.fontConfig.height);
								}}}
								
								return true;
							}
							else return false;
						}
					}}
				
				}

				
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
							default: macro color = Std.string(font.fontConfig.color.toGLSL());
					}}}
					
					// check distancefield-rendering
					if (font.fontConfig.distancefield) {
						var bold = peote.view.utils.Util.toFloatString(0.5); // 4.8 -> bold
						var sharp = peote.view.utils.Util.toFloatString(0.5); // TODO
						setColorFormula(color + " * smoothstep( "+bold+" - "+sharp+" * fwidth(TEX.r), "+bold+" + "+sharp+" * fwidth(TEX.r), TEX.r)");							
					}
					else {
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
					

					${switch (glyphStyleHasMeta.packed)
					{
						case true: macro // ------- Gl3Font -------
						{
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
										macro setFormula("width", peote.view.utils.Util.toFloatString(font.fontConfig.width));
							}}}
							${switch (glyphStyleHasField.local_height) {
								case true: macro {}
								default: switch (glyphStyleHasField.height) {
									case true:
										macro setFormula("height", peote.view.utils.Util.toFloatString(fontStyle.height));
									default:
										macro setFormula("height", peote.view.utils.Util.toFloatString(font.fontConfig.height));
							}}}
							
							// mixing alpha while use of zIndex
							${switch (glyphStyleHasField.zIndex) {
								case true: macro {discardAtAlpha(0.5);}
								default: macro {}
							}}
							
							
						}
						
					}}
					
					updateTextures();
				}
				
				public function addLine(line:Line<$styleType>, chars:String, x:Float=0, y:Float=0, glyphStyle:$styleType = null)
				{
					penX = line.x = x;
					penY = line.y = y;
					haxe.Utf8.iter(chars, function(charcode)
					{
						var glyph = new Glyph<$styleType>();
						line.glyphes.push(glyph);
						addGlyph(glyph, charcode, glyphStyle);					
					});
				}
				
				public function insertIntoLine(line:Line<$styleType>, chars:String, xPosition:Int=0, yPosition:Int=0) {
					
				}
			
				public function updateLine(line:Line<$styleType>) {
					for (glyph in line.glyphes) {
						updateGlyph(glyph);
					}
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
