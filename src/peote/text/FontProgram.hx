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
		className += "_" + glyphName;
		var classPackage = Context.getLocalClass().get().pack;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var glyphField:Array<String>;
			if (superName == null) glyphField = glyphModule.split(".").concat([glyphName]);
			else glyphField = superModule.split(".").concat([superName]);
			
			var fontStyleNames = glyphName.split("_");

			var fontName = "Gl3Font";     // TODO -> default
			var fontPack = ["peote","text"];
			if (fontStyleNames.length > 0) fontName = fontStyleNames[1];
			var fontModule = fontPack.concat([fontName]).join(".");
			var fontType = TypeTools.toComplexType(Context.getType(fontModule));
			var fontField = fontModule.split(".").concat([fontName]); // TODO: super-class

			var styleName = "GlyphStyle"; // TODO -> default
			var stylePack = ["peote","text"];
			if (fontStyleNames.length > 1) styleName = fontStyleNames[2];
			var styleModule = stylePack.concat([styleName]).join(".");
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

			trace("FontPackage:" + fontPack);  // [peote,text]
			trace("FontModule:" + fontModule); // peote.text.Gl3Font
			trace("FontName:" + fontName);     // Gl3Font			
			trace("FontType:" + fontType);     // TPath(...)
			trace("FontField:" + fontField);   // [peote,text,Gl3Font,Gl3Font]
			
			trace("StylePackage:" + stylePack);  // [peote.text]
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
	public var style:peote.text.Gl3FontStyle;
	
	var _buffer:peote.view.Buffer<$glyphType>;
		
	public function new(font:$fontType, glyphStyle:peote.text.Gl3FontStyle)
	{
		_buffer = new peote.view.Buffer<$glyphType>(100);		
		super(_buffer);
		
		style = glyphStyle;
		if (style.width == null) {
			// todo use default from Font
			style.width = 16.0;
		}
		if (style.height == null) {
			// todo use default from Font
			style.height = 16.0;
		}
		
		
		this.font = font;
		
		// inject global fontsize and color into shader
		$p{glyphField}.setGlobalStyle(this, style);
		
	}
	
	public function add(glyph:$glyphType):Void {
		_buffer.addElement(glyph);
	}
	public function remove(glyph:$glyphType):Void {
		_buffer.removeElement(glyph);
	}
	
	
}


// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------			
			//Context.defineModule(classPackage.concat([className]).join('.'),[c],Context.getLocalImports());
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
			//Context.defineType(c);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
