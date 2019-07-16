package peote.text;

#if !macro
@:genericBuild(peote.text.Glyph.GlyphMacro.build())
class Glyph<T,U> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

@:publicFields class GlyphStyleHasField {
	var color:Bool;
	var bgColor:Bool;
	var width:Bool;
	var height:Bool;
	var rotation:Bool;
	var bold:Bool;
	var italic:Bool;
	public function new() {}
}

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
	
	static public function parseGlyphStyleFields(styleModule:String):GlyphStyleHasField {
			// parse GlyphStyle fields
			var glyphStyleHasField = new GlyphStyleHasField();
			
			var style_fields = switch Context.getType(styleModule) {
				case TInst(s,_): s.get();
				default: throw "error: can not parse glyphstyle";
			}
			for (field in style_fields.fields.get()) {
				switch (field.name) {
					case "color": glyphStyleHasField.color = true;
					case "bgColor": glyphStyleHasField.bgColor = true;
					case "width": glyphStyleHasField.width = true;
					case "height": glyphStyleHasField.height = true;
					case "rotation": glyphStyleHasField.rotation = true;
					case "bold": glyphStyleHasField.bold = true;
					case "italic": glyphStyleHasField.italic = true;
					default: // todo
				}
			}
			return glyphStyleHasField;
	}
	
	static public function buildClass(
		className:String, fontPack:Array<String>, fontModule:String, fontName:String, fontSuperModule:String, fontSuperName:String, fontType:ComplexType,
		stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType):ComplexType
	{		
		var styleMod = styleModule.split(".").join("_");
			
		className += "__" + fontName + "__" + styleMod;
		if (styleModule.split(".").pop() != styleName) className += ((styleMod != "") ? "_" : "") + styleName;
		
		var classPackage = Context.getLocalClass().get().pack;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var fontField:Array<String>;
			//if (fontSuperName == null) fontField = fontModule.split(".").concat([fontName]);
			//else fontField = fontSuperModule.split(".").concat([fontSuperName]);
			fontField = fontModule.split(".").concat([fontName]);
			
			var styleField:Array<String>;
			//if (styleSuperName == null) styleField = styleModule.split(".").concat([styleName]);
			//else styleField = styleSuperModule.split(".").concat([styleSuperName]);
			styleField = styleModule.split(".").concat([styleName]);
			
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
						
			var c = macro
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------

			class $className implements peote.view.Element
			{
				public var charcode:Int=0;

				@posX public var x:Int=0;
				@posY public var y:Int = 0;
				
				// TODO: generate 

				//@sizeX @const public var w:Float=16.0;
				//@sizeY @const public var h:Float=16.0;
				@texUnit public var unit:Int = 0;
				@texSlot public var slot:Int = 0;
				
				@color public var color:peote.view.Color;
				
				
				
				public function new(charcode:Int, x:Int, y:Int) 
				{
					this.charcode = charcode;
					this.x = x;
					this.y = y;
				}
				
/*				public static function setGlobalStyle(program:peote.view.Program, style:peote.text.Gl3FontStyle) {
					// inject global fontsize and color into shader
					program.setFormula("w", Std.string(style.width));
					program.setFormula("h", Std.string(style.height));
					program.setColorFormula(Std.string(style.color.toGLSL()));
				}
*/				
			}
			
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			var glyphStyleHasField = parseGlyphStyleFields(styleModule+"."+styleName);
			trace("GLYPH:", glyphStyleHasField);
			// TODO add fields depending on GlyphStyle fields
			if (glyphStyleHasField.width) {
				
			}
			
			// add fields depending on type of font
			if (fontName == "Gl3Font") // TODO: other font-types that use texture-packing
			{
				c.fields.push({
					name:  "w",
					meta:  [{name:"sizeX", params:[], pos:Context.currentPos()}],
					//access:  [Access.APrivate],
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "h",
					meta:  [{name:"sizeY", params:[], pos:Context.currentPos()}],
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "tx",
					meta:  [{name:"texX", params:[], pos:Context.currentPos()}],
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "ty",
					meta:  [{name:"texY", params:[], pos:Context.currentPos()}],
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "tw",
					meta:  [{name:"texW", params:[], pos:Context.currentPos()}],
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "th",
					meta:  [{name:"texH", params:[], pos:Context.currentPos()}],
					access:  [Access.APublic],
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
