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
			
			// -------------------------------------------------------------------------------------------
			var c = macro		

			class $className extends peote.view.Program
			{
				public var font:peote.text.Gl3Font; // TODO peote.text.Font<$styleType>
				public var fontStyle:$styleType;
				
				var _buffer:peote.view.Buffer<$glyphType>;
					
				//public function new(font:$fontType, fontStyle:peote.text.Gl3FontStyle)
				public function new(font:peote.text.Gl3Font, fontStyle:$styleType)
				{
					this.font = font;
					_buffer = new peote.view.Buffer<$glyphType>(100);
					super(_buffer);	
					
					this.fontStyle = fontStyle;
					setFontStyle(fontStyle); // inject global fontsize and color into shader -> GENERATED
				}
				
				public inline function add(glyph:$glyphType, charcode:Int, x:Int, y:Int, glyphStyle:$styleType = null):Void {
					glyph.x = x;
					glyph.y = y;
					glyph.setStyle((glyphStyle != null) ? glyphStyle : fontStyle);
					setCharcode(glyph, charcode);  // -> GENERATED					
					_buffer.addElement(glyph);
				}
								
				public inline function remove(glyph:$glyphType):Void {
					_buffer.removeElement(glyph);
				}
								
				public inline function update(glyph:$glyphType):Void {
					_buffer.updateElement(glyph);
				}
				
			}

			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			var glyphStyleHasField = Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			var glyphStyleHasMeta = Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			
			if (glyphStyleHasMeta.gl3Font)
			{
				var exprBlock = new Array<Expr>();
				
				if (glyphStyleHasField.local_width) 
					exprBlock.push( macro glyph.w = metric.width * glyph.width );
				else if (glyphStyleHasField.width) 
					exprBlock.push( macro glyph.w = metric.width * fontStyle.width );
				else
					exprBlock.push( macro glyph.w = metric.width * 20 );
					//exprBlock.push( macro glyph.w = metric.width * font.width );
				
				if (glyphStyleHasField.local_height)
				    exprBlock.push( macro glyph.h = metric.height * glyph.height );
				else if (glyphStyleHasField.height)
					exprBlock.push( macro glyph.h = metric.height * fontStyle.height );
				else
					exprBlock.push( macro glyph.h = metric.height * 20 );
					//exprBlock.push( macro glyph.h = metric.height * fontStyle.height );
								
				// ------ generate Function setCharcode -------
				c.fields.push({
					name: "setCharcode",
					access: [Access.APublic, Access.AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args:[ {name:"glyph", type:macro:$glyphType},
						       {name:"charcode", type:macro:Int},
						],
						expr: macro {
							var range = font.getRange(charcode);
							if (range != null) {
								glyph.unit = range.unit;
								glyph.slot = range.slot;								
								var metric = range.fontData.getMetric(charcode);								
								if (metric != null) {
									//trace("glyph"+charcode, range.unit, range.slot, metric);								
									glyph.tx = metric.u;
									glyph.ty = metric.v;
									glyph.tw = metric.w;
									glyph.th = metric.h;							
									$b{ exprBlock }
								}
							}
						},
						ret: null
					})
				});
								
				// ------ generate Function setFontStyle -------
				
				exprBlock = new Array<Expr>();
				if (glyphStyleHasField.local_color) 
					exprBlock.push( macro super.setColorFormula("color * smoothstep( "+bold+" - "+sharp+" * fwidth(TEX.r), "+bold+" + "+sharp+" * fwidth(TEX.r), TEX.r)") );
				else if (glyphStyleHasField.color)
					exprBlock.push( macro super.setColorFormula(Std.string(fontStyle.color.toGLSL()) + " * smoothstep( "+bold+" - "+sharp+" * fwidth(TEX.r), "+bold+" + "+sharp+" * fwidth(TEX.r), TEX.r)") );
				else
					exprBlock.push( macro super.setColorFormula("smoothstep( "+bold+" - "+sharp+" * fwidth(TEX.r), "+bold+" + "+sharp+" * fwidth(TEX.r), TEX.r)") );
					//exprBlock.push( macro super.setColorFormula(Std.string(font.color.toGLSL()) + " * smoothstep( "+bold+" - "+sharp+" * fwidth(TEX.r), "+bold+" + "+sharp+" * fwidth(TEX.r), TEX.r)") );
				
				c.fields.push({
					name: "setFontStyle",
					access: [Access.APublic],
					pos: Context.currentPos(),
					kind: FFun({
						args:[ {name:"fontStyle", type:macro:$styleType}
						],
						expr: macro {
							this.fontStyle = fontStyle;
												
							var bold = peote.view.utils.Util.toFloatString(0.5);
							var sharp = peote.view.utils.Util.toFloatString(0.5);
							
							super.setMultiTexture(font.textureCache.textures, "TEX");
							
							$b{ exprBlock }
						},
						ret: null
					})
				});
			
			}

			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
