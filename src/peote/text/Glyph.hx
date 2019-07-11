package peote.text;

#if !macro
@:genericBuild(peote.text.Glyph.GlyphMacro.build())
class Glyph<T,U> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class GlyphMacro
{
	public static var cache = new Map<String, Bool>();
	
	static public function build()
	{	
		switch (Context.getLocalType()) {
			case TInst(_, [t,u]):
				switch (t) {
					case TInst(n, []):
						var font = n.get();
						if (font.name != "Gl3Font") // TODO -> other font-types!
							Context.error("Type for Font has to be Gl3Font or ...", Context.currentPos());
						var fontSuperName:String = null;
						var fontSuperModule:String = null;
						var s = font;
						while (s.superClass != null) {
							s = s.superClass.t.get(); trace("->" + s.name);
							fontSuperName = s.name;
							fontSuperModule = s.module;
						}
						switch (u) {
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
									"Glyph",  font.pack, font.module, font.name, fontSuperModule, fontSuperName, TypeTools.toComplexType(t),
									style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(u)
								);
					
							case t: Context.error("Type for GlyphStyle expected", Context.currentPos());
						}
					case t: Context.error("Type for Font expected", Context.currentPos());
				}
			case t: Context.error("Type for Font expected", Context.currentPos());
		}
		return null;
	}
	
	static public function buildClass(
		className:String, fontPack:Array<String>, fontModule:String, fontName:String, fontSuperModule:String, fontSuperName:String, fontType:ComplexType,
		stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType):ComplexType
	{		
		className += "_" + fontName + "_" + styleName;
		var classPackage = Context.getLocalClass().get().pack;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var fontField:Array<String>;
			if (fontSuperName == null) fontField = fontModule.split(".").concat([fontSuperName]);
			else fontField = fontSuperModule.split(".").concat([fontSuperName]);
			
			var styleField:Array<String>;
			if (styleSuperName == null) styleField = styleModule.split(".").concat([styleSuperName]);
			else styleField = styleSuperModule.split(".").concat([styleSuperName]);
			
			#if peoteview_debug_macro
			trace('generating Class: '+classPackage.concat([className]).join('.'));	
			
			trace("ClassName:"+className);           // FontProgram_Gl3Font_GlypStyle
			trace("classPackage:" + classPackage);   // [peote,text]	
			
			trace("FontPackage:" + fontPack);  // [peote,text]
			trace("FontModule:" + fontModule); // peote.text.Gl3Font
			trace("FontName:" + fontName);     // Gl3Font			
			trace("FontType:" + fontType);     // TPath(...)
			trace("FontField:" + fontField);
			
			trace("StylePackage:" + stylePack);  // [peote.text]
			trace("StyleModule:" + styleModule); // peote.text.GlyphStyle
			trace("StyleName:" + styleName);     // GlyphStyle			
			trace("StyleType:" + styleType);     // TPath(...)
			trace("StyleField:" + styleField);
			#end
			
			// parse GlyphStyle fields
			var style_fields = switch Context.getType(styleModule)
				{	case TInst(s,_): s.get();
					default: throw "error: can not parse glyphstyle";
				}
			var hasColor = false;
			var hasWidth = false;
			var hasHeight = false;
			for (field in style_fields.fields.get()) {
				switch (field.name) {
					case "color": hasColor = true;
					case "width": hasWidth = true;
					case "height": hasHeight = true;
				}
			}
			
			var c = macro
// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className implements peote.view.Element
{
	public var charcode:Int=0; // TODO: get/set to change the Tile at unicode-range

	@posX public var x:Int=0;
	@posY public var y:Int = 0;
	
	@sizeX @const public var w:Float=16.0;
	@sizeY @const public var h:Float=16.0;
	
	@color public var color:peote.view.Color;
	
	public function new(charcode:Int, x:Int, y:Int) 
	{
		this.charcode = charcode;
		this.x = x;
		this.y = y;
	}
	
	public static function setGlobalStyle(program:peote.view.Program, style:peote.text.Gl3FontStyle) {
		// inject global fontsize and color into shader
		program.setFormula("w", Std.string(style.width));
		program.setFormula("h", Std.string(style.height));
		program.setColorFormula(Std.string(style.color.toGLSL()));
	}
	
}


// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
			
			// add fields depending on GlyphStyle fields
			if (fontName == "Gl3Font") // TODO: other font-types that use texture-packing
			{
				c.fields.push({
					name:  "tx",
					meta:  [{name:"texX", params:[], pos:Context.currentPos()}],
					access:  [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "ty",
					meta:  [{name:"texY", params:[], pos:Context.currentPos()}],
					access:  [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "tw",
					meta:  [{name:"texW", params:[], pos:Context.currentPos()}],
					access:  [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "th",
					meta:  [{name:"texH", params:[], pos:Context.currentPos()}],
					access:  [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
			}

			
			//Context.defineModule(classPackage.concat([className]).join('.'),[c],Context.getLocalImports());
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
			//Context.defineType(c);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end

/*package peote.text;

import peote.view.Element;
import peote.view.Program;
import peote.view.Color;


class Glyph implements Element
{
	public var charcode:Int=0; // TODO: get/set to change the Tile at unicode-range

	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX @const public var w:Float=16.0;
	@sizeY @const public var h:Float=16.0;
	
	
	public function new(charcode:Int, x:Int, y:Int) 
	{
		this.charcode = charcode;
		this.x = x;
		this.y = y;
	}
	
	public static function setGlobalStyle(program:Program, style:GlyphStyle) {
		// inject global fontsize and color into shader
		program.setFormula("w", '${style.width}');
		program.setFormula("h", '${style.height}');
		program.setColorFormula('${style.color.toGLSL()}');
	}
	
}
*/