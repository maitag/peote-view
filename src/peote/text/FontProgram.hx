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
						var g = n.get();
						var superName:String = null;
						var superModule:String = null;
						var s = g;
						while (s.superClass != null) {
							s = s.superClass.t.get(); //trace("->" + s.name);
							superName = s.name;
							superModule = s.module;
						}			
						return buildClass("FontProgram",  g.pack, g.module, g.name, superModule, superName, TypeTools.toComplexType(t) );
					case t: Context.error("Glyph-Class expected", Context.currentPos());
				}
			case t: Context.error("Glyph-Class expected", Context.currentPos());
		}
		return null;
	}
	
	static public function buildClass(className:String, glyphPack:Array<String>, glyphModule:String, glyphName:String, superModule:String, superName:String, glyphType:ComplexType):ComplexType
	{		
		var fontStyleNames = glyphName.split("__");
		fontStyleNames.shift();
		
		className += "_" + fontStyleNames.join("_");
		var classPackage = Context.getLocalClass().get().pack;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var glyphField:Array<String>;
			if (superName == null) glyphField = glyphModule.split(".").concat([glyphName]);
			else glyphField = superModule.split(".").concat([superName]);
			
			var fontName = "Gl3Font";     // TODO -> default
			var fontModule = "peote.text";
			if (fontStyleNames.length > 0) fontName = fontStyleNames.shift();
			fontModule += "." + fontName;
			var fontType = TypeTools.toComplexType(Context.getType(fontModule));
			var fontField = fontModule.split(".").concat([fontName]); // TODO: super-class

			var styleName = "GlyphStyle"; // TODO -> default
			var styleModule = "peote.text";
			if (fontStyleNames.length > 0) {
				var s = fontStyleNames.shift().split("_");
				styleName = s.pop();
				styleModule = s.join(".");
			}
			styleModule += "." + styleName;
			var styleType = TypeTools.toComplexType(Context.getType(styleModule));
			var styleField = styleModule.split(".").concat([styleName]); // TODO: super-class
			
			#if peoteview_debug_macro
			trace('generating Class: '+classPackage.concat([className]).join('.'));	
			
			trace("ClassName:"+className);           // FontProgram_Glyph_Gl3Font_GlyphStyle
			trace("classPackage:" + classPackage);   // [peote,text]	
			
			trace("GlyphPackage:" + glyphPack);  // [peote,text]
			trace("GlyphModule:" + glyphModule); // peote.text.Glyph_Gl3Font_GlyphStyle
			trace("GlyphName:" + glyphName);     // Glyph_Gl3Font_GlyphStyle
			trace("GlyphType:" + glyphType);     // TPath(...)
			trace("GlyphField:" + glyphField);   // [peote,text,Glyph_Gl3Font_GlyphStyle,Glyph_Gl3Font_GlyphStyle]		

			trace("FontModule:" + fontModule); // peote.text.Gl3Font
			trace("FontName:" + fontName);     // Gl3Font			
			trace("FontType:" + fontType);     // TPath(...)
			trace("FontField:" + fontField);   // [peote,text,Gl3Font,Gl3Font]
			
			trace("StyleModule:" + styleModule); // peote.text.GlyphStyle
			trace("StyleName:" + styleName);     // GlyphStyle			
			trace("StyleType:" + styleType);     // TPath(...)
			trace("StyleField:" + styleField);   // [peote,text,GlyphStyle,GlyphStyle]
			#end
			
			var c = macro		
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------

			class $className extends peote.view.Program
			{
				public var font:$fontType;
				public var glyphStyle:peote.text.Gl3FontStyle;
				
				var _buffer:peote.view.Buffer<$glyphType>;
					
				public function new(font:$fontType, glyphStyle:peote.text.Gl3FontStyle)
				{
					this.font = font;
					this.glyphStyle = glyphStyle;

					_buffer = new peote.view.Buffer<$glyphType>(100);
					
					super(_buffer);
					
/*					if (style.width == null) {
						// todo use default from Font
						style.width = 16.0;
					}
					if (style.height == null) {
						// todo use default from Font
						style.height = 16.0;
					}
*/					
					
					
					// inject global fontsize and color into shader
					//$p{glyphField}.setGlobalStyle(this, style);
					setGlobalStyle(glyphStyle);
					
				}
				
				public function setGlobalStyle(glyphStyle:peote.text.Gl3FontStyle) {
					// inject global fontsize and color into shader
					//program.setFormula("w", Std.string(glyphStyle.width));
					//program.setFormula("h", Std.string(glyphStyle.height));
					//program.setColorFormula(Std.string(style.color.toGLSL()));
					
					//program.setTexture(texture, "TEX");
					
					var bold = peote.view.utils.Util.toFloatString(0.5);
					var sharp = peote.view.utils.Util.toFloatString(0.5);
					
					// TODO
					super.setMultiTexture(font.textureCache.textures, "TEX");
					super.setColorFormula("color * smoothstep( "+bold+" - "+sharp+" * fwidth(TEX.r), "+bold+" + "+sharp+" * fwidth(TEX.r), TEX.r)");
				}
				
				public function add(glyph:$glyphType):Void {
					setCharGl3Font(glyph);
					_buffer.addElement(glyph);
				}
				public function update(glyph:$glyphType):Void {
					setCharGl3Font(glyph);
					_buffer.updateElement(glyph);
				}
				public function remove(glyph:$glyphType):Void {
					_buffer.removeElement(glyph);
				}
				
				// TODO: w, h, and text-coords for packed glyphes (versus tiled and not-packed ones)
				public function setCharGl3Font(glyph:$glyphType):Void {
					
					var range = font.getRange(glyph.charcode);
					var metric = range.fontData.getMetric(glyph.charcode);
					
					glyph.unit = range.unit;
					glyph.slot = range.slot;
					
					glyph.w  = metric.width  * 16.0;
					glyph.h  = metric.height * 16.0;
					glyph.tx = metric.u;
					glyph.ty = metric.v;
					glyph.tw = metric.w;
					glyph.th = metric.h;
					
					trace("glyph"+glyph.charcode, range.unit, range.slot, metric);
				}
				
			}

			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			var glyphStyleHasField = Glyph.GlyphMacro.parseGlyphStyleFields(styleModule);
			trace("FONTPROGRAM:", glyphStyleHasField);
			// TODO
			if (glyphStyleHasField.width) {
				
			}
			
			

			//Context.defineModule(classPackage.concat([className]).join('.'),[c],Context.getLocalImports());
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
			//Context.defineType(c);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
