package peote.text;

#if !macro
@:genericBuild(peote.text.Page.PageMacro.build())
class Page<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class PageMacro
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
							"Page", style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(t)
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
			
			var lineType = Line.LineMacro.buildClass("Line", stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			
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
								
				// TODO: optimize later in putting some properties into outside wrapper of line or textwidget
				public var maxX:Float = 0xffff;
				public var maxY:Float = 0xffff;
				
				@:allow(peote.text) public var fullWidth(default, null):Float = 0.0;
				@:allow(peote.text) public var fullHeight(default, null):Float = 0.0;
				
				public var asc:Float = 0.0;
				public var desc:Float = 0.0; // height
				public var base:Float = 0.0;  // <- all aligns here
				
				
				//public var xDirection:Int = 1;  // <- TODO: better later with LineStyle !!!
				//public var yDirection:Int = 0;
				
				
				// TODO: optimize here for js/neko/cpp
				public var lines = new Array<$lineType>();
				public inline function getLine(i:Int):$lineType return lines[i];
				@:allow(peote.text) inline function setLine(i:Int, line:$lineType) lines[i] = line;
				
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