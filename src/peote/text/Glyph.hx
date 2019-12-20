package peote.text;

#if !macro
@:genericBuild(peote.text.Glyph.GlyphMacro.build())
class Glyph<T> {}
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
	var weight:Bool;
	var tilt:Bool;
	var zIndex:Bool;
	
	var local_color:Bool;
	var local_bgColor:Bool;
	var local_width:Bool;
	var local_height:Bool;
	var local_rotation:Bool;
	var local_weight:Bool;
	var local_tilt:Bool;
	var local_zIndex:Bool;
	public function new() {}
}

@:publicFields class GlyphStyleHasMeta {
	var packed:Bool;
	var multiSlot:Bool;
	var multiTexture:Bool;
	public function new() {}
}

class GlyphMacro
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
							"Glyph", style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(t)
						);	
					default: Context.error("Type for GlyphStyle expected", Context.currentPos());
				}
			default: Context.error("Type for GlyphStyle expected", Context.currentPos());
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
			for (field in style_fields.fields.get()) {//trace("param",Context.getTypedExpr(field.expr()).expr);
				var local = true;
				var meta = field.meta.get();
				if (meta.length > 0)
					if (meta[0].name == "global") local = false;
					
				switch (field.name) {
					case "color":   glyphStyleHasField.color   = true; if (local) glyphStyleHasField.local_color   = true;
					case "bgColor": glyphStyleHasField.bgColor = true; if (local) glyphStyleHasField.local_bgColor = true;
					case "width":   glyphStyleHasField.width   = true; if (local) glyphStyleHasField.local_width   = true;
					case "height":  glyphStyleHasField.height  = true; if (local) glyphStyleHasField.local_height  = true;
					case "rotation":glyphStyleHasField.rotation= true; if (local) glyphStyleHasField.local_rotation= true;
					case "weight":  glyphStyleHasField.weight  = true; if (local) glyphStyleHasField.local_weight  = true;
					case "tilt":    glyphStyleHasField.tilt    = true; if (local) glyphStyleHasField.local_tilt    = true;
					case "zIndex":  glyphStyleHasField.zIndex  = true; if (local) glyphStyleHasField.local_zIndex  = true;
					default: // todo
				}
				// TODO: store other metas for custom anim and formula stuff
			}
			//trace("--- glyphStyleHasField",glyphStyleHasField);
			return glyphStyleHasField;
	}
	
	static public function parseGlyphStyleMetas(styleModule:String):GlyphStyleHasMeta {
			// parse GlyphStyle metas for font type
			var glyphStyleHasMeta = new GlyphStyleHasMeta();
			
			var style_fields = switch Context.getType(styleModule) {
				case TInst(s,_): s.get();
				default: throw "error: can not parse glyphstyle";
			}
			for (meta in style_fields.meta.get()) {
				switch (meta.name) {
					case "packed": glyphStyleHasMeta.packed = true;
					case "multiSlot":   glyphStyleHasMeta.multiSlot = true;
					case "multiTexture": glyphStyleHasMeta.multiTexture = true;
					default:
				}
			}
			return glyphStyleHasMeta;
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
			
			#if peoteview_debug_macro
			trace('generating Class: '+classPackage.concat([className]).join('.'));	
			
			trace("ClassName:"+className);           // Glyph__peote_text_GlypStyle
			trace("classPackage:" + classPackage);   // [peote,text]	
			
			trace("StylePackage:" + stylePack);  // [peote.text]
			trace("StyleModule:" + styleModule); // peote.text.GlyphStyle
			trace("StyleName:" + styleName);     // GlyphStyle			
			trace("StyleType:" + styleType);     // TPath(...)
			trace("StyleField:" + styleField);   // [peote,text,GlyphStyle,GlyphStyle]
			#end
						
			var glyphStyleHasMeta = parseGlyphStyleMetas(styleModule+"."+styleName); //trace("Glyph - glyphStyleHasMeta:", glyphStyleHasMeta);
			var glyphStyleHasField = parseGlyphStyleFields(styleModule+"."+styleName); //trace("Glyph - glyphStyleHasField:", glyphStyleHasField);

			var exprBlock = new Array<Expr>();
			if (glyphStyleHasField.local_width)  exprBlock.push( macro width = glyphStyle.width );
			if (glyphStyleHasField.local_height) exprBlock.push( macro height= glyphStyle.height );
			if (glyphStyleHasField.local_color)  exprBlock.push( macro color = glyphStyle.color );
			if (glyphStyleHasField.local_zIndex) exprBlock.push( macro zIndex= glyphStyle.zIndex );
			if (glyphStyleHasField.local_rotation) exprBlock.push( macro rotation = glyphStyle.rotation );
			if (glyphStyleHasField.local_weight) exprBlock.push( macro weight = glyphStyle.weight );
			if (glyphStyleHasField.local_tilt) exprBlock.push( macro tilt = glyphStyle.tilt );
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			var c = macro

			class $className implements peote.view.Element
			{
				public function new() {}
				
				public inline function setStyle(glyphStyle: $styleType) {
					$b{ exprBlock }
				}
				
			}
			
			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
						
			c.fields.push({
				name:  "x",
				meta: [{name:"posX", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:Float, macro 0.0),
				pos: Context.currentPos(),
			});
			
			c.fields.push({
				name:  "y",
				meta: [{name:"posY", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:Float, macro 0.0),
				pos: Context.currentPos(),
			});
			
			// TODO
			// to cut of a glyph horizontal - only for non-monospaced!
/*			c.fields.push({
				name:  "txOffset",
				meta: [{name:"texPosX", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:Float, macro 0.0),
				pos: Context.currentPos(),
			});
			c.fields.push({
				name:  "tyOffset",
				meta: [{name:"texPosY", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:Float, macro 0.0),
				pos: Context.currentPos(),
			});
*/			
			// --- add fields depending on unit/slots
			if (glyphStyleHasMeta.multiTexture) c.fields.push({
				name:  "unit",
				meta:  [{name:"texUnit", params:[], pos:Context.currentPos()},
						{name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
				access:  [Access.APrivate],
				kind: FieldType.FVar(macro:Int, macro 0),
				pos: Context.currentPos(),
			});
			if (glyphStyleHasMeta.multiSlot) c.fields.push({
				name:  "slot",
				meta:  [{name:"texSlot", params:[], pos:Context.currentPos()},
						{name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
				access:  [Access.APrivate],
				kind: FieldType.FVar(macro:Int, macro 0),
				pos: Context.currentPos(),
			});
			
			// --- add fields depending on style
			if (glyphStyleHasField.local_color) c.fields.push({
				name:  "color",
				meta:  [{name:"color", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:peote.view.Color, macro 0xffffffff),
				pos: Context.currentPos(),
			});
			
			if (glyphStyleHasField.zIndex) {
				var meta = [{name:"zIndex", params:[], pos:Context.currentPos()}];
				if (!glyphStyleHasField.local_zIndex) meta.push({name:"@const", params:[], pos:Context.currentPos()});
				c.fields.push({
					name:  "zIndex",
					meta:  meta,
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Int, macro 0),
					pos: Context.currentPos(),
				});
			}
			
			if (glyphStyleHasField.rotation) {
				var meta = [{name:"rotation", params:[], pos:Context.currentPos()}];
				if (!glyphStyleHasField.local_rotation) meta.push({name:"@const", params:[], pos:Context.currentPos()});
				c.fields.push({
					name:  "rotation",
					meta:  meta,
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
			}
			
			if (glyphStyleHasField.local_tilt) c.fields.push({
				name:  "tilt",
				meta:  [{name:"custom", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:Float, macro 0.0),
				pos: Context.currentPos(),
			});
			
			if (glyphStyleHasField.local_weight) c.fields.push({
				name:  "weight",
				meta:  [{name:"custom", params:[], pos:Context.currentPos()},
				       {name:"varying", params:[], pos:Context.currentPos()}],
				access:  [Access.APublic],
				kind: FieldType.FVar(macro:Float, macro 0.0),
				pos: Context.currentPos(),
			});
			
			// ------------- add fields depending on font-type and style ------------------
			
			if (glyphStyleHasMeta.packed)
			{			
				if (glyphStyleHasField.local_width) {
					c.fields.push({
						name:  "width",
						access:  [Access.APublic],
						kind: FieldType.FProp("default", "set", macro:Float),
						pos: Context.currentPos(),
					});
					c.fields.push({
						name: "set_width",
						access: [Access.APrivate],
						pos: Context.currentPos(),
						kind: FFun({
							args: [{name:"value", type:macro:Float}],
							expr: macro {
								if (width > 0.0) w = w / width * value else w = 0;
								return width = value;
							},
							ret: macro:Float
						})
					});
				}
								
				if (glyphStyleHasField.local_height) {
					c.fields.push({
						name:  "height",
						access:  [Access.APublic],
						kind: FieldType.FProp("default", "set", macro:Float),
						pos: Context.currentPos(),
					});
					c.fields.push({
						name: "set_height",
						access: [Access.APrivate],
						pos: Context.currentPos(),
						kind: FFun({
							args: [{name:"value", type:macro:Float}],
							expr: macro {
								if (height > 0.0) h = h / height * value else h = 0;
								return height = value;
							},
							ret: macro:Float
						})
					});
				}
				
				c.fields.push({
					name: "w",
					meta: [{name:"sizeX", params:[], pos:Context.currentPos()},
					       //{name:"varying", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access: [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name: "h",
					meta: [{name:"sizeY", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access: [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name: "tx",
					meta: [{name:"texX", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access: [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "ty",
					meta: [{name:"texY", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access: [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name:  "tw",
					meta: [{name:"texW", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access: [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				c.fields.push({
					name: "th",
					meta: [{name:"texH", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access: [Access.APrivate],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});

			}
			else
			{
				var meta = [{name:"sizeX", params:[], pos:Context.currentPos()},
							{name:"varying", params:[], pos:Context.currentPos()}]; // TODO: for outlnine and weight
				if (!glyphStyleHasField.local_width) meta.push({name:"@const", params:[], pos:Context.currentPos()});
				c.fields.push({
					name:  "width",
					meta: meta,
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				
				meta = [{name:"sizeY", params:[], pos:Context.currentPos()}];
				if (!glyphStyleHasField.local_height) meta.push({name:"@const", params:[], pos:Context.currentPos()});
				c.fields.push({
					name:  "height",
					meta: meta,
					access:  [Access.APublic],
					kind: FieldType.FVar(macro:Float, macro 0.0),
					pos: Context.currentPos(),
				});
				
				c.fields.push({
					name:  "tile",
					meta: [{name:"texTile", params:[], pos:Context.currentPos()},
					       {name:":allow", params:[macro peote.text], pos:Context.currentPos()}],
					access:  [Access.APrivate],
					kind: FieldType.FVar(macro:Int, macro 0),
					pos: Context.currentPos(),
				});
				
			}
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
