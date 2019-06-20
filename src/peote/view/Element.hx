package peote.view;

#if !macro
@:remove @:autoBuild(peote.view.ElementImpl.build())
interface Element {}
class ElementImpl {}
#else

import haxe.Log;
import haxe.ds.StringMap;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Printer;

import peote.view.utils.Util;

typedef ConfParam =
{
	posX :ConfSubParam,
	posY :ConfSubParam,
	sizeX:ConfSubParam,
	sizeY:ConfSubParam,
	pivotX:ConfSubParam,
	pivotY:ConfSubParam,
	rotation:ConfSubParam,
	zIndex:ConfSubParam,
	
	texUnitDefault:ConfSubParam, texUnit:Array<ConfSubParam>,
	texSlotDefault:ConfSubParam, texSlot:Array<ConfSubParam>,
	texTileDefault:ConfSubParam, texTile:Array<ConfSubParam>,
	texXDefault:ConfSubParam, texX:Array<ConfSubParam>,
	texYDefault:ConfSubParam, texY:Array<ConfSubParam>,
	texWDefault:ConfSubParam, texW:Array<ConfSubParam>,
	texHDefault:ConfSubParam, texH:Array<ConfSubParam>,
	texPosXDefault:ConfSubParam, texPosX:Array<ConfSubParam>,
	texPosYDefault:ConfSubParam, texPosY:Array<ConfSubParam>,
	texSizeXDefault:ConfSubParam, texSizeX:Array<ConfSubParam>,
	texSizeYDefault:ConfSubParam, texSizeY:Array<ConfSubParam>,
	
	colorDefault:ConfSubParam, color:Array<ConfSubParam>,
	customDefault:ConfSubParam, custom:Array<ConfSubParam>,
}
typedef ConfSubParam =
{
	formula:String, isVarying:Bool, isAltType:Bool, vStart:Dynamic, vEnd:Dynamic, n:Int, isAnim:Bool, name:String, isStart:Bool, isEnd:Bool, time:String, pos:Position
}

typedef GLConfParam =
{			UNIFORM_TIME:String,
			ATTRIB_TIME:String, ATTRIB_SIZE:String, ATTRIB_POS:String, ATTRIB_ROTZ:String, ATTRIB_PIVOT:String,
			ATTRIB_UNIT:String, ATTRIB_SLOT:String, ATTRIB_TILE:String,
			ATTRIB_PACK:String,
			ATTRIB_TEXX:String, ATTRIB_TEXY:String, ATTRIB_TEXW:String, ATTRIB_TEXH:String,
			ATTRIB_TEXPOSX:String, ATTRIB_TEXPOSY:String, ATTRIB_TEXSIZEX:String, ATTRIB_TEXSIZEY:String,
			ATTRIB_COLOR:String, ATTRIB_CUSTOM:String,
			OUT_VARYING:String, IN_VARYING:String,
			OUT_TEXVARYING:String, IN_TEXVARYING:String,
			OUT_COLOR:String, IN_COLOR:String, OUT_TEXCOORD:String, IN_TEXCOORD:String, ZINDEX:String,
			OUT_UNIT:String, IN_UNIT:String, OUT_SLOT:String, IN_SLOT:String, OUT_TILE:String, IN_TILE:String,
			OUT_TEXX:String, IN_TEXX:String, OUT_TEXY:String, IN_TEXY:String, OUT_TEXW:String, IN_TEXW:String, OUT_TEXH:String, IN_TEXH:String, 
			OUT_TEXPOSX:String, IN_TEXPOSX:String, OUT_TEXPOSY:String, IN_TEXPOSY:String, OUT_TEXSIZEX:String, IN_TEXSIZEX:String, OUT_TEXSIZEY:String, IN_TEXSIZEY:String,
			FRAGMENT_CALC_COLOR:String,
			CALC_TIME:String, CALC_SIZE:String, CALC_POS:String, CALC_ROTZ:String, CALC_PIVOT:String, CALC_TEXCOORD:String,
			CALC_VARYING:String, CALC_TEXVARYING:String,
			CALC_UNIT:String, CALC_SLOT:String, CALC_TILE:String,
			CALC_TEXX:String, CALC_TEXY:String, CALC_TEXW:String, CALC_TEXH:String,
			CALC_TEXPOSX:String, CALC_TEXPOSY:String, CALC_TEXSIZEX:String, CALC_TEXSIZEY:String,
			CALC_COLOR:String,
			ELEMENT_LAYERS:Array<{UNIT:String, end_ELEMENT_LAYER:String, if_ELEMENT_LAYER:String, TEXCOORD:String}>,
};

class ElementImpl
{
	static inline var MAX_ZINDEX:Int = 0x1FFFFF;
	
	//static inline function debug(s:String, ?pos:haxe.PosInfos):Void	{
	static inline function debug(s:String, ?pos:haxe.PosInfos):Void	{
		#if peoteview_debug_macro
		//trace(s);
		Log.trace(s,pos);
		#end
	}
	static inline function debugLastField(fields:Array<Field>):Void	{
		#if peoteview_debug_macro
		trace(new Printer().printField(fields[fields.length - 1]));
		#end
	}
	
	/*
	static var rComments:EReg = new EReg("//.*?$","gm");
	static var rEmptylines:EReg = new EReg("([ \t]*\r?\n)+", "g");
	static var rStartspaces:EReg = new EReg("^([ \t]*\r?\n)+", "g");
	*/
	static inline function parseShader(shader:String):String {
		var template = new utils.MultipassTemplate(shader);
		//var s = rStartspaces.replace(rEmptylines.replace(rComments.replace(template.execute(glConf), ""), "\n"), "");
		var s = template.execute(glConf);
		return s;
	}
	
	static function hasMeta(f:Field, s:String):Bool {
		var itHas:Bool = false;
		for (m in f.meta) {
			if (m.name == s || m.name == ':$s') {
				itHas = true; break; 
			}
		}
		return itHas;
	}
	
	static function getMetaParam(f:Field, s:String):String {
		var p = null;
		var found = false;
		for (m in f.meta) if (m.name == s || m.name == ':$s') { p = m.params[0]; found = true; break; }
		if (found) {
			if (p != null) {
				switch (p.expr) {
					case EConst(CString(value)): return value;
					case EConst(CInt(value)): return value;
					case EConst(CFloat(value)): return value;
					default: return "";
				}
			}
			else return "";
		}
		else return null;
	}
		
	static inline function getTimeMetaParams(f:Field, s:String):Null<Array<String>> {
		var pa:Null<Array<Expr>> = null;
		var found = false;
		for (m in f.meta) if (m.name == s || m.name == ':$s') { pa = m.params; found = true; break; }
		if (found) {
			var types = ["default", "constant", "repeat", "pingpong"];
			var ret = new Array<String>();
			if (pa != null)
				for (p in pa)
					switch (p.expr) {
						case EConst(CString(value)): ret.push(value);
						//case EConst(CInt(value)): ret.push(value);
						default:
					}
			if (ret.length == 0) ret.push("");
			else if (ret[0] != "") {
				if (types.indexOf(ret[0].toLowerCase()) >= 0) ret.unshift("");
				else {
					ret[0] = Util.camelCase("", ret[0]);
					if (Util.isWrongIdentifier(ret[0])) throw Context.error('Error: "${ret[0]}" is not an identifier, please use only letters/numbers or "_" (starting with a letter)', f.pos);
				}
			}
			if (ret.length == 1) ret.push("default");
			ret[1] = ret[1].toLowerCase();
			if (types.indexOf(ret[1]) == -1) throw Context.error('Error: unknown time interpolation type "${ret[1]}". Possible values are "${types.join(",")}"', f.pos);
			if (ret.length > 2) throw Context.error('Error: to much parameter', f.pos);
			return ret;
		}
		else return null;
	}
	
	static inline function getIdentifiersByMetaParams(f:Field, s:String):Null<Array<String>> {
		var pa:Null<Array<Expr>> = null;
		var found = false;
		for (m in f.meta) if (m.name == s || m.name == ':$s') { pa = m.params; found = true; break; }
		if (found) {
			var ret = new Array<String>();
			if (pa != null)
				for (p in pa)
					switch (p.expr) {
						case EConst(CString(value)): ret.push(value);
						default: throw Context.error('Error: identifiers has to be Strings', f.pos); // TODO: test!!
					}
			return ret;
		}
		else return null;
	}
	
	static var allowForBuffer = [{name:":allow", params:[macro peote.view], pos:Context.currentPos()}];
	
	static function genVar(type:ComplexType, name:String, value:Dynamic, isConstant:Bool = false) {
		if (fieldnames.indexOf(name) == -1) {
			fields.push({
				name:  name,
				access:  [Access.APublic],
				kind: (isConstant) ? FieldType.FProp("get", "never", type) : FieldType.FVar( type, macro $v{value} ), 
				pos: Context.currentPos(),
			});
			debugLastField(fields);
			if (isConstant) genConstGetter(type, name, value);
		}
	}
	
