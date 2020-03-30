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
				public var x:Float = 0.0;
				public var y:Float = 0.0;
				public var xOffset:Float = 0.0;
				public var yOffset:Float = 0.0;				
				public var maxX:Float = 0xffff;
				public var maxY:Float = 0xffff;
				
				@:allow(peote.text) public var fullWidth(default, null):Float = 0.0;
				@:allow(peote.text) public var fullHeight(default, null):Float = 0.0;
				
				public var asc:Float = 0.0;
				public var desc:Float = 0.0; // height
				public var base:Float = 0.0;  // <- all aligns here
				
				
				//public var xDirection:Int = 1;  // <- TODO: better later with LineStyle !!!
				//public var yDirection:Int = 0;
				public var length(get, never):Int; // number of lines
				public inline function get_length():Int return glyphes.length;
				
				
				// TODO: optimize for neko/hl/cpp
				var glyphes = new Array<$glyphType>();
				
				public inline function getGlyph(i:Int):$glyphType return glyphes[i];
				@:allow(peote.text) inline function setGlyph(i:Int, glyph:$glyphType) glyphes[i] = glyph;
				@:allow(peote.text) inline function pushGlyph(glyph:$glyphType) glyphes.push(glyph);
				@:allow(peote.text) inline function insertGlyph(pos:Int, glyph:$glyphType) glyphes.insert(pos, glyph);
				
				@:allow(peote.text) inline function splice(pos:Int, len:Int):Array<$glyphType> return glyphes.splice(pos, len);
				@:allow(peote.text) inline function resize(newLength:Int) {
					//TODO HAXE 4 lines.resize(newLength);
					glyphes.splice(newLength, glyphes.length - newLength);
				}
				@:allow(peote.text) inline function append(a:Array<$glyphType>) {
					glyphes = glyphes.concat(a);
				}
				
				@:allow(peote.text) var updateFrom:Int = 0x1000000;
				@:allow(peote.text) var updateTo:Int = 0;
				@:allow(peote.text) public var visibleFrom(default, null):Int = 0;
				@:allow(peote.text) public var visibleTo(default, null):Int = 0;
				
				public function new() {}
			}
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
