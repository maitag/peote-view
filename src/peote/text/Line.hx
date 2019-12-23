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
				public var width:Float = 0.0;
				public var height:Float = 0.0; // TODO:height from greatest Glyphstyle
				
				// TODO
				//public var baseline:Float = 0.0;

				public var xDirection:Int = 1;
				public var yDirection:Int = 0;
				
				
				// TODO: optimize here for js/neko/cpp
				public var glyphes = new Array<$glyphType>();
				public var chars = new Array<Int>();
				
				@:allow(peote.text) var updatePosFrom:Int = 0x1000000;
				@:allow(peote.text) var updateStyleFrom:Int = 0x1000000;
				@:allow(peote.text) var updateStyleTo:Int = 0;
				@:allow(peote.text) var posHasChanged:Bool = false;
				
				public function new() 
				{
				}
				
				public inline function setStyle(glyphStyle:$styleType, from:Int = 0, to:Null<Int> = null)
				{
					if (to == null) to = glyphes.length;
					
					if (from < updateStyleFrom) updateStyleFrom = from;
					if (to > updateStyleTo) updateStyleTo = to;
					
					for (i in from...to) glyphes[i].setStyle(glyphStyle);
				}
						
				public inline function setPosition(xNew:Float, yNew:Float)
				{
					setPositionOffset(xNew - x, yNew - y, 0, glyphes.length); 
					x = xNew;
					y = yNew;
					updatePosFrom = 0;
					posHasChanged = true;
				}
				
				@:allow(peote.text) inline function setPositionOffset(deltaX:Float, deltaY:Float, from:Int, to:Int)
				{
					if (deltaX == 0)
						for (i in from...to) glyphes[i].y += deltaY;
					else if (deltaY == 0)
						for (i in from...to) glyphes[i].x += deltaX;
					else 
						for (i in from...to) {
							glyphes[i].x += deltaX;
							glyphes[i].y += deltaY;
						}
				}
						
						

				
			}
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