	static inline function genConstGetter(type:ComplexType, name:String, value:Dynamic) {
		if (fieldnames.indexOf("get_"+name) == -1) {
			fields.push({
				name: "get_"+name,
				access: [Access.APrivate, Access.AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro return $v{value},
					params: [],
					ret: type
				})
			});
			debugLastField(fields);
		}
	}
	
	static inline function genSetter(v:Dynamic) {
		if (fieldnames.indexOf("set_"+v.name) == -1) {
			fields.push({
				name: "set_"+v.name,
				access: [Access.APrivate, Access.AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name:"value", type:v.type}],
					expr: macro $b{v.expr},
					params: [],
					ret: v.type
				})
			});
			debugLastField(fields);
		}
	}
	
	static inline function checkSet(f:Field, type:ComplexType, isAnim:Bool = false, isAnimStart:Bool = false, isAnimEnd:Bool = false )
	{
		var param:String = getMetaParam(f, "set");
		if (param != null) {
			param = Util.camelCase("set", param);
			var v = setFun.get(param);
			if (v == null) {
				v = {args:[], expr:[]};
				setFun.set( param, v);
			}
			var name:String = f.name;
			v.args.push( {name:name, type:type} );
			if (!isAnim) v.expr.push( macro this.$name = $i{name} );
			else {
				var nameStart:String = name + "Start";
				var nameEnd:String = name + "End";
				if (isAnimStart) v.expr.push( macro this.$nameStart = $i{name} );
				if (isAnimEnd)   v.expr.push( macro this.$nameEnd   = $i{name} );
			}
		}		
	}
	
	static inline function checkAnim(f:Field, type:ComplexType, isAnimStart:Bool, isAnimEnd:Bool)
	{
		var param:String = getMetaParam(f, "anim");
		if (param != null) {
			param = Util.camelCase("anim", param);
			var v = animFun.get(param);
			if (v == null) {
				v = {argsStart:[], argsEnd:[], exprStart:[], exprEnd:[]};
				animFun.set( param, v);
			}			
			if (isAnimStart) {
				var nameStart:String = f.name + "Start";
				v.argsStart.push( {name:nameStart, type:type} );
				v.exprStart.push( macro this.$nameStart   = $i{nameStart} );
			}
			if (isAnimEnd) {
				var nameEnd:String   = f.name + "End";
				v.argsEnd.push( {name:nameEnd, type:type} );
				v.exprEnd.push( macro this.$nameEnd   = $i{nameEnd} );
			}
		}		
	}

	static inline function addConstGetter(type:ComplexType, name:String, value:Dynamic)
	{
		getterFun.push({type:type, name:name, value:value});
	}

	static inline function addSetter(type:ComplexType, name:String, isStart:Bool, isEnd:Bool)
	{
		var v = {type:type, name:name, expr:[]};
		var nameEnd:String   = name + "End";
		var nameStart:String = name + "Start";
		if (isStart) v.expr.push( macro this.$nameStart = value );
		if (isEnd)   v.expr.push( macro this.$nameEnd   = value );
		v.expr.push( macro return value );
		setterFun.push(v);
	}
	
	
	static function checkMetas(f:Field, expectedType:ComplexType, alternativeType:ComplexType, type:ComplexType, val:Expr, confItem:ConfSubParam, getter:String, setter:String)
	{
		if (confItem.name == "") confItem.name = f.name;
		else throw Context.error('Error: attribute already defined for "${f.name}"', f.pos);
		
		confItem.pos = f.pos;
		
		if (f.access.indexOf(Access.AStatic) != -1) throw Context.error('Error: "${f.name}" can not be static', f.pos);
		
		var printer = new Printer();
		
		var expType:String = switch(expectedType) { case TPath(tp): tp.name; default: ""; }
		var hasType:String;
		
		if (type == null) { debug('set type of ${f.name} to ${printer.printComplexType(expectedType)}');
			type = expectedType;
			f.kind = FieldType.FVar( type, val );
		}
		else {
			hasType = switch(type) { case TPath(tp): tp.name; default: ""; }
			//trace('var ${f.name}: - type:${hasType} - expected type:${expType}');
			if (hasType != expType) {
				if (alternativeType != null) {
					expType = switch(alternativeType) { case TPath(tp): tp.name; default: ""; }
					if (hasType == expType) {
						type = alternativeType;
						confItem.isAltType = true;
					}
					else throw Context.error('Error: type of "${f.name}" should be ${ printer.printComplexType(expectedType) } or ${ printer.printComplexType(alternativeType) }', f.pos);
				}
				else throw Context.error('Error: type of "${f.name}" should be ${ printer.printComplexType(expectedType) }', f.pos);
			}
		}
				
		var defaultVal:Dynamic;
		if (val != null) {
			var v:Dynamic;
			try v = ExprTools.getValue(val) catch(e:String) throw Context.error('Error: init value for "${f.name}" had to be Int or Float', f.pos);
			if (expType=="Int" && Type.typeof(v) != Type.ValueType.TInt)
				throw Context.error('Error: init value "$v" for "${f.name}" had to be Int', f.pos);
			else if (expType=="Float" && Type.typeof(v) != Type.ValueType.TFloat)
				throw Context.error('Error: init value "$v" for "${f.name}" had to be Float', f.pos);
			else if (expType=="Color" && Type.typeof(v) != Type.ValueType.TInt)
				throw Context.error('Error: init value "$v" for "${f.name}" had to be Int', f.pos);
			defaultVal = v;
		} else {
			defaultVal = confItem.vStart; debug('set default value of ${f.name} to ${(macro $v{defaultVal}).expr}');
			f.kind = FieldType.FVar( type, macro $v{defaultVal} );
		}
		
		var param:String;
		var timeparam = getTimeMetaParams(f, "time");
		if (timeparam == null) timeparam = getTimeMetaParams(f, "anim"); // if no @time exists, use @anim instead
		if (timeparam != null) {
			confItem.isAnim = true;
			if (timers.indexOf(timeparam[0]) == -1) {
				timers.push( timeparam[0] );
				timerTypes.push( timeparam[1] );
			} else if (timeparam[1] != "default") timerTypes[timers.indexOf(timeparam[0])] = timeparam[1];
			confItem.time = timeparam[0];
			
			param = getMetaParam(f, "constStart");
			if (param != null) {
				if (param == "") confItem.vStart = defaultVal;
				else confItem.vStart = (expType=="Int") ? Std.parseInt(param) : Std.parseFloat(param);
			} else {
				confItem.isStart = true;
				confItem.n++;
			}
			param = getMetaParam(f, "constEnd");
			if (param != null) {
				if (param == "") confItem.vEnd = defaultVal;
				else confItem.vEnd = (expType=="Int") ? Std.parseInt(param) : Std.parseFloat(param);
				if (confItem.vStart == confItem.vEnd) throw Context.error('Error: it is senseless to animate if @constStart == @constEnd', f.pos);
			} else {
				confItem.isEnd = true;
				confItem.n++;
			}
			if (confItem.isStart || confItem.isEnd) {
				checkSet(f, type, true, confItem.isStart, confItem.isEnd);
				checkAnim(f, type, confItem.isStart, confItem.isEnd);
				if (getter == "null" || getter == "default")
					throw Context.error('Error: for ${f.name}-getter use "never" or "get" for custom getter-function', f.pos);
				// todo: generate new function "getCurrentX(time:Float)" to get relative value
				if (setter == "null")
					throw Context.error('Error: for ${f.name}-setter use "never" or "set".\nFor "default" a setter will be generated automatically that sets ${(confItem.isStart) ? f.name+"Start": ""} ${(confItem.isEnd) ? f.name+"End": ""} .', f.pos);
				f.kind = FieldType.FProp( (getter == null || getter == "never") ? "never" : getter,
				                          (setter == null || setter == "default") ? "set" : setter, type);
				if (setter == null || setter == "default") addSetter(type, f.name, confItem.isStart, confItem.isEnd);
			} else {
				if ((getter != null && getter != "never") || (setter != null && setter != "never"))
					throw Context.error('Error: for constant start/end-values ${f.name} getter and setter has to be "never"', f.pos);
				f.kind = FieldType.FProp("never", "never", type);
			}
		} 
		else {
			param = getMetaParam(f, "const");
			if (param != null) {
				if (param == "") confItem.vStart = defaultVal;
				else {
					confItem.vStart = (expType == "Int") ? Std.parseInt(param) : Std.parseFloat(param);
					// trace("CHECK-:",confItem.name, expType, confItem.vStart); // TODO: same for constStart/end, check Color-consts
					if (confItem.vStart == null) 
						throw Context.error('Error: value of constant ${f.name} has to be of type "$expType"', f.pos);
				}
				if (getter == "null")
					throw Context.error('Error: for constant ${f.name} the getter has to be "default", "never" or "get"', f.pos);
				if (setter != null && setter != "never")
					throw Context.error('Error: for constant ${f.name} the setter has to be "never"', f.pos);
				f.kind = FieldType.FProp( (getter == null || getter == "default") ? "get" : getter, "never", type);
				if (getter == null || getter == "default") addConstGetter(type, f.name, confItem.vStart);
			} else {
				confItem.isStart = true;
				checkSet(f, type);
				confItem.n++;
			}							
		}
		// to make an attribute varying for fragmentshader - only for vPos, vSize, vRotZ or vPivot
		param = getMetaParam(f, "varying");
		if (param != null) {
			confItem.isVarying = true;
		}
		var fparam = getIdentifiersByMetaParams(f, "formula");
		if (fparam != null) {
			confItem.formula = fparam[0];
			//if (fparam.length>1) // TODO: options?
		}
		//trace(confItem);
	}
	
	static function checkTexLayerMetas(meta:String, f:Field, expectedType:ComplexType, alternativeType:ComplexType, type:ComplexType, val:Expr, d:ConfSubParam, confItem:Array<ConfSubParam>, getter:String, setter:String):Bool
	{
		var identifiers:Array<String> = getIdentifiersByMetaParams(f, meta);
		if (identifiers == null) return false;
		if (identifiers.length == 0) identifiers.push("__default__");
		for (name in identifiers) {
			if (colorIdentifiers.indexOf(name) >= 0) throw Context.error('Error: "$name" is already used for a @color identifier', f.pos);
			if (name != "__default__" && Util.isWrongIdentifier(name)) throw Context.error('Error: "$name" is not an identifier, please use only letters/numbers or "_" (starting with a letter)', f.pos);
			var layer = confTextureLayer.get(name);
			if (layer != null) {
				if (layer.exists(meta)) throw Context.error('Error: "$name" is already used as identifier for @$meta', f.pos);
				layer.set(meta, confItem.length);
			} else {
				layer = new StringMap<Int>();
				if (name != "__default__") {
					textureIdentifiers[maxLayer] = name;
					layer.set("layer", maxLayer++);
				}
				layer.set(meta, confItem.length );
				confTextureLayer.set(name, layer);
			}
		}
		var c = { formula:d.formula, isVarying:d.isVarying, isAltType:d.isAltType, vStart:d.vStart, vEnd:d.vEnd, n:d.n, isAnim:d.isAnim, name:d.name, isStart:d.isStart, isEnd:d.isEnd, time:d.time, pos:d.pos };
		checkMetas(f, expectedType, alternativeType, type, val, c , getter, setter);
		confItem.push(c);
		return true;
	}
	
	static function checkColorLayerMetas(meta:String, f:Field, expectedType:ComplexType, alternativeType:ComplexType, type:ComplexType, val:Expr, d:ConfSubParam, confItem:Array<ConfSubParam>, getter:String, setter:String):Bool
	{
		var identifiers:Array<String> = getIdentifiersByMetaParams(f, meta);
		if (identifiers == null) return false;
		if (identifiers.length > 1) throw Context.error('Error: @color attributes needs only 1 identifier for use in colorFormula (default is allways "color")', f.pos);
		if (identifiers.length == 0) identifiers.push("color");
		var name = identifiers[0];
		if (Util.isWrongIdentifier(name)) throw Context.error('Error: "$name" is not an identifier, please use only letters/numbers or "_" (starting with a letter)', f.pos);
		if (colorIdentifiers.indexOf(name) >= 0) throw Context.error('Error: "$name" is already used for a @color identifier', f.pos);
		if (confTextureLayer.exists(name)) throw Context.error('Error: "$name" is already used as identifier for a texture-layer', f.pos);
		colorIdentifiers.push(name);
		var c = { formula:d.formula, isVarying:d.isVarying, isAltType:d.isAltType, vStart:d.vStart, vEnd:d.vEnd, n:d.n, isAnim:d.isAnim, name:d.name, isStart:d.isStart, isEnd:d.isEnd, time:d.time, pos:d.pos };
		checkMetas(f, expectedType, alternativeType, type, val, c , getter, setter);
		confItem.push(c);
		return true;
	}
	
	static function checkCustomMetas(meta:String, f:Field, expectedType:ComplexType, alternativeType:ComplexType, type:ComplexType, val:Expr, d:ConfSubParam, confItem:Array<ConfSubParam>, getter:String, setter:String):Bool
	{
		var identifiers:Array<String> = getIdentifiersByMetaParams(f, meta);
		if (identifiers == null) return false;
		if (identifiers.length > 1) throw Context.error('Error: @custom attributes needs only 1 identifier for use in custom shadercode (default is allways "custom")', f.pos);
		if (identifiers.length == 0) identifiers.push("custom");
		var name = identifiers[0];
		if (Util.isWrongIdentifier(name)) throw Context.error('Error: "$name" is not an identifier, please use only letters/numbers or "_" (starting with a letter)', f.pos);
		if (customIdentifiers.indexOf(name) >= 0) throw Context.error('Error: "$name" is already used for a @custom identifier', f.pos);
		customIdentifiers.push(name);
		var c = { formula:d.formula, isVarying:d.isVarying, isAltType:d.isAltType, vStart:d.vStart, vEnd:d.vEnd, n:d.n, isAnim:d.isAnim, name:d.name, isStart:d.isStart, isEnd:d.isEnd, time:d.time, pos:d.pos };
		checkMetas(f, expectedType, alternativeType, type, val, c , getter, setter);
		confItem.push(c);
		return true;
	}
	
	static inline function configure(f:Field, type:ComplexType, val:Expr, getter:String=null, setter:String=null)
	{	//trace(f.name, type, val, getter, setter);
		if      (hasMeta(f, "posX"))   checkMetas(f, macro:Int, macro:Float, type, val, conf.posX, getter, setter);
		else if (hasMeta(f, "posY"))   checkMetas(f, macro:Int, macro:Float, type, val, conf.posY, getter, setter);
		else if (hasMeta(f, "sizeX"))  checkMetas(f, macro:Int, macro:Float, type, val, conf.sizeX, getter, setter);
		else if (hasMeta(f, "sizeY"))  checkMetas(f, macro:Int, macro:Float, type, val, conf.sizeY, getter, setter);
		else if (hasMeta(f, "pivotX")) checkMetas(f, macro:Int, macro:Float, type, val, conf.pivotX, getter, setter);
		else if (hasMeta(f, "pivotY")) checkMetas(f, macro:Int, macro:Float, type, val, conf.pivotY, getter, setter);
		// rotz
		else if (hasMeta(f, "rotation"))checkMetas(f, macro:Float, null, type, val, conf.rotation, getter, setter);
		else if (hasMeta(f, "zIndex"))  checkMetas(f, macro:Int,   null, type, val, conf.zIndex, getter, setter);
		// color layer attributes
		else if (checkColorLayerMetas("color", f, macro:peote.view.Color, null, type, val, conf.colorDefault, conf.color, getter, setter) ) {}
		// custom attributes
		else if (checkCustomMetas("custom", f, macro:Int, macro:Float, type, val, conf.customDefault, conf.custom, getter, setter) ) {}
		// texture layer attributes
		else if (checkTexLayerMetas("texX",    f, macro:Int, macro:Float, type, val, conf.texXDefault, conf.texX, getter, setter) ) {}
		else if (checkTexLayerMetas("texY",    f, macro:Int, macro:Float, type, val, conf.texYDefault, conf.texY, getter, setter) ) {}
		else if (checkTexLayerMetas("texW",    f, macro:Int, macro:Float, type, val, conf.texWDefault, conf.texW, getter, setter) ) {}
		else if (checkTexLayerMetas("texH",    f, macro:Int, macro:Float, type, val, conf.texHDefault, conf.texH, getter, setter) ) {}
		else if (checkTexLayerMetas("texPosX", f, macro:Int, macro:Float, type, val, conf.texPosXDefault,  conf.texPosX, getter, setter) ) {}
		else if (checkTexLayerMetas("texPosY", f, macro:Int, macro:Float, type, val, conf.texPosYDefault,  conf.texPosY, getter, setter) ) {}
		else if (checkTexLayerMetas("texSizeX",f, macro:Int, macro:Float, type, val, conf.texSizeXDefault, conf.texSizeX, getter, setter) ) {}
		else if (checkTexLayerMetas("texSizeY",f, macro:Int, macro:Float, type, val, conf.texSizeYDefault, conf.texSizeY, getter, setter) ) {}
		else if (checkTexLayerMetas("texUnit", f, macro:Int, null, type, val, conf.texUnitDefault, conf.texUnit, getter, setter) ) {}
		else if (checkTexLayerMetas("texSlot", f, macro:Int, null, type, val, conf.texSlotDefault, conf.texSlot, getter, setter) ) {}
		else if (checkTexLayerMetas("texTile", f, macro:Int, null, type, val, conf.texTileDefault, conf.texTile, getter, setter) ) {}
	}

	static var setFun :StringMap<Dynamic>;
	static var animFun:StringMap<Dynamic>;
	
	static var getterFun:Array<Dynamic>;
	static var setterFun:Array<Dynamic>;
	
	static var timers:Array<String>;
	static var timerTypes:Array<String>;
	
	static var fieldnames:Array<String>;	
	static var fields:Array<Field>;
	
	static var conf:ConfParam;
	static var glConf:GLConfParam;
	
	static var maxLayer:Int;
	static var confTextureLayer:StringMap<StringMap<Int>>;
	static var textureIdentifiers:Array<String>;
	static var colorIdentifiers:Array<String>;
	static var customIdentifiers:Array<String>;
	
	static var formula:StringMap<String>;
	static var formulaErrPos:StringMap<Position>;		
	static var attrib:StringMap<String>;

	//static var isChild:Bool = false;
	// -------------------------------------- BUILD -------------------------------------------------
	public static function build()
	{
		conf = {
			posX :          { formula:"", isVarying:false, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },
			posY :          { formula:"", isVarying:false, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },		
			sizeX:          { formula:"", isVarying:false, isAltType:false, vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },
			sizeY:          { formula:"", isVarying:false, isAltType:false, vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },
			pivotX:         { formula:"", isVarying:false, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },			
			pivotY:         { formula:"", isVarying:false, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },			
			rotation:       { formula:"", isVarying:false, isAltType:false, vStart:0.0, vEnd:0.0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },			
			zIndex:         { formula:"", isVarying:false, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null },			

			colorDefault:   { formula:"", isVarying:false, isAltType:false, vStart:0xFF0000FF, vEnd:0xFF0000FF, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, color:[],
			
			texUnitDefault: { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texUnit:[],
			texSlotDefault: { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texSlot:[],
			texTileDefault: { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texTile:[],
			texXDefault:    { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texX:[],
			texYDefault:    { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texY:[],
			texWDefault:    { formula:"", isVarying:true, isAltType:false, vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texW:[],
			texHDefault:    { formula:"", isVarying:true, isAltType:false, vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texH:[],
			texPosXDefault: { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texPosX:[],
			texPosYDefault: { formula:"", isVarying:true, isAltType:false, vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texPosY:[],
			texSizeXDefault:{ formula:"", isVarying:true, isAltType:false, vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texSizeX:[],
			texSizeYDefault:{ formula:"", isVarying:true, isAltType:false, vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, texSizeY:[],
			customDefault:  { formula:"", isVarying:false, isAltType:false, vStart:0,   vEnd:0,  n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "-", pos:null }, custom:[],
		};
		
		glConf = {
			UNIFORM_TIME:"",
			ATTRIB_TIME:"", ATTRIB_SIZE:"", ATTRIB_POS:"", ATTRIB_ROTZ:"", ATTRIB_PIVOT:"",
			ATTRIB_UNIT:"", ATTRIB_SLOT:"", ATTRIB_TILE:"",
			ATTRIB_PACK:"",
			ATTRIB_TEXX:"", ATTRIB_TEXY:"", ATTRIB_TEXW:"", ATTRIB_TEXH:"",
			ATTRIB_TEXPOSX:"", ATTRIB_TEXPOSY:"", ATTRIB_TEXSIZEX:"", ATTRIB_TEXSIZEY:"",
			ATTRIB_COLOR:"", ATTRIB_CUSTOM:"",
			OUT_VARYING:"", IN_VARYING:"",
			OUT_TEXVARYING:"", IN_TEXVARYING:"",
			OUT_COLOR:"", IN_COLOR:"", OUT_TEXCOORD:"", IN_TEXCOORD:"", ZINDEX:"",
			OUT_UNIT:"", IN_UNIT:"", OUT_SLOT:"", IN_SLOT:"", OUT_TILE:"", IN_TILE:"",
			OUT_TEXX:"", IN_TEXX:"", OUT_TEXY:"", IN_TEXY:"", OUT_TEXW:"", IN_TEXW:"", OUT_TEXH:"", IN_TEXH:"", 
			OUT_TEXPOSX:"", IN_TEXPOSX:"", OUT_TEXPOSY:"", IN_TEXPOSY:"", OUT_TEXSIZEX:"", IN_TEXSIZEX:"", OUT_TEXSIZEY:"", IN_TEXSIZEY:"", 
			FRAGMENT_CALC_COLOR:"",
			CALC_TIME:"", CALC_SIZE:"", CALC_POS:"", CALC_ROTZ:"", CALC_PIVOT:"", CALC_TEXCOORD:"",
			CALC_UNIT:"", CALC_SLOT:"", CALC_TILE:"",
			CALC_VARYING:"", CALC_TEXVARYING:"",
			CALC_TEXX:"", CALC_TEXY:"", CALC_TEXW:"", CALC_TEXH:"", 
			CALC_TEXPOSX:"", CALC_TEXPOSY:"", CALC_TEXSIZEX:"", CALC_TEXSIZEY:"", 
			CALC_COLOR:"",
			ELEMENT_LAYERS:[],
		};
		
		var options = { alpha:false, picking:false, texRepeatX:false, texRepeatY:false };
		
		setFun  = new StringMap<Dynamic>();
		animFun = new StringMap<Dynamic>();
		getterFun = new Array<Dynamic>();
		setterFun = new Array<Dynamic>();
		timers = new Array<String>();
		timerTypes = new Array<String>();
		fieldnames = new Array<String>();
		maxLayer = 0;
		confTextureLayer = new StringMap<StringMap<Int>>();
		textureIdentifiers = new Array<String>();
		colorIdentifiers = new Array<String>();
		customIdentifiers = new Array<String>();
		
		formula = new StringMap<String>();
		formulaErrPos = new StringMap<Position>();		
		attrib = new StringMap<String>();
		
		fields = Context.getBuildFields();

		var hasNoNew:Bool = true;		
		var hasNoDefaultColorFormula:Bool = true;		
		var hasNoDefaultFormulaVars:Bool = true;
		var defaultFormulaVars = new Array<String>();
		var needFragmentPrecision:Bool = false;
		
		var classname:String = Context.getLocalClass().get().name;
		//var classpackage = Context.getLocalClass().get().pack;
		
		// TODO: Errormsg; "defines had to be in superclass" if found some metas in fields
		if (Context.getLocalClass().get().superClass != null) return fields;//isChild = true;
		
		debug('----- generating Class: $classname -----');
		
		for (f in fields)
		{	
			if (f.name == "new") hasNoNew = false;
			else if (f.name == "DEFAULT_COLOR_FORMULA") { // TODO: check Formula
				hasNoDefaultColorFormula = false;
				f.meta = allowForBuffer;
				f.access = [Access.APrivate, Access.AStatic, Access.AInline];				
			}
			else if (f.name == "DEFAULT_FORMULA_VARS") {
				hasNoDefaultFormulaVars = false;
				f.meta = allowForBuffer;
				f.access = [Access.APrivate, Access.AStatic];
				// collect identifiers here to make all new identifiers also static for .TEXTURE_...
				switch(f.kind) {
					case FVar(_, val):
						switch(val.expr) {
							case EArrayDecl(arr):
								for (a in arr)
									switch(a.expr) {
										case EBinop(OpArrow, e1, _):
											switch(e1.expr) {
												case EConst(CString(identifier)):
													if (Util.isWrongIdentifier(identifier)) throw Context.error('Error: "$identifier" is not an identifier, please use only letters/numbers or "_" (starting with a letter)', f.pos);
													defaultFormulaVars.push(identifier);
												default: // TODO: errorhandling if there is no value of type color or int
											}
										default:
									}
							default:
						}
					default:
				}
			}
			else if (f.name == "OPTIONS") {
				f.meta = allowForBuffer;
				f.access = [Access.APrivate, Access.AStatic];
				switch(f.kind) {
					case FVar(_, val):
						switch(val.expr) {
							case EObjectDecl(obj):
								var vBool:Null<Bool> = null;
								var vInt:Null<Int> = null;
								var vString:Null<String> = null;
								for (o in obj) {
									//trace(o.expr.expr);
									switch(o.expr.expr) {
										case EConst(CIdent(value)):  vBool = (value == "true") ? true : false;
										case EConst(CInt(value)):    vInt  = Std.parseInt(value);
										case EConst(CString(value)): vString = value;
										default: throw Context.error('Error: "${o.field}" has invalid type', f.pos);
									}
									var checkErr = function(v:Null<Dynamic>, expType:String) {
										if (v==null) throw Context.error('Error: "${o.field}" should be of type $expType', f.pos);
									}
									switch (o.field) {
										case ("alpha"):        checkErr(vBool, "Bool"); options.alpha      = vBool;
										case ("picking"):      checkErr(vBool, "Bool"); options.picking    = vBool;
										case ("texRepeatX"):   checkErr(vBool, "Bool"); options.texRepeatX = vBool;
										case ("texRepeatY"):   checkErr(vBool, "Bool"); options.texRepeatY = vBool;
										default: throw Context.error('Error: "${o.field}" is not a valid option', f.pos);
									}
								}
							default:
						}
					default:
				}
			}
			else {
				fieldnames.push(f.name);
				switch (f.kind)
				{	
					case FVar(type, val)                 : configure(f, type, val);
					case FProp(getter, setter, type, val): configure(f, type, val, getter, setter);
					default: //trace(f.kind);
				}
			}
		}
		
		// --------------------- generate shader-template vars -------------------------------
		for (i in 0...Std.int((timers.length + 1) / 2)) {
			if ((i == Std.int(timers.length / 2)) && (timers.length % 2 != 0))
			     glConf.ATTRIB_TIME += '::IN:: vec2 aTime$i;';
			else glConf.ATTRIB_TIME += '::IN:: vec4 aTime$i;';
		}
		
		// size, pos, pivot and rotation+z-index
		var n:Int;
		n = conf.sizeX.n + conf.sizeY.n;
		if (n > 0) glConf.ATTRIB_SIZE = '::IN:: ${ (n==1) ? "float" : "vec"+n} aSize;';
		n = conf.posX.n + conf.posY.n;
		if (n > 0) glConf.ATTRIB_POS  = '::IN:: ${ (n==1) ? "float" : "vec"+n } aPos;';
		n = conf.pivotX.n + conf.pivotY.n;
		if (n > 0) glConf.ATTRIB_PIVOT = '::IN:: ${ (n==1) ? "float" : "vec"+n } aPivot;';
		n = conf.rotation.n + conf.zIndex.n;
		if (n > 0) glConf.ATTRIB_ROTZ = '::IN:: ${ (n==1) ? "float" : "vec"+n } aRotZ;';
		
		// color
		for (k in 0...conf.color.length) {
			if (conf.color[k].isStart) glConf.ATTRIB_COLOR += '::IN:: vec4 aColorStart${k};';
			if (conf.color[k].isEnd)   glConf.ATTRIB_COLOR += '::IN:: vec4 aColorEnd${k};';
			if (conf.color[k].n > 0) {
				glConf.OUT_COLOR += '::if isES3::flat ::end::::VAROUT:: vec4 vColor${k};';
				glConf.IN_COLOR  += '::if isES3::flat ::end::::VARIN:: vec4 vColor${k}; ';
			}
		}
				
		
		// --------- packing texture-attributes ---------
		var packedAttribs = {
			float: new Array<Array<{isStart:Bool, conf:ConfSubParam}>>(),
			short: new Array<Array<{isStart:Bool, conf:ConfSubParam}>>(),
			byte:  new Array<Array<{isStart:Bool, conf:ConfSubParam}>>() 
		};
		
		function createPackedAttribs(type:Array<Array<{isStart:Bool, conf:ConfSubParam}>>, altype:Array<Array<{isStart:Bool, conf:ConfSubParam}>> ,confArray:Array<Array<ConfSubParam>>)
		{
			var m = ['.x', '.y', '.z', '.w']; // TODO: make static for all functions that using it
			for (conf in confArray)
			{
				for (k in 0...conf.length) {
					var pa = (conf[k].isAltType) ? altype : type;
					var i = pa.length - 1;
					// packed attribs
					if (conf[k].isStart) {
						if (i < 0 || pa[i].length >= 4) {
							i++;
							pa.push(new Array<{isStart:Bool, conf:ConfSubParam}>());
						}
						pa[i].push({isStart:true, conf:conf[k]});
					}
					
					if (conf[k].isEnd) {
						if (i < 0 || pa[i].length >= 4) {
							i++;
							pa.push(new Array<{isStart:Bool, conf:ConfSubParam}>());
						}
						pa[i].push({isStart:false, conf:conf[k]});
					}
				}
			}
		}		
		createPackedAttribs(packedAttribs.byte , packedAttribs.byte,  [conf.texUnit]);
		createPackedAttribs(packedAttribs.short, packedAttribs.byte,  [conf.texSlot, conf.texTile]);
		createPackedAttribs(packedAttribs.short, packedAttribs.float, [conf.custom, conf.texX, conf.texY, conf.texW, conf.texH, conf.texPosX, conf.texPosY, conf.texSizeX, conf.texSizeY]);

/*		trace("packedAttribs.float:"); for (a in packedAttribs.float) trace('  ${[for(b in a) b.conf.name + ((b.isStart) ? "Start":"End")]}');
		trace("packedAttribs.short:"); for (a in packedAttribs.short) trace('  ${[for(b in a) b.conf.name + ((b.isStart) ? "Start":"End")]}');
		trace("packedAttribs.byte:");  for (a in packedAttribs.byte)  trace('  ${[for(b in a) b.conf.name + ((b.isStart) ? "Start":"End")]}');
*/		
		function resolvePackedAttribs(paType:Array<Array<{isStart:Bool, conf:ConfSubParam}>>, aName:String)
		{
			for (i in 0...paType.length) {
				var pa = paType[i];
				var m = ['.x', '.y', '.z', '.w']; // TODO: make static for all functions that using it
				
				var type = (pa.length == 1) ? "float" : "vec" + pa.length;
				glConf.ATTRIB_PACK += '::IN:: $type ' + aName + i + ";";
				
				for (j in 0...pa.length) {
					var mapping = pa[j];
					var ending = (i == paType.length-1 && pa.length == 1) ? "" : m[j];
					if (mapping.isStart)
						attrib.set(mapping.conf.name+"Start", aName + i + ending);
					else attrib.set(mapping.conf.name+"End",  aName + i + ending);
				}
			}
		}
		resolvePackedAttribs(packedAttribs.float, "aFloat"); 
		resolvePackedAttribs(packedAttribs.short, "aShort"); 
		resolvePackedAttribs(packedAttribs.byte,  "aByte"); 
			
		function resolvePackedFormulas(confArray:Array<Array<ConfSubParam>>)
		{
			for (conf in confArray)
			{
				for (k in 0...conf.length) {
					if (!conf[k].isStart)
						attrib.set(conf[k].name+"Start", Util.toFloatString(conf[k].vStart));
					
					if (!conf[k].isEnd) {
						if (conf[k].isAnim)	attrib.set(conf[k].name+"End", Util.toFloatString(conf[k].vEnd));
						else attrib.set(conf[k].name+"End", attrib.get(conf[k].name+"Start"));
					}
					
					// formulas for tex-attribs
					if (conf[k].formula != "") {
						formulaErrPos.set(conf[k].name, conf[k].pos);
						formula.set(conf[k].name, conf[k].formula);
					}
					
					if (conf[k].isAnim) {
						var t = timers.indexOf(conf[k].time);
						attrib.set(conf[k].name, '${attrib.get(conf[k].name+"Start")}+(${attrib.get(conf[k].name+"End")}-${attrib.get(conf[k].name+"Start")})*time$t');
					} else attrib.set(conf[k].name, attrib.get(conf[k].name+"Start"));
				}
			}
		}		
		resolvePackedFormulas([conf.custom, conf.texUnit, conf.texSlot, conf.texTile, conf.texX, conf.texY, conf.texW, conf.texH, conf.texPosX, conf.texPosY, conf.texSizeX, conf.texSizeY]);
				
/*		trace("formula:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		trace("attrib:"); for (a in attrib.keys()) trace('  $a => ${attrib.get(a)}');
		trace("-----");
*/		
		glConf.OUT_TEXCOORD = "::VAROUT:: vec2 vTexCoord;";
		glConf.IN_TEXCOORD  = "::VARIN:: vec2 vTexCoord;";
		// default texcoords
		glConf.CALC_TEXCOORD  = "vTexCoord = aPosition;";
		
		// CALC TIME-MUTLIPLICATORS:
		for (i in 0...timers.length) {
			var t:String = "" + Std.int(i / 2);
			var d:String = "" + Std.int(i / 2);
			if (i % 2 == 0) { t += ".x"; d += ".y"; } else { t += ".z"; d += ".w"; }
			if (timerTypes[i] == "constant")
				glConf.CALC_TIME += 'float time$i = (uTime - aTime$t) / max(aTime$d, 0.000001); ';
			else if (timerTypes[i] == "repeat")
				glConf.CALC_TIME += 'float time$i = fract( (uTime - aTime$t) / max(aTime$d, 0.000001) ); ';
			else if (timerTypes[i] == "pingpong")
				glConf.CALC_TIME += 'float time$i = 1.0 - abs(mix( -1.0, 1.0, fract((uTime - aTime$t) / max(aTime$d * 2.0, 0.000001)))); ';
			else
				glConf.CALC_TIME += 'float time$i = clamp( (uTime - aTime$t) / aTime$d, 0.0, 1.0); ';
		}
		if (timers.length > 0) glConf.UNIFORM_TIME = "uniform float uTime;";
		
		// pack & formulas -------------------------------------------------------
		function resolveFormulas(name:String, x:ConfSubParam, y:ConfSubParam)
		{				
			var ending = ["",".x", ".y", ".z", ".w"];
			var i = (x.n + y.n > 1) ? 1 : 0;
			
			if (x.name != "") {
				if (x.formula != "") {
					formulaErrPos.set(x.name, x.pos);
					formula.set(x.name, x.formula);
				}				
				if (x.isStart) {
					attrib.set(x.name+"Start", name + ending[i++]);
				} else attrib.set(x.name+"Start", Util.toFloatString(x.vStart));
			}
			
			if (y.name != "") {
				if (y.formula != "") {
					formula.set(y.name, y.formula);
					formulaErrPos.set(y.name, y.pos);
				}
				if (y.isStart) {
					attrib.set(y.name+"Start", name + ending[i++]);
				} else attrib.set(y.name+"Start", Util.toFloatString(y.vStart));
			}
			
			// ANIM
			if (x.name != "") {
				if (x.isEnd) attrib.set(x.name+"End", name + ending[i++]);
				else if (x.isAnim) attrib.set(x.name+"End", Util.toFloatString(x.vEnd));
				else attrib.set(x.name+"End", attrib.get(x.name+"Start"));
				
				if (x.isAnim) {
					var tx = timers.indexOf(x.time);
					attrib.set(x.name, '${attrib.get(x.name+"Start")}+(${attrib.get(x.name+"End")}-${attrib.get(x.name+"Start")})*time$tx');
				} else attrib.set(x.name, attrib.get(x.name+"Start"));
			}
			
			if (y.name != "") {
				if (y.isEnd) attrib.set(y.name+"End", name + ending[i]);
				else if (y.isAnim) attrib.set(y.name+"End", Util.toFloatString(y.vEnd));
				else attrib.set(y.name+"End", attrib.get(y.name+"Start"));

				if (y .isAnim) {
					var ty = timers.indexOf(y.time);
					attrib.set(y.name, '${attrib.get(y.name+"Start")}+(${attrib.get(y.name+"End")}-${attrib.get(y.name+"Start")})*time$ty');					
				} else attrib.set(y.name, attrib.get(y.name+"Start"));
			}
				
		}
		
		resolveFormulas("aSize", conf.sizeX, conf.sizeY); 
		resolveFormulas("aPos" , conf.posX, conf.posY );
		resolveFormulas("aRotZ" , conf.rotation, conf.zIndex );
		resolveFormulas("aPivot", conf.pivotX, conf.pivotY );
		
		try Util.resolveFormulaCyclic(formula) catch(e:Dynamic) throw Context.error('Error: cyclic reference of "${e.errVar}" inside @formula "${e.formula}" for "${e.errKey}"', formulaErrPos.get(e.errKey));
		//trace("formula cyclic resolved:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		Util.resolveFormulaVars(formula, attrib);

/*		trace("formula resolved:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		trace("attrib:"); for (a in attrib.keys()) trace('  $a => ${attrib.get(a)}');
*/				
		// TODO: resolve time-identifiers!
		
		// TODO: generate static fields for changing formulas inside program at runtime!
		
		// TODO: generate getter for animated values by using formulas

		
		function pack2in1(name:String, x:ConfSubParam, y:ConfSubParam):String
		{
			var start = name; var end = name;
			var n:Int = x.n + y.n;
			if (x.isStart && !y.isStart) {
				if (n > 1) { start += ".x"; end += ".y"; }
				start = 'vec2( $start, ${Util.toFloatString(y.vStart)} )';
			}
			else if (!x.isStart && y.isStart) {
				if (n > 1) { start += ".x"; end += ".y"; }
				start = 'vec2( ${Util.toFloatString(x.vStart)}, $start )';
			}
			else if (!x.isStart && !y.isStart)
				start = 'vec2( ${Util.toFloatString(x.vStart)}, ${Util.toFloatString(y.vStart)} )';
			else if (n > 2) {
				start += ".xy"; end += ".z";
			}
			// ANIM
			if (x.isAnim || y.isAnim) {
				if (x.isEnd && !y.isEnd)       end = 'vec2( $end, ${Util.toFloatString(y.vEnd)} )';
				else if (!x.isEnd && y.isEnd)  end = 'vec2( ${Util.toFloatString(x.vEnd)}, $end )';
				else if (!x.isEnd && !y.isEnd) end = 'vec2( ${Util.toFloatString(x.vEnd)}, ${Util.toFloatString(y.vEnd)} )';
				else {
					if      (end == name+".y") end += "z";
					else if (end == name+".z") end += "w";
				}
				var tx = timers.indexOf(x.time);
				var ty = timers.indexOf(y.time);
				if (tx == -1)      start = '$start + ($end - $start) * vec2( 0.0, time$ty )';
				else if (ty == -1) start = '$start + ($end - $start) * vec2( time$tx, 0.0 )';
				else               start = '$start + ($end - $start) * vec2( time$tx, time$ty )';
			}
			return start;
		}
			
		function packForFormula(name:String, x:ConfSubParam, y:ConfSubParam):String
		{	
			if (x.formula == "" && y.formula == "" ) return pack2in1(name, x, y);
			
			var tmplvar = name.substr(1).toUpperCase();
			
			var fx = (x.name != "") ? formula.get(x.name) : Util.toFloatString(x.vStart);
			if (fx == null) fx = attrib.get(x.name);
			
			var fy = (y.name != "") ? formula.get(y.name) : Util.toFloatString(y.vStart);
			if (fy == null) fy = attrib.get(y.name);
			
			if (name == "aRotZ") {
				if (x.formula != "") fx = '($fx)/180.0*${Math.PI}';
				if (y.formula != "") fy = 'clamp( $fy/${Util.toFloatString(MAX_ZINDEX)}, -1.0, 1.0)';
			}
			
			var vecXstart = '::if ${tmplvar}X_FORMULA::::${tmplvar}X_FORMULA::::else::$fx::end::';
			var vecYstart = '::if ${tmplvar}Y_FORMULA::::${tmplvar}Y_FORMULA::::else::$fy::end::';
			return 'vec2($vecXstart, $vecYstart)';
		}		
		
		// size
		glConf.CALC_SIZE = "vec2 size = " + packForFormula("aSize", conf.sizeX, conf.sizeY) + ";";
		
		// pos
		glConf.CALC_POS = "vec2 pos = " + packForFormula("aPos", conf.posX,  conf.posY ) + ";" + "\n";
		
		// set varyings for vPos (before pos will be rotated!)
		if (conf.posX.isVarying || conf.posY.isVarying) {
			glConf.CALC_POS += "vPos = pos; ";
			glConf.OUT_VARYING += "::if isES3::flat ::end::::VAROUT:: vec2 vPos; ";
			glConf.IN_VARYING += "::if isES3::flat ::end::::VARIN:: vec2 vPos; ";
		}
		
		// rotation and zIndex
		conf.zIndex.vStart = Math.min(1.0,Math.max(-1.0, conf.zIndex.vStart/MAX_ZINDEX));
		conf.zIndex.vEnd   = Math.min(1.0,Math.max(-1.0, conf.zIndex.vEnd/MAX_ZINDEX));
		if (conf.rotation.name != "" || conf.zIndex.name != "") {
			conf.rotation.vStart = conf.rotation.vStart/180 * Math.PI;
			conf.rotation.vEnd   = conf.rotation.vEnd/180 * Math.PI;
			glConf.CALC_ROTZ  = "vec2 rotZ = " + packForFormula("aRotZ", conf.rotation, conf.zIndex ) + ";";
		}		
		if (conf.rotation.name != "") {
			var rotationmatrix = "mat2( vec2(cos(rotZ.x), -sin(rotZ.x)), vec2(sin(rotZ.x), cos(rotZ.x)) )";
			if (conf.pivotX.name != "" || conf.pivotY.name != "") {
				// pivot
				glConf.CALC_PIVOT = "vec2 pivot = " + packForFormula("aPivot", conf.pivotX,  conf.pivotY ) + ";";
				glConf.CALC_POS += 'pos = pos + (aPosition * size - pivot) * $rotationmatrix + pivot;';
			}
			else glConf.CALC_POS += 'pos = pos + aPosition * size * $rotationmatrix;';
		}
		else glConf.CALC_POS += "pos = pos + aPosition * size;";
		
		//z-index
		if (conf.zIndex.name != "") glConf.ZINDEX = "rotZ.y" else glConf.ZINDEX = Util.toFloatString(conf.zIndex.vStart);

		// set varyings for vSize, vRotZ or vPivot
		if (conf.sizeX.isVarying || conf.sizeY.isVarying) {
			glConf.CALC_SIZE += "vSize = size;";
			glConf.OUT_VARYING += "::if isES3::flat ::end::::VAROUT:: vec2 vSize; ";
			glConf.IN_VARYING += "::if isES3::flat ::end::::VARIN:: vec2 vSize; ";
		}
		if (conf.rotation.isVarying || conf.zIndex.isVarying) {
			glConf.CALC_ROTZ += "vRotZ = rotZ;";
			glConf.OUT_VARYING += "::if isES3::flat ::end::::VAROUT:: vec2 vRotZ; ";
			glConf.IN_VARYING += "::if isES3::flat ::end::::VARIN:: vec2 vRotZ; ";
		}
		if (conf.pivotX.isVarying || conf.pivotY.isVarying) {
			glConf.CALC_PIVOT += "vPivot = pivot;";
			glConf.OUT_VARYING += "::if isES3::flat ::end::::VAROUT:: vec2 vPivot; ";
			glConf.IN_VARYING += "::if isES3::flat ::end::::VARIN:: vec2 vPivot; ";
		}
		
		// color
		for (k in 0...conf.color.length) {
			var start = (conf.color[k].isStart) ? 'aColorStart${k}.wzyx' : Util.color2vec4(conf.color[k].vStart);
			if (conf.color[k].isAnim) {
				var end = (conf.color[k].isEnd) ? 'aColorEnd${k}.wzyx' : Util.color2vec4(conf.color[k].vEnd);
				start = '$start + ($end - $start) * time' + timers.indexOf(conf.color[k].time);
			}
			if (conf.color[k].n > 0 || conf.color[k].isAnim) {
				glConf.CALC_COLOR += 'vColor${k} = $start; ';
				glConf.FRAGMENT_CALC_COLOR += 'vec4 c${k} = vColor${k}; ';
			} else
				glConf.FRAGMENT_CALC_COLOR += 'vec4 c${k} = $start; ';
		}
		
		
		
		// ---------------- Varyings packing ---------
		var packedVaryings = new Array<{conf:ConfSubParam, formula:String}>();
		var packedTexVaryings = new Array<{conf:ConfSubParam, formula:String}>();
		var varyings = new StringMap<String>();						
		var texVaryings = new StringMap<String>();						

		function resolveVaryings(v:StringMap<String>, pv:Array<{conf:ConfSubParam, formula:String}>, confArray:Array<Array<ConfSubParam>>)
		{
			for (conf in confArray)
				for (c in conf) {
					if (c.isVarying ) {
						// varyings mapping
						var f = formula.get(c.name);
						if (f == null) f = attrib.get(c.name);
						if (c.isAnim || c.isStart || c.formula != "")
							pv.push({conf:c, formula:f});
						else v.set(c.name, f);
					}
				}
		}	
		resolveVaryings(varyings, packedVaryings, [conf.custom]);
		resolveVaryings(texVaryings, packedTexVaryings, [conf.texUnit, conf.texSlot, conf.texTile, conf.texX, conf.texY, conf.texW, conf.texH, conf.texPosX, conf.texPosY, conf.texSizeX, conf.texSizeY]);
		
		// traverse packedVaryings again and fill rest of varyings
		function fillVaryings(v:StringMap<String>, pv:Array<{conf:ConfSubParam, formula:String}>, isTex:Bool=false)
		{
			for (i in 0...pv.length) {
				var m = ['.x', '.y', '.z', '.w']; // TODO: make STATIC
				var c:ConfSubParam = pv[i].conf;

				var isLast:Bool = ( Std.int(i / 4) == Std.int((pv.length-1) / 4) ) ? true : false;
				
				if (i % 4 == 0) {
					var type = (isLast && (pv.length - 1) % 4 == 0 ) ? "float" : "vec" + ((isLast) ? pv.length - i : 4);
					if (isTex) {
						glConf.OUT_TEXVARYING += '::if isES3::flat ::end:: ::VAROUT:: $type vTexPack${Std.int(i / 4)};';
						glConf.IN_TEXVARYING  += '::if isES3::flat ::end:: ::VARIN:: $type vTexPack${Std.int(i / 4)};';
					} else {
						glConf.OUT_VARYING += '::if isES3::flat ::end:: ::VAROUT:: $type vPack${Std.int(i / 4)};';
						glConf.IN_VARYING  += '::if isES3::flat ::end:: ::VARIN:: $type vPack${Std.int(i / 4)};';						
					}
				}
				
				var ending:String = (isLast && (pv.length-1)%4 ==0 ) ? "" : m[i % 4];
				
				if (isTex) {
					glConf.CALC_TEXVARYING += "vTexPack" + Std.int(i / 4) + ending + ' = ' + pv[i].formula + ";";
					v.set(c.name, "vTexPack" + Std.int(i / 4) + ending);
				} else {
					glConf.CALC_VARYING += "vPack" + Std.int(i / 4) + ending + ' = ' + pv[i].formula + ";";
					v.set(c.name, "vTexPack" + Std.int(i / 4) + ending);
				}
			}	
		}
		fillVaryings(varyings, packedVaryings);
		fillVaryings(texVaryings, packedTexVaryings, true);
		
		trace("varyings:"); for (v in varyings.keys()) trace('  $v => ${varyings.get(v)}');			
		trace("-------"); 
		
		
		// texture layers
		if (!confTextureLayer.exists("__default__")) confTextureLayer.set("__default__",new StringMap<Int>());
		
		var resolveVaryingName = function(c:Array<ConfSubParam>, name:String, v:StringMap<Int>, dv:StringMap<Int>, d:String=""):String {
			if (v.exists(name)) return texVaryings.get(c[v.get(name)].name);
			else if (dv.exists(name)) return texVaryings.get(c[dv.get(name)].name);
			else return(d);
		}
		
		var dv = confTextureLayer.get("__default__");
		for (name in confTextureLayer.keys()) {
			//trace(name, confTextureLayer.get(name));
			var v:StringMap<Int> = confTextureLayer.get(name);
			
			var layer = (name == "__default__") ? maxLayer : v.get("layer");
			
			var unit = resolveVaryingName(conf.texUnit, "texUnit", v, dv, "0.0");

			var x  = "0.0";
			var y  = "0.0";
			var w = "::SLOTS_WIDTH::";
			var h = "::SLOTS_HEIGHT::";

			var slot = resolveVaryingName(conf.texSlot, "texSlot", v, dv);
			if (slot != "") {
				w = '::SLOT_WIDTH::';
				h = '::SLOT_HEIGHT::';
				//x  = 'mod(floor($slot), ::SLOTS_X::) * $w';
				x  = 'floor(mod($slot, ::SLOTS_X::)) * $w';
				y  = 'floor(floor($slot)/::SLOTS_X::) * $h';
			}
			
			var texX = resolveVaryingName(conf.texX, "texX", v, dv);
			var texY = resolveVaryingName(conf.texY, "texY", v, dv);
			if (texX != "") x = ((x != "0.0") ? '$x + ' : "") + "(" + texX + " / ::TEXTURE_WIDTH::)";
			if (texY != "") y = ((y != "0.0") ? '$y + ' : "") + "(" + texY + " / ::TEXTURE_HEIGHT::)";
			
			var texW = resolveVaryingName(conf.texW, "texW", v, dv);
			var texH = resolveVaryingName(conf.texH, "texH", v, dv);
			if (texW != "") w = '($texW / ::TEXTURE_WIDTH::)';
			if (texH != "") h = '($texH / ::TEXTURE_HEIGHT::)';
			
			var tile = resolveVaryingName(conf.texTile, "texTile", v, dv);
			if (tile != "") {
				w = '$w / ::TILES_X::';
				h = '$h / ::TILES_Y::';
				//x  = ((x != "0.0") ? '$x + ' : "") + 'mod(floor($tile), ::TILES_X::) * $w';				
				x  = ((x != "0.0") ? '$x + ' : "") + 'floor(mod($tile, ::TILES_X::)) * $w';
				// this all did not help on android (only highp float solves the modulo-precision-bug):
				//x  = ((x != "0.0") ? '$x + ' : "") + '(floor($tile) - ::TILES_X:: * floor($tile/::TILES_X::)) * $w';
				//x  = ((x != "0.0") ? '$x + ' : "") + 'floor(mod($tile/::TILES_X::, 1.0)*::TILES_X::) * $w';
				//x  = ((x != "0.0") ? '$x + ' : "") + 'floor(fract($tile/::TILES_X::)*::TILES_X::) * $w';
				needFragmentPrecision = true;
				y  = ((y != "0.0") ? '$y + ' : "") + 'floor(floor($tile) / ::TILES_X::) * $h';
			}
			
			var texCoordX = 'vTexCoord.x * $w';
			var texCoordY = 'vTexCoord.y * $h';
			
			var texPosX  = resolveVaryingName(conf.texPosX , "texPosX" , v, dv, "0.0");
			var texPosY  = resolveVaryingName(conf.texPosY , "texPosY" , v, dv, "0.0");
			if (texPosX != "0.0") texCoordX = '($texCoordX - $texPosX / ::TEXTURE_WIDTH::)';
			if (texPosY != "0.0") texCoordY = '($texCoordY - $texPosY / ::TEXTURE_HEIGHT::)';
			
			var texSizeX = resolveVaryingName(conf.texSizeX, "texSizeX", v, dv);
			var texSizeY = resolveVaryingName(conf.texSizeY, "texSizeY", v, dv);
			if (texSizeX != "") texCoordX = '$w * ::TEXTURE_WIDTH:: / $texSizeX * $texCoordX';
			if (texSizeY != "") texCoordY = '$h * ::TEXTURE_HEIGHT:: / $texSizeY * $texCoordY';
						
			if (texPosX != "0.0" || texPosY != "0.0" || texSizeX != "" || texSizeY != "") {
				if (options.texRepeatX && options.texRepeatY) {
					texCoordX = 'mod($texCoordX, $w)';
					texCoordY = 'mod($texCoordY, $h)';
				}
				else if (options.texRepeatX) texCoordX = 'mod($texCoordX, $w)';
				else if (options.texRepeatY) texCoordY = 'mod($texCoordY, $h)';
				texCoordX = 'clamp($texCoordX, 0.0, $w)';
				texCoordY = 'clamp($texCoordY, 0.0, $h)';
			}			
			
			if (x != "0.0") texCoordX = '$texCoordX + $x';
			if (y != "0.0") texCoordY = '$texCoordY + $y';				
			
			glConf.ELEMENT_LAYERS.push({
				UNIT: unit,
				TEXCOORD: 'vec2($texCoordX, $texCoordY)',
				if_ELEMENT_LAYER:  '::if (LAYER ${(name == "__default__") ? ">" : "="}= $layer)::',
				end_ELEMENT_LAYER: "::end::"
			});			
			
			// create static vars for texture identifiers
			if (name != "__default__") {
				fields.push({
					name:  "TEXTURE_" + name, //name.toUpperCase(),
					access:  [Access.APublic, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:String, macro $v{name}), 
					pos: Context.currentPos(),
				});
				debugLastField(fields);
			}
		}
		
		// create aditional static vars for texture identifiers
		for (name in defaultFormulaVars) {
			if (!confTextureLayer.exists(name)) {
				fields.push({
					name:  "TEXTURE_" + name, //name.toUpperCase(),
					access:  [Access.APublic, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:String, macro $v{name}), 
					pos: Context.currentPos(),
				});
				debugLastField(fields);				
			}
		}
		
		
		// TODO: handle custom attribute-names for shader-injection
		
		// create static vars for color identifiers that is additional inside DEFAULT_COLOR_VARS
		for (name in colorIdentifiers) // create static vars for color identifiers
			fields.push({
				name:  "COLOR_" + name, //.toUpperCase(),
				access:  [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{name}), 
				pos: Context.currentPos(),
			});					
		
		// put all texture identifiers inside a static string for progam
		// trace("textureIdentifiers:",textureIdentifiers);
		fields.push({
			name:  "IDENTIFIERS_TEXTURE",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{textureIdentifiers.join(",")}), 
			pos: Context.currentPos(),
		});
		
		// put all color identifiers inside a static string for progam
		// trace("colorIdentifiers", colorIdentifiers);
		fields.push({
			name:  "IDENTIFIERS_COLOR",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{colorIdentifiers.join(",")}), 
			pos: Context.currentPos(),
		});
		
		// set default color formula
		if (hasNoDefaultColorFormula) {
			fields.push({
				name:  "DEFAULT_COLOR_FORMULA",
				meta:  allowForBuffer,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{""}), 
				pos: Context.currentPos(),
			});
		}
		// set default texture colors (for formula)
		if (hasNoDefaultFormulaVars) {
			fields.push({
				name:  "DEFAULT_FORMULA_VARS",
				meta:  allowForBuffer,
				access:  [Access.APrivate, Access.AStatic],
				kind: FieldType.FVar(macro:haxe.ds.StringMap<peote.view.Color>, macro new haxe.ds.StringMap<peote.view.Color>()),
				pos: Context.currentPos(),
			});
		}
		// if modulo in glsl needs a 23-precision for float
		fields.push({
			name:  "NEED_FRAGMENT_PRECISION",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Bool, macro $v{needFragmentPrecision}),
			pos: Context.currentPos(),
		});
		
		// ---------------------- generate helper vars and functions ---------------------------
		debug("__generate vars and functions__");
		
		// add constructor ("new") if it is not there
		if (hasNoNew) {
			fields.push({
				name: "new",
				access: [Access.APublic],
				pos: Context.currentPos(),
				kind: FFun({
					args: [], // TODO: params for all that have @new meta
					expr: macro {},
					params: [],
					ret: null
				})
			});
			debugLastField(fields);
		}
		
		for (t in timers) {
			var name = Util.camelCase("time", t);
			genVar(macro:Float, name + "Start",    0.0);
			genVar(macro:Float, name + "Duration", 0.0);
			if (fieldnames.indexOf(name) == -1) {
				fields.push({
					name: name,
					access: [Access.APublic], //, Access.AInline
					pos: Context.currentPos(),
					kind: FFun({
						args:[ {name:"startTime", type:macro:Float},{name:"duration", type:macro:Float} ],
						expr:  macro {
							$i{name + "Start"} = startTime;
							$i{name + "Duration"} = duration;
						},
						ret: null
					})
				});
				debugLastField(fields);
			}
		}
		// @set
		for (name in setFun.keys()) {
			if (fieldnames.indexOf(name) == -1) {
				fields.push({
					name: name,
					access: [Access.APublic], //, Access.AInline
					pos: Context.currentPos(),
					kind: FFun({
						args: setFun.get(name).args,
						expr:  macro $b{setFun.get(name).expr},
						ret: null
					})
				});
				debugLastField(fields);
			}
		}
		// @anim
		for (name in animFun.keys()) {
			if (fieldnames.indexOf(name) == -1) {
				fields.push({
					name: name,
					access: [Access.APublic], //, Access.AInline
					pos: Context.currentPos(),
					kind: FFun({
						args: animFun.get(name).argsStart.concat(animFun.get(name).argsEnd),
						expr: macro $b{animFun.get(name).exprStart.concat(animFun.get(name).exprEnd)},
						ret: null
					})
				});
				debugLastField(fields);
			}
		}
		
		// getters for constant values (non anim)
		debug("__generate getter:");
		for (v in getterFun) genConstGetter(v.type, v.name, v.value);

		// setters for anim
		debug("__generate setter:");
		for (v in setterFun) genSetter(v);
		
		// start/end vars for animation attributes
		debug("__generate start/end vars for animation attributes:");
		function createStartEndVar(p:ConfSubParam, type:ComplexType, altType:ComplexType=null) {
			if (p.isAnim) {
				if (! p.isAltType) {
					genVar(type, p.name+"Start", p.vStart, !p.isStart);
					genVar(type, p.name+"End",   p.vEnd,   !p.isEnd);				
				}
				else {
					genVar(altType, p.name+"Start", p.vStart, !p.isStart);
					genVar(altType, p.name+"End",   p.vEnd,   !p.isEnd);				
				}
			}
		}
		createStartEndVar(conf.rotation, macro:Float);
		createStartEndVar(conf.zIndex,   macro:Int);
		createStartEndVar(conf.posX,  macro:Int, macro:Float);
		createStartEndVar(conf.posY,  macro:Int, macro:Float);
		createStartEndVar(conf.sizeX, macro:Int, macro:Float);
		createStartEndVar(conf.sizeY, macro:Int, macro:Float);
		createStartEndVar(conf.pivotX, macro:Int, macro:Float);
		createStartEndVar(conf.pivotY, macro:Int, macro:Float);		
		
		function createStartEndTexVar(pa:Array<ConfSubParam>, type:ComplexType, altType:ComplexType=null) {
			for (p in pa) if (p.isAnim) {
				if (! p.isAltType) {
					genVar(type, p.name+"Start", p.vStart, !p.isStart);
					genVar(type, p.name+"End",   p.vEnd,   !p.isEnd);				
				} else {
					genVar(altType, p.name+"Start", p.vStart, !p.isStart);
					genVar(altType, p.name+"End",   p.vEnd,   !p.isEnd);				
				}
			}
		}
		
		createStartEndTexVar(conf.color, macro:peote.view.Color);
		createStartEndTexVar(conf.texUnit, macro:Int);
		createStartEndTexVar(conf.texSlot, macro:Int);
		createStartEndTexVar(conf.texTile, macro:Int);
		createStartEndTexVar(conf.custom, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texX, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texY, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texW, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texH, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texPosX, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texPosY, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texSizeX, macro:Int, macro:Float);		
		createStartEndTexVar(conf.texSizeY, macro:Int, macro:Float);		
		
		// ------------------------- calc buffer size ----------------------------------------		
		var vertex_count:Int = 6;
		
		var buff_size_instanced:Int = Std.int(
			timers.length * 8
			+ 4 * (conf.rotation.n + conf.zIndex.n)
			+ ((conf.posX.isAltType) ? 4:2) * (conf.posX.n  + conf.posY.n)
			+ ((conf.sizeX.isAltType) ? 4:2) * (conf.sizeX.n + conf.sizeY.n)
			+ ((conf.pivotX.isAltType) ? 4:2) * (conf.pivotX.n + conf.pivotY.n)
		);
		for (c in conf.color)   buff_size_instanced += c.n * 4;
		
		// TODO: better packing
		for (attrib in packedAttribs.float) buff_size_instanced += attrib.length * 4;
		for (attrib in packedAttribs.short) buff_size_instanced += attrib.length * 2;
		for (attrib in packedAttribs.byte)  buff_size_instanced += attrib.length;
			
		var buff_size:Int = buff_size_instanced + 2;
		if (options.picking) buff_size += 4; // add size of elementId for picking
		
		//trace("buff_size_instanced", buff_size_instanced);
		//trace("buff_size", buff_size);
		
		var fillStride:Int = buff_size % 4;
		if (fillStride != 0) fillStride = 4 - fillStride;
		var fillStride_instanced:Int = buff_size_instanced % 4;
		if (fillStride_instanced != 0) fillStride_instanced = 4 - fillStride_instanced;
		
		buff_size += fillStride;
		buff_size_instanced += fillStride_instanced;
		//trace("fillStride_instanced",fillStride_instanced, "buff_size_instanced", buff_size_instanced);
		//trace("fillStride",fillStride, "buff_size", buff_size);
		
		// ---------------------- constants and switches -----------------------------------
		fields.push({
			name:  "MAX_ZINDEX",
			//meta:  allowForBuffer,
			access:  [Access.APublic, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{MAX_ZINDEX}),
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "ALPHA_ENABLED",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Bool, macro $v{options.alpha}),
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "ZINDEX_ENABLED",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Bool, macro $v{(conf.zIndex.name != "")}),
			pos: Context.currentPos(),
		});
		fields.push({
			name: "getZINDEX",
			meta:  allowForBuffer,
			access: [Access.APrivate, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: (conf.zIndex.name != "") ? macro return($i{conf.zIndex.name}) : macro return($v{Std.parseInt(conf.zIndex.vStart)}),
				ret: macro:Int
			})
		});
		fields.push({
			name:  "PICKING_ENABLED",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Bool, macro $v{options.picking}),
			pos: Context.currentPos(),
		});
		// ---------------------- vertex count and bufsize -----------------------------------
		fields.push({
			name:  "VERTEX_COUNT",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{vertex_count}), 
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "BUFF_SIZE",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{buff_size}), 
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "BUFF_SIZE_INSTANCED", // only for instanceDrawing
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{buff_size_instanced}), 
			pos: Context.currentPos(),
		});
		
		// ---------------------- bytePos and  dataPointer ----------------------------------
		fields.push({
			name:  "bytePos",
			meta:  allowForBuffer,
			access:  [Access.APrivate],
			kind: FieldType.FVar(macro:Int, macro $v{-1}), 
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "dataPointer",
			meta:  allowForBuffer,
			access:  [Access.APrivate],
			kind: FieldType.FVar(macro:peote.view.PeoteGL.DataPointer, null), 
			pos: Context.currentPos(),
		});
		
		// ---------------------- vertex attribute bindings ----------------------------------
		var attrNumber = 0;

		fields.push({
			name:  "aPOSITION",
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
			pos: Context.currentPos(),
		});
		if (conf.posX.n + conf.posY.n > 0) 
			fields.push({
				name:  "aPOS",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		if (conf.sizeX.n + conf.sizeY.n > 0)
			fields.push({
				name:  "aSIZE",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		if (conf.pivotX.n + conf.pivotY.n > 0)
			fields.push({
				name:  "aPIVOT",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		if (conf.rotation.n + conf.zIndex.n > 0)
			fields.push({
				name:  "aROTZ",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		// --------
		for (i in 0...Std.int((timers.length+1) / 2)) {
			fields.push({
				name:  "aTIME"+i,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}		
		// --------
		for (k in 0...conf.color.length) {
			if (conf.color[k].isStart) {
				fields.push({
					name:  "aCOLORSTART"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}
			if (conf.color[k].isEnd) {
				fields.push({
					name:  "aCOLOREND"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}
		}
		// --------
		// from packed attribs

		for (i in 0...packedAttribs.float.length) {
			fields.push({
				name:  "aFLOAT"+i,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}
		for (i in 0...packedAttribs.short.length) {
			fields.push({
				name:  "aSHORT"+i,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}
		for (i in 0...packedAttribs.byte.length) {
			fields.push({
				name:  "aBYTE"+i,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}
			
		if (options.picking)
			fields.push({
				name:  "aELEMENT",
				access:  [Access.APrivate, Access.AStatic, Access.AInline], // <-- for opengl-picking
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		debug("Number of vertex attributes:"+attrNumber);
		if (attrNumber >= 16) debug("WARNING: more then 16 vertex attributes not supported on most devices.");

		// -------------------------- instancedrawing --------------------------------------
		fields.push({
			name:  "instanceBytes", // only for instanceDrawing
			access:  [Access.APrivate, Access.AStatic],
			kind: FieldType.FVar(macro:utils.Bytes, macro null), 
			pos: Context.currentPos(),
		});
		fields.push({
			name: "createInstanceBytes", // only for instanceDrawing
			meta:  allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro {
					if (instanceBytes == null) {
						//trace("create bytes for instance GLbuffer");
						instanceBytes = utils.Bytes.alloc(VERTEX_COUNT * 2);
						instanceBytes.set(0 , 1); instanceBytes.set(1,  1);
						instanceBytes.set(2 , 1); instanceBytes.set(3,  1);
						instanceBytes.set(4 , 0); instanceBytes.set(5,  1);
						instanceBytes.set(6 , 1); instanceBytes.set(7,  0);
						instanceBytes.set(8 , 0); instanceBytes.set(9,  0);
						instanceBytes.set(10, 0); instanceBytes.set(11, 0);
					}
				},
				ret: null
			})
		});
		fields.push({
			name: "updateInstanceGLBuffer",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glInstanceBuffer", type:macro:peote.view.PeoteGL.GLBuffer}
				],
				expr: macro {
					//trace("fill full instance GLbuffer");
					gl.bindBuffer (gl.ARRAY_BUFFER, glInstanceBuffer);
					gl.bufferData (gl.ARRAY_BUFFER, instanceBytes.length, instanceBytes, gl.STATIC_DRAW);
					gl.bindBuffer (gl.ARRAY_BUFFER, null);
				},
				ret: null
			})
		});
		
		// ----------------------------- writeBytes -----------------------------------------
		function writeBytesExpr(verts:Array<Array<Int>> = null):Array<Expr> {
			var i:Int = 0;
			var exprBlock = new Array<Expr>();
			var len = 1;
			if (verts != null) len = verts.length;			
			for (j in 0...len)
			{
				// -------------- setInt32 ------------------------------
				// PICKING-ID
				if (verts != null && options.picking) {
					exprBlock.push( macro bytes.setInt32(bytePos + $v{i},  Std.int(1+bytePos/($v{buff_size*vertex_count})) ) ); i+=4;
				}				
				// COLOR
				for (k in 0...conf.color.length) {
					if (conf.color[k].isAnim && conf.color[k].isStart) { exprBlock.push( macro bytes.setInt32(bytePos + $v{i}, $i{conf.color[k].name+"Start"}) ); i+=4; }
					if (!conf.color[k].isAnim && conf.color[k].isStart){ exprBlock.push( macro bytes.setInt32(bytePos + $v{i}, $i{conf.color[k].name}) ); i+=4; }
					if (conf.color[k].isAnim && conf.color[k].isEnd)   { exprBlock.push( macro bytes.setInt32(bytePos + $v{i}, $i{conf.color[k].name+"End"}) ); i+=4; }
				}
				// -------------- setFloat (32) ------------------------------
				// TIMERS
				for (k in 0...timers.length) {
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{Util.camelCase("time",timers[k])+"Start"}) ); i+=4;
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{Util.camelCase("time",timers[k])+"Duration"}) ); i+=4;
				}
				// ROTZ
				if (conf.rotation.isAnim && conf.rotation.isStart) { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{conf.rotation.name+"Start"}/180*Math.PI) ); i+=4; }
				if (!conf.rotation.isAnim && conf.rotation.isStart){ exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{conf.rotation.name }/180*Math.PI) ); i+=4; }
				if (conf.zIndex.isAnim && conf.zIndex.isStart)     { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, Math.min(1.0,Math.max(-1.0, $i{conf.zIndex.name+"Start"}/MAX_ZINDEX))) ); i+=4; }
				if (!conf.zIndex.isAnim && conf.zIndex.isStart)    { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, Math.min(1.0,Math.max(-1.0, $i{conf.zIndex.name }/MAX_ZINDEX))) ); i+=4; }
				if (conf.rotation.isAnim && conf.rotation.isEnd)   { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{conf.rotation.name+"End"}/180*Math.PI) ); i+=4; }
				if (conf.zIndex.isAnim && conf.zIndex.isEnd)       { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, Math.min(1.0,Math.max(-1.0, $i{conf.zIndex.name+"End"}/MAX_ZINDEX))) ); i+=4; }
				
				// POS, SIZE, PIVOT -> Floats
				function write2packedFloat(a:ConfSubParam, b:ConfSubParam) {
					// attributes that are packed together should use same type
					if ((a.name != "" && b.name != "") && (a.isAltType != b.isAltType)) throw Context.error('Error: ${a.name} and ${b.name} has to be of the same type', a.pos);
					if ((a.name != "" && a.isAltType) || (b.name != "" && b.isAltType)) { // -> only the Float ones
						if (a.isAnim && a.isStart) { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{a.name+"Start"}) ); i+=4; }
						if (!a.isAnim && a.isStart){ exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{a.name })        ); i+=4; }
						if (b.isAnim && b.isStart) { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{b.name+"Start"}) ); i+=4; }
						if (!b.isAnim && b.isStart){ exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{b.name })        ); i+=4; }
						if (a.isAnim && a.isEnd)   { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{a.name+"End"})   ); i+=4; }
						if (b.isAnim && b.isEnd)   { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{b.name+"End"})   ); i+=4; }
					}
				}
				write2packedFloat(conf.posX  , conf.posY);
				write2packedFloat(conf.sizeX , conf.sizeY);
				write2packedFloat(conf.pivotX, conf.pivotY);				
			
				// packed float attribs
				for (attrib in packedAttribs.float) {
					for (m in attrib) {	
						if (m.isStart) {
							if (m.conf.isAnim)
							     { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{m.conf.name+"Start"}) ); i+=4; }
							else { exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{m.conf.name})         ); i+=4; }
						}
						else {     exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{m.conf.name+"End"})   ); i+=4; }
					}
				}
				
				// -------------- setUInt16 ------------------------------
				// POS, SIZE, PIVOT -> INT
				function write2packedInt(a:ConfSubParam, b:ConfSubParam) {
					if ((a.name != "" && !a.isAltType) || (b.name != "" && !b.isAltType)) {  // -> only the Int ones
						if (a.isAnim && a.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{a.name+"Start"}) ); i+=2; }
						if (!a.isAnim && a.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{a.name })        ); i+=2; }
						if (b.isAnim && b.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{b.name+"Start"}) ); i+=2; }
						if (!b.isAnim && b.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{b.name })        ); i+=2; }
						if (a.isAnim && a.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{a.name+"End"})   ); i+=2; }
						if (b.isAnim && b.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{b.name+"End"})   ); i+=2; }
					}
				}
				write2packedInt(conf.posX  , conf.posY);
				write2packedInt(conf.sizeX , conf.sizeY);
				write2packedInt(conf.pivotX, conf.pivotY);
							
				// packed short attribs
				for (attrib in packedAttribs.short) {
					for (m in attrib) {	
						if (m.isStart) {
							if (m.conf.isAnim)
							     { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{m.conf.name+"Start"}) ); i+=2; }
							else { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{m.conf.name})         ); i+=2; }
						}
						else {     exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{m.conf.name+"End"})   ); i+=2; }
					}
				}
				
				// POSITION for non-instancedrawing
				if (verts != null) {
					exprBlock.push( macro bytes.set(bytePos + $v{i}, $v{verts[j][0]}) ); i++;
					exprBlock.push( macro bytes.set(bytePos + $v{i}, $v{verts[j][1]}) ); i++;
				}
				
				// ----------------- Bytes --------------------------------
				// packed byte attribs
				for (attrib in packedAttribs.byte) {
					for (m in attrib) {	
						if (m.isStart) {
							if (m.conf.isAnim)
							     { exprBlock.push( macro bytes.set(bytePos + $v{i}, $i{m.conf.name+"Start"}) ); i++; }
							else { exprBlock.push( macro bytes.set(bytePos + $v{i}, $i{m.conf.name})         ); i++; }
						}
						else {     exprBlock.push( macro bytes.set(bytePos + $v{i}, $i{m.conf.name+"End"})   ); i++; }
					}
				}
				
				if (verts != null) i += fillStride;// else i += fillStride_instanced;
			}
			return exprBlock;
		}

		fields.push({
			name: "writeBytesInstanced",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"bytes", type:macro:utils.Bytes}
				],
				expr: macro $b{ writeBytesExpr() },
				ret: null
			})
		});
		// trace(new Printer().printField(fields[fields.length-1])); //debug
		// -------------------------	
		fields.push({
			name: "writeBytes",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"bytes", type:macro:utils.Bytes}
				],
				expr: macro $b{ writeBytesExpr([[1,1],[1,1],[0,1],[1,0],[0,0],[0,0]]) },
				ret: null
			})
		});
		// trace(new Printer().printField(fields[fields.length-1])); //debug
		// ----------------------------- updateGLBuffer -------------------------------------
		fields.push({
			name: "updateGLBuffer",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glBuffer", type:macro:peote.view.PeoteGL.GLBuffer},
				       {name:"elemBuffSize", type:macro:Int}
				],
				expr: macro {
					//trace("Element updateGLBuffer");
					gl.bindBuffer (gl.ARRAY_BUFFER, glBuffer);
					gl.bufferSubData(gl.ARRAY_BUFFER, bytePos, elemBuffSize, dataPointer );
					gl.bindBuffer (gl.ARRAY_BUFFER, null);
				},
				ret: null
			})
		});
		
		// ------------------ bind vertex attributes to program ----------------------------------
		function bindAttribLocationsExpr(isInstanced:Bool=false):Array<Expr> {
			var exprBlock = new Array<Expr>();
			// PICKING-ID
			if (!isInstanced && options.picking) exprBlock.push( macro gl.bindAttribLocation(glProgram, aELEMENT,  "aElement" ) );
			// COLOR
			for (k in 0...conf.color.length) {
				if (conf.color[k].isStart) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aCOLORSTART"+k}, $v{"aColorStart"+k} ) );
				if (conf.color[k].isEnd)   exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aCOLOREND"  +k}, $v{"aColorEnd"  +k} ) );
			}
			// TIMERS
			for (k in 0...Std.int((timers.length+1) / 2)) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTIME" + k}, $v{"aTime"+k} ) );
			// ROTZ
			if (conf.rotation.n + conf.zIndex.n > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aROTZ, "aRotZ") );
			// POS, SIZE, PIVOT
			if (conf.posX.n  + conf.posY.n  > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aPOS,  "aPos" ) );
			if (conf.sizeX.n + conf.sizeY.n > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aSIZE, "aSize") );
			if (conf.pivotX.n + conf.pivotY.n > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aPIVOT, "aPivot") );
			
			// packed attribs			
			for (k in 0...packedAttribs.float.length) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aFLOAT"+k}, $v{"aFloat"+k} ) );
			for (k in 0...packedAttribs.short.length) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aSHORT"+k}, $v{"aShort"+k} ) );
			for (k in 0...packedAttribs.byte.length)  exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aBYTE"+k},  $v{"aBYTE"+k} ) );
			
			// POSITION for non-instancedrawing
			exprBlock.push( macro gl.bindAttribLocation(glProgram, aPOSITION, "aPosition") );
			return exprBlock;
		}
		
		fields.push({
			name: "bindAttribLocations",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glProgram", type:macro:peote.view.PeoteGL.GLProgram}
				],
				expr: macro $b{ bindAttribLocationsExpr() },
				ret: null
			})
		});
		
		fields.push({
			name: "bindAttribLocationsInstanced",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glProgram", type:macro:peote.view.PeoteGL.GLProgram}
				],
				expr: macro $b{ bindAttribLocationsExpr(true) },
				ret: null
			})
		});
		//trace(new Printer().printField(fields[fields.length - 1])); //debug
		
		// ------------------------ enable/disable vertex attributes ------------------------------
		function enableVertexAttribExpr(isInstanced:Bool=false):Array<Expr> {
			var i:Int = 0;
			var n:Int = 0;
			var exprBlock = new Array<Expr>();
			var stride = buff_size;
			
			if (isInstanced) {
				exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glInstanceBuffer) );
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, 2, 0 ) );
				stride = buff_size_instanced;
			}
			
			exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer) );
			
			// -------------- setInt32 ------------------------------
			// PICKING ID
			if (!isInstanced && options.picking) {
				exprBlock.push( macro gl.enableVertexAttribArray (aELEMENT) );
				exprBlock.push( macro gl.vertexAttribPointer(aELEMENT, 4, gl.UNSIGNED_BYTE, true, $v{stride}, $v{i} ) ); i += 4;
			}
			// COLORS
			for (k in 0...conf.color.length) {
				if (conf.color[k].isStart) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aCOLORSTART"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aCOLORSTART"+k}, 4, gl.UNSIGNED_BYTE, true, $v{stride}, $v{i} ) ); i += 4;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aCOLORSTART"+k}, 1) );			
				}			
				if (conf.color[k].isEnd) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aCOLOREND"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aCOLOREND"+k}, 4, gl.UNSIGNED_BYTE, true, $v{stride}, $v{i} ) ); i += 4;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aCOLOREND"+k}, 1) );			
				}
			}
			
			// -------------- setFloat (32) ------------------------------
			// TIMERS
			for (k in 0...Std.int((timers.length+1) / 2) ) {
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTIME" + k}) );
				n = ((k==Std.int(timers.length / 2)) && (timers.length % 2 != 0)) ? 2 : 4;
				exprBlock.push( macro gl.vertexAttribPointer($i{"aTIME"+k}, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTIME"+k}, 1) );			
			}
			// ROTZ
			n = conf.rotation.n + conf.zIndex.n;
			if (n > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aROTZ) );
				exprBlock.push( macro gl.vertexAttribPointer(aROTZ, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aROTZ, 1) );			
			}
			
			// POS, SIZE, PIVOT -> FLOAT
			function enable2packFloat(attr:String, a:ConfSubParam, b:ConfSubParam) {
				if ((a.name != "" && a.isAltType) || (b.name != "" && b.isAltType)) { // -> only the Float ones
					n = a.n + b.n;
					if (n > 0 ) {
						exprBlock.push( macro gl.enableVertexAttribArray ($i{attr}) );
						exprBlock.push( macro gl.vertexAttribPointer($i{attr}, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
						if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{attr}, 1) );			
					}
				}
			}
			enable2packFloat("aPOS", conf.posX, conf.posY);
			enable2packFloat("aSIZE", conf.sizeX, conf.sizeY);
			enable2packFloat("aPIVOT", conf.pivotX, conf.pivotY);

			
			// packed float attribs
			for (k in 0...packedAttribs.float.length) {
				n = packedAttribs.float[k].length;
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aFLOAT"+k}) );
				exprBlock.push( macro gl.vertexAttribPointer($i{"aFLOAT"+k}, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aFLOAT"+k}, 1) );
			}
			
			// -------------- setUInt16 ------------------------------

			// POS, SIZE, PIVOT -> INT
			function enable2packInt(attr:String, a:ConfSubParam, b:ConfSubParam) {
				if ((a.name != "" && !a.isAltType) || (b.name != "" && !b.isAltType)) {  // -> only the Int ones
					n = a.n + b.n;
					if (n > 0 ) {
						exprBlock.push( macro gl.enableVertexAttribArray ($i{attr}) );
						exprBlock.push( macro gl.vertexAttribPointer($i{attr}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
						if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{attr}, 1) );			
					}
				}
			}
			enable2packInt("aPOS", conf.posX, conf.posY);
			enable2packInt("aSIZE", conf.sizeX, conf.sizeY);
			enable2packInt("aPIVOT", conf.pivotX, conf.pivotY);
			
			// packed short attribs
			for (k in 0...packedAttribs.short.length) {
				n = packedAttribs.short[k].length;
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aSHORT"+k}) );
				exprBlock.push( macro gl.vertexAttribPointer($i{"aSHORT"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aSHORT"+k}, 1) );
			}
			
			// POSITION for non-instancedrawing
			if (!isInstanced) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, $v{stride}, $v{i} )); i += 2;
			}

			// packed byte attribs
			for (k in 0...packedAttribs.byte.length) {
				n = packedAttribs.byte[k].length;
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aBYTE"+k}) );
				exprBlock.push( macro gl.vertexAttribPointer($i{"aBYTE"+k}, $v{n}, gl.UNSIGNED_BYTE, false, $v{stride}, $v{i} ) ); i += n;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aBYTE"+k}, 1) );
			}

			return exprBlock;
		}
		fields.push({
			name: "enableVertexAttribInstanced",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glBuffer", type:macro:peote.view.PeoteGL.GLBuffer},
				       {name:"glInstanceBuffer", type:macro:peote.view.PeoteGL.GLBuffer}
				],
				expr: macro $b{ enableVertexAttribExpr(true) },
				ret: null
			})
		});
		// trace(new Printer().printField(fields[fields.length-1])); //debug
		// -------------------------
		fields.push({
			name: "enableVertexAttrib",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glBuffer", type:macro:peote.view.PeoteGL.GLBuffer}
				],
				expr: macro $b{ enableVertexAttribExpr() },
				ret: null
			})
		});
		// trace(new Printer().printField(fields[fields.length-1])); //debug
		// -------------------------
		function disableVertexAttribExpr(isInstanced:Bool=false):Array<Expr> {
			var exprBlock = new Array<Expr>();
			// POSITION (instance or non-instancedrawing)
			exprBlock.push(  macro gl.disableVertexAttribArray (aPOSITION) );
			// PICKING ID
			if (!isInstanced && options.picking) exprBlock.push( macro gl.disableVertexAttribArray (aELEMENT) );
			// COLORS
			for (k in 0...conf.color.length) {
				if (conf.color[k].isStart) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aCOLORSTART"+k}) );
				if (conf.color[k].isEnd)   exprBlock.push( macro gl.disableVertexAttribArray ($i{"aCOLOREND"  +k}) );
			}
			// TIMERS
			for (k in 0...Std.int((timers.length+1) / 2)) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTIME"+k}) );
			// ROTZ
			if (conf.rotation.n + conf.zIndex.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aROTZ) );
			// POS, SIZE, PIVOT
			if (conf.posX.n  + conf.posY.n  > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aPOS) );
			if (conf.sizeX.n + conf.sizeY.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aSIZE) );
			if (conf.pivotX.n + conf.pivotY.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aPIVOT) );
			
			// packed attribs		
			for (k in 0...packedAttribs.float.length) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aFLOAT"+k}) );
			for (k in 0...packedAttribs.short.length) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aSHORT"+k}) );
			for (k in 0...packedAttribs.byte.length)  exprBlock.push( macro gl.disableVertexAttribArray ($i{"aBYTE"+k}) );			

			return exprBlock;
		}
		
		fields.push({
			name: "disableVertexAttribInstanced",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL}
				],
				expr: macro $b{ disableVertexAttribExpr(true) },
				ret: null
			})
		});
		// trace(new Printer().printField(fields[fields.length-1])); //debug
		fields.push({
			name: "disableVertexAttrib",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL}
				],
				expr: macro $b{ disableVertexAttribExpr() },
				ret: null
			})
		});
		// trace(new Printer().printField(fields[fields.length-1])); //debug
				
		// ----------------------- shader generation ------------------------
		fields.push({
			name:  "vertexShader",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{parseShader(Shader.vertexShader)}), 
			pos: Context.currentPos(),
		});
		//trace("ELEMENT ---------- \n"+parseShader(Shader.vertexShader));
		fields.push({
			name:  "fragmentShader",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{parseShader(Shader.fragmentShader)}),
			pos: Context.currentPos(),
		});
				
		return fields; // <------ classgeneration complete !
	}

}

#end