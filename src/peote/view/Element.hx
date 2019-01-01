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
	texUnitDefault:ConfSubParam,
	texUnit:Array<ConfSubParam>,
	texSlotDefault:ConfSubParam,
	texSlot:Array<ConfSubParam>,
	texTileDefault:ConfSubParam,
	texTile:Array<ConfSubParam>,
	texXDefault:ConfSubParam,
	texX:Array<ConfSubParam>,
	texYDefault:ConfSubParam,
	texY:Array<ConfSubParam>,
	texWDefault:ConfSubParam,
	texW:Array<ConfSubParam>,
	texHDefault:ConfSubParam,
	texH:Array<ConfSubParam>,
	colorDefault:ConfSubParam,
	color:Array<ConfSubParam>,
}
typedef ConfSubParam =
{
	vStart:Dynamic, vEnd:Dynamic, n:Int, isAnim:Bool, name:String, isStart:Bool, isEnd:Bool, time:String,
}

typedef GLConfParam =
{			isPICK:Bool,
			UNIFORM_TIME:String,
			ATTRIB_TIME:String, ATTRIB_SIZE:String, ATTRIB_POS:String, ATTRIB_COLOR:String, ATTRIB_ROTZ:String, ATTRIB_PIVOT:String,
			ATTRIB_UNIT:String, ATTRIB_SLOT:String, ATTRIB_TILE:String,
			ATTRIB_TEXX:String, ATTRIB_TEXY:String, ATTRIB_TEXW:String, ATTRIB_TEXH:String,
			OUT_COLOR:String, IN_COLOR:String, OUT_TEXCOORD:String, IN_TEXCOORD:String, ZINDEX:String,
			OUT_UNIT:String, IN_UNIT:String, OUT_SLOT:String, IN_SLOT:String, OUT_TILE:String, IN_TILE:String, 
			OUT_TEXX:String, IN_TEXX:String, OUT_TEXY:String, IN_TEXY:String, OUT_TEXW:String, IN_TEXW:String, OUT_TEXH:String, IN_TEXH:String, 
			FRAGMENT_CALC_COLOR:String,
			CALC_TIME:String, CALC_SIZE:String, CALC_POS:String, CALC_COLOR:String, CALC_ROTZ:String, CALC_PIVOT:String, CALC_TEXCOORD:String,
			CALC_UNIT:String, CALC_SLOT:String, CALC_TILE:String,
			CALC_TEXX:String, CALC_TEXY:String, CALC_TEXW:String, CALC_TEXH:String,
			ELEMENT_LAYERS:Array<{UNIT:String, end_ELEMENT_LAYER:String, if_ELEMENT_LAYER:String, TEXCOORD:String}>,
};

class ElementImpl
{
	static inline var MAX_ZINDEX:Int = 0x1FFFFF;
	
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
					default: return "";
				}
			}
			else return "";
		}
		else return null;
	}
		
	static inline function getAllMetaParams(f:Field, s:String):Null<Array<String>> {
		var pa:Null<Array<Expr>> = null;
		var found = false;
		for (m in f.meta) if (m.name == s || m.name == ':$s') { pa = m.params; found = true; break; }
		if (found) {
			var ret = new Array<String>();
			if (pa != null)
				for (p in pa)
					switch (p.expr) {
						case EConst(CString(value)): ret.push(value);
						case EConst(CInt(value)): ret.push(value);
						default:
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
	
	
	static function checkMetas(f:Field, expectedType:ComplexType, type:ComplexType, val:Expr, confItem:ConfSubParam, getter:String, setter:String)
	{
		if (confItem.name == "") confItem.name = f.name;
		else throw Context.error('Error: attribute already defined for "${f.name}"', f.pos);
		
		if (f.access.indexOf(Access.AStatic) != -1) throw Context.error('Error: "${f.name}" can not be static', f.pos);
		
		var printer = new Printer();
		
		var expType:String = switch(expectedType) {	case TPath(tp): tp.name; default: ""; }
		var hasType:String;
		
		if (type == null) { debug('set type of ${f.name} to ${printer.printComplexType(expectedType)}');
			type = expectedType;
			f.kind = FieldType.FVar( type, val );
		}
		else {
			hasType = switch(type) { case TPath(tp): tp.name; default: ""; }
			//trace('var ${f.name}: - type:${hasType} - expected type:${expType}');
			if (hasType != expType) throw Context.error('Error: type of "${f.name}" should be ${ printer.printComplexType(expectedType) }', f.pos);
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
		
		var param = getMetaParam(f, "time");
		if (param == null) param = getMetaParam(f, "anim"); // if no @time exists, use @anim instead
		if (param != null) {
			confItem.isAnim = true;
			if (timers.indexOf(param) == -1) timers.push( param );
			confItem.time = param;
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
				else confItem.vStart = (expType=="Int") ? Std.parseInt(param) : Std.parseFloat(param);
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
		//trace(confItem);
	}
	
	static function checkTexLayerMetas(meta:String, f:Field, expectedType:ComplexType, type:ComplexType, val:Expr, d:ConfSubParam, confItem:Array<ConfSubParam>, getter:String, setter:String):Bool
	{
		var metas:Array<String> = getAllMetaParams(f, meta);
		if (metas == null) return false;
		if (metas.length == 0) metas.push("__default__");
		for (name in metas) {
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
		var c = { vStart:d.vStart, vEnd:d.vEnd, n:d.n, isAnim:d.isAnim, name:d.name, isStart:d.isStart, isEnd:d.isEnd, time:d.time };
		checkMetas(f, expectedType, type, val, c , getter, setter);
		confItem.push(c);
		return true;
	}
	
	static function checkColorLayerMetas(meta:String, f:Field, expectedType:ComplexType, type:ComplexType, val:Expr, d:ConfSubParam, confItem:Array<ConfSubParam>, getter:String, setter:String):Bool
	{
		var metas:Array<String> = getAllMetaParams(f, meta);
		if (metas == null) return false;
		if (metas.length > 1) throw Context.error('Error: @color attributes needs only 1 identifier for use in colorFormula (default is allways "color")', f.pos);
		if (metas.length == 0) metas.push("color");
		var name = metas[0];
		if (Util.isWrongIdentifier(name)) throw Context.error('Error: "$name" is not an identifier, please use only letters/numbers or "_" (starting with a letter)', f.pos);
		if (colorIdentifiers.indexOf(name) >= 0) throw Context.error('Error: "$name" is already used for a @color identifier', f.pos);
		if (confTextureLayer.exists(name)) throw Context.error('Error: "$name" is already used as identifier for a texture-layer', f.pos);
		colorIdentifiers.push(name);
		var c = { vStart:d.vStart, vEnd:d.vEnd, n:d.n, isAnim:d.isAnim, name:d.name, isStart:d.isStart, isEnd:d.isEnd, time:d.time };
		checkMetas(f, expectedType, type, val, c , getter, setter);
		confItem.push(c);
		return true;
	}
	
	static inline function configure(f:Field, type:ComplexType, val:Expr, getter:String=null, setter:String=null)
	{	//trace(f.name, type, val, getter, setter);
		if      ( hasMeta(f, "posX")  ) checkMetas(f, macro:Int, type, val, conf.posX, getter, setter);
		else if ( hasMeta(f, "posY")  ) checkMetas(f, macro:Int, type, val, conf.posY, getter, setter);
		else if ( hasMeta(f, "sizeX") ) checkMetas(f, macro:Int, type, val, conf.sizeX, getter, setter);
		else if ( hasMeta(f, "sizeY") ) checkMetas(f, macro:Int, type, val, conf.sizeY, getter, setter);
		else if ( hasMeta(f, "pivotX") ) checkMetas(f, macro:Int, type, val, conf.pivotX, getter, setter);
		else if ( hasMeta(f, "pivotY") ) checkMetas(f, macro:Int, type, val, conf.pivotY, getter, setter);
		else if ( hasMeta(f, "rotation") ) checkMetas(f, macro:Float, type, val, conf.rotation, getter, setter);
		else if ( hasMeta(f, "zIndex") ) checkMetas(f, macro:Int, type, val, conf.zIndex, getter, setter);
		// texture layer attributes
		else if ( checkTexLayerMetas("texUnit", f, macro:Int, type, val, conf.texUnitDefault, conf.texUnit, getter, setter) ) {}
		else if ( checkTexLayerMetas("texSlot", f, macro:Int, type, val, conf.texSlotDefault, conf.texSlot, getter, setter) ) {}
		else if ( checkTexLayerMetas("texTile", f, macro:Int, type, val, conf.texTileDefault, conf.texTile, getter, setter) ) {}
		else if ( checkTexLayerMetas("texX",    f, macro:Int, type, val, conf.texXDefault, conf.texX, getter, setter) ) {}
		else if ( checkTexLayerMetas("texY",    f, macro:Int, type, val, conf.texYDefault, conf.texY, getter, setter) ) {}
		else if ( checkTexLayerMetas("texW",    f, macro:Int, type, val, conf.texWDefault, conf.texW, getter, setter) ) {}
		else if ( checkTexLayerMetas("texH",    f, macro:Int, type, val, conf.texHDefault, conf.texH, getter, setter) ) {}
		else if ( checkColorLayerMetas("color",   f, macro:Color, type, val, conf.colorDefault, conf.color, getter, setter) ) {}
	}
	

	static var setFun :StringMap<Dynamic>;
	static var animFun:StringMap<Dynamic>;
	
	static var getterFun:Array<Dynamic>;
	static var setterFun:Array<Dynamic>;
	
	static var timers:Array<String>;
	
	static var fieldnames:Array<String>;	
	static var fields:Array<Field>;
	
	static var conf:ConfParam;
	static var glConf:GLConfParam;
	
	static var maxLayer:Int = 0;
	static var confTextureLayer = new StringMap<StringMap<Int>>();
	static var textureIdentifiers = new Array<String>();
	static var colorIdentifiers = new Array<String>();
	
	//static var isChild:Bool = false;
	// -------------------------------------- BUILD -------------------------------------------------
	public static function build()
	{
		conf = {
			posX :{ vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },
			posY :{ vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },		
			sizeX:{ vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },
			sizeY:{ vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },
			pivotX:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },			
			pivotY:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },			
			rotation:{ vStart:0.0, vEnd:0.0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },			
			zIndex:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },			
			texUnitDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texUnit:[],
			texSlotDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texSlot:[],
			texTileDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texTile:[],
			texXDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texX:[],
			texYDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texY:[],
			texWDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texW:[],
			texHDefault:{ vStart:0, vEnd:0, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, texH:[],
			colorDefault:{ vStart:0xFF0000FF, vEnd:0xFF0000FF, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" }, color:[],
		};
		glConf = {
			isPICK:false,
			UNIFORM_TIME:"",
			ATTRIB_TIME:"", ATTRIB_SIZE:"", ATTRIB_POS:"", ATTRIB_COLOR:"", ATTRIB_ROTZ:"", ATTRIB_PIVOT:"",
			ATTRIB_UNIT:"", ATTRIB_SLOT:"", ATTRIB_TILE:"",
			ATTRIB_TEXX:"", ATTRIB_TEXY:"", ATTRIB_TEXW:"", ATTRIB_TEXH:"",
			OUT_COLOR:"", IN_COLOR:"", OUT_TEXCOORD:"", IN_TEXCOORD:"", ZINDEX:"",
			OUT_UNIT:"", IN_UNIT:"", OUT_SLOT:"", IN_SLOT:"", OUT_TILE:"", IN_TILE:"", 
			OUT_TEXX:"", IN_TEXX:"", OUT_TEXY:"", IN_TEXY:"", OUT_TEXW:"", IN_TEXW:"", OUT_TEXH:"", IN_TEXH:"", 
			FRAGMENT_CALC_COLOR:"",
			CALC_TIME:"", CALC_SIZE:"", CALC_POS:"", CALC_COLOR:"", CALC_ROTZ:"", CALC_PIVOT:"", CALC_TEXCOORD:"",
			CALC_UNIT:"", CALC_SLOT:"", CALC_TILE:"", CALC_TEXX:"", CALC_TEXY:"", CALC_TEXW:"", CALC_TEXH:"", 
			ELEMENT_LAYERS:[],
		};		
		setFun  = new StringMap<Dynamic>();
		animFun = new StringMap<Dynamic>();
		getterFun = new Array<Dynamic>();
		setterFun = new Array<Dynamic>();
		timers = new Array<String>();
		fieldnames = new Array<String>();	
		fields = Context.getBuildFields();
		
		var hasNoNew:Bool = true;		
		var hasNoDefaultColorFormula:Bool = true;		
		var hasNoDefaultFormulaVars:Bool = true;
		var defaultFormulaVars = new Array<String>();
		var classname:String = Context.getLocalClass().get().name;
		//var classpackage = Context.getLocalClass().get().pack;
		
		// TODO: Errormsg; "defines had to be in superclass" if found some metas in fields
		if (Context.getLocalClass().get().superClass != null) return fields;//isChild = true;
		
		debug('----- generating Class: $classname -----');
		
		for (f in fields)
		{	
			fieldnames.push(f.name);
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
												case EConst(CString(identifier)): defaultFormulaVars.push(identifier);
												default:
											}
										default:
									}
							default:
						}
					default:
				}
			}
			else switch (f.kind)
			{	
				case FVar(type, val)                 : configure(f, type, val);
				case FProp(getter, setter, type, val): configure(f, type, val, getter, setter);
				default: //trace(f.kind);
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
				glConf.OUT_COLOR += '::if isES3::flat::end:: ::VAROUT:: vec4 vColor${k};';
				glConf.IN_COLOR  += '::if isES3::flat::end:: ::VARIN::  vec4 vColor${k};';
			}
		}
		//TODO: better pack the attributes here ------------------------- 
		// units
		for (k in 0...conf.texUnit.length) {
			if (conf.texUnit[k].n > 0) {
				var type:String = (conf.texUnit[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_UNIT += '::IN:: $type aUnit${k};';
			}
			glConf.OUT_UNIT += '::if isES3::flat::end:: ::VAROUT:: float vUnit${k};';
			glConf.IN_UNIT  += '::if isES3::flat::end:: ::VARIN::  float vUnit${k};';
		}
		// slots
		for (k in 0...conf.texSlot.length) {
			if (conf.texSlot[k].n > 0) {
				var type:String = (conf.texSlot[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_SLOT += '::IN:: $type aSlot${k};';
			}
			glConf.OUT_SLOT += '::if isES3::flat::end:: ::VAROUT:: float vSlot${k};';
			glConf.IN_SLOT  += '::if isES3::flat::end:: ::VARIN::  float vSlot${k};';
		}
		// tiles
		for (k in 0...conf.texTile.length) {
			if (conf.texTile[k].n > 0) {
				var type:String = (conf.texTile[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_TILE += '::IN:: $type aTile${k};';
			}
			glConf.OUT_TILE += '::if isES3::flat::end:: ::VAROUT:: float vTile${k};';
			glConf.IN_TILE  += '::if isES3::flat::end:: ::VARIN::  float vTile${k};';
		}
		// texX
		for (k in 0...conf.texX.length) {
			if (conf.texX[k].n > 0) {
				var type:String = (conf.texX[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_TEXX += '::IN:: $type aTexX${k};';
			}
			glConf.OUT_TEXX += '::if isES3::flat::end:: ::VAROUT:: float vTexX${k};';
			glConf.IN_TEXX  += '::if isES3::flat::end:: ::VARIN::  float vTexX${k};';
		}
		// texY
		for (k in 0...conf.texY.length) {
			if (conf.texY[k].n > 0) {
				var type:String = (conf.texY[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_TEXY += '::IN:: $type aTexY${k};';
			}
			glConf.OUT_TEXY += '::if isES3::flat::end:: ::VAROUT:: float vTexY${k};';
			glConf.IN_TEXY  += '::if isES3::flat::end:: ::VARIN::  float vTexY${k};';
		}
		// texW
		for (k in 0...conf.texW.length) {
			if (conf.texW[k].n > 0) {
				var type:String = (conf.texW[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_TEXW += '::IN:: $type aTexW${k};';
			}
			glConf.OUT_TEXW += '::if isES3::flat::end:: ::VAROUT:: float vTexW${k};';
			glConf.IN_TEXW  += '::if isES3::flat::end:: ::VARIN::  float vTexW${k};';
		}
		// texH
		for (k in 0...conf.texH.length) {
			if (conf.texH[k].n > 0) {
				var type:String = (conf.texH[k].n == 1) ? "float" : "vec2";
				glConf.ATTRIB_TEXH += '::IN:: $type aTexH${k};';
			}
			glConf.OUT_TEXH += '::if isES3::flat::end:: ::VAROUT:: float vTexH${k};';
			glConf.IN_TEXH  += '::if isES3::flat::end:: ::VARIN::  float vTexH${k};';
		}
		
		glConf.OUT_TEXCOORD = "::VAROUT:: vec2 vTexCoord;";
		glConf.IN_TEXCOORD  = "::VARIN::  vec2 vTexCoord;";
		
		// CALC TIME-MUTLIPLICATORS:
		for (i in 0...timers.length) {
			var t:String = "" + Std.int(i / 2);
			var d:String = "" + Std.int(i / 2);
			if (i % 2 == 0) { t += ".x"; d += ".y"; } else { t += ".z"; d += ".w"; } 
			glConf.CALC_TIME += 'float time$i = clamp( (uTime - aTime$t) / aTime$d, 0.0, 1.0); ';
		}
		if (timers.length > 0) glConf.UNIFORM_TIME = "uniform float uTime;";
		
		// pack -----------------------------------------------------------------------
		function pack2in1(name:String, x:ConfSubParam, y:ConfSubParam):String {
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
				start= 'vec2( ${Util.toFloatString(x.vStart)}, ${Util.toFloatString(y.vStart)} )';
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
				if (tx == -1)      return '( $start + ($end - $start) * vec2( 0.0, time$ty ) )';
				else if (ty == -1) return '( $start + ($end - $start) * vec2( time$tx, 0.0 ) )';
				else               return '( $start + ($end - $start) * vec2( time$tx, time$ty ) )';
			} else return start;
		}
		
		// size
		glConf.CALC_SIZE = "vec2 size = aPosition * " + pack2in1("aSize", conf.sizeX, conf.sizeY) + ";";
		
		// rotation and zIndex
		conf.zIndex.vStart = Math.min(1.0,Math.max(-1.0, conf.zIndex.vStart/MAX_ZINDEX));
		conf.zIndex.vEnd   = Math.min(1.0,Math.max(-1.0, conf.zIndex.vEnd/MAX_ZINDEX));
		if (conf.rotation.name != "" || conf.zIndex.name != "") {
			conf.rotation.vStart = conf.rotation.vStart/180 * Math.PI;
			conf.rotation.vEnd   = conf.rotation.vEnd/180 * Math.PI;
			glConf.CALC_ROTZ  = "vec2 rotZ = " + pack2in1("aRotZ" , conf.rotation, conf.zIndex ) + ";";
		}
		if (conf.rotation.name != "") {
			var rotationmatrix = "mat2( vec2(cos(rotZ.x), -sin(rotZ.x)), vec2(sin(rotZ.x), cos(rotZ.x)) )";
			if (conf.pivotX.name != "" || conf.pivotY.name != "") {
				// pivot
				glConf.CALC_PIVOT = "vec2 pivot = " + pack2in1("aPivot" , conf.pivotX,  conf.pivotY ) + ";";
				glConf.CALC_ROTZ += ' size = (size-pivot) * $rotationmatrix + pivot;';
			}
			else glConf.CALC_ROTZ += ' size = size * $rotationmatrix;';
		}
		if (conf.zIndex.name != "") glConf.ZINDEX = "rotZ.y" else glConf.ZINDEX = Util.toFloatString(conf.zIndex.vStart);
		
		// pos
		glConf.CALC_POS  = "vec2 pos  = size + " + pack2in1("aPos" , conf.posX,  conf.posY ) + ";";

		// color
		//if (conf.color.length == 0) glConf.FRAGMENT_CALC_COLOR += 'vec4 c0 = ${color2vec4(conf.colorDefault.vStart)};';
		//else 
			for (k in 0...conf.color.length) {
				var start = (conf.color[k].isStart) ? 'aColorStart${k}.wzyx' : Util.color2vec4(conf.color[k].vStart);
				if (conf.color[k].isAnim) {
					var end = (conf.color[k].isEnd) ? 'aColorEnd${k}.wzyx' : Util.color2vec4(conf.color[k].vEnd);
					start = '$start + ($end - $start) * time' + timers.indexOf(conf.color[k].time);
				}
				if (conf.color[k].n > 0 || conf.color[k].isAnim) {
					glConf.CALC_COLOR += 'vColor${k} = $start;';
					glConf.FRAGMENT_CALC_COLOR += 'vec4 c${k} = vColor${k};';
				} else
					glConf.FRAGMENT_CALC_COLOR += 'vec4 c${k} = $start;';
			}
		
		// ------- TODO make that packs all units, slots and tiles together into many aUnitSlotTile vec4 attributes --------- 
		function packTex(name:String, confItems:Array<ConfSubParam>, index:Int):String {
			name += index;
			var confItem:ConfSubParam = confItems[index];
			var start = (confItem.isStart) ? name : Util.toFloatString(confItem.vStart);
			if (confItem.isAnim) {
				var end = (confItem.isEnd) ? name : Util.toFloatString(confItem.vEnd);				
				if (confItem.isStart && confItem.isEnd) { start += ".x"; end += ".y"; }
				else if (confItem.isEnd) { end += ".x"; }
				start = '$start + ($end - $start) * time' + timers.indexOf(confItem.time);
			}
			return start;
		}
		// texUnit
		for (k in 0...conf.texUnit.length) {
			glConf.CALC_UNIT += 'vUnit$k = ' + packTex("aUnit", conf.texUnit, k) + ";";
		}		
		// texSlot
		for (k in 0...conf.texSlot.length) {
			glConf.CALC_SLOT += 'vSlot$k = ' + packTex("aSlot", conf.texSlot, k) + ";";
		}		
		// texTile
		for (k in 0...conf.texTile.length) {
			glConf.CALC_TILE += 'vTile$k = ' + packTex("aTile", conf.texTile, k) + ";";
		}
		// texX
		for (k in 0...conf.texX.length) {
			glConf.CALC_TEXX += 'vTexX$k = ' + packTex("aTexX", conf.texX, k) + ";";
		}
		// texY
		for (k in 0...conf.texY.length) {
			glConf.CALC_TEXY += 'vTexY$k = ' + packTex("aTexY", conf.texY, k) + ";";
		}
		// texW
		for (k in 0...conf.texW.length) {
			glConf.CALC_TEXW += 'vTexW$k = ' + packTex("aTexW", conf.texW, k) + ";";
		}
		// texH
		for (k in 0...conf.texH.length) {
			glConf.CALC_TEXH += 'vTexH$k = ' + packTex("aTexH", conf.texH, k) + ";";
		}
		// default texcoords
		glConf.CALC_TEXCOORD  = "vTexCoord = aPosition;";
		
		// TODO: colors
		
		// for each texture layers
		var default_unit = "";
		var default_slot = "";
		var default_tile = "";
		var default_texX = "";
		var default_texY = "";
		var default_texW = "";
		var default_texH = "";
		if (confTextureLayer.exists("__default__")) {
			var defaultLayer = confTextureLayer.get("__default__");
			if (defaultLayer.exists("texUnit")) default_unit += defaultLayer.get("texUnit");
			if (defaultLayer.exists("texSlot")) default_slot += defaultLayer.get("texSlot");
			if (defaultLayer.exists("texTile")) default_tile += defaultLayer.get("texTile");
			if (defaultLayer.exists("texX")) default_texX += defaultLayer.get("texX");
			if (defaultLayer.exists("texY")) default_texY += defaultLayer.get("texY");
			if (defaultLayer.exists("texW")) default_texW += defaultLayer.get("texW");
			if (defaultLayer.exists("texH")) default_texH += defaultLayer.get("texH");
		} else {
			confTextureLayer.set("__default__",new StringMap<Int>());
		}
		
		for (name in confTextureLayer.keys()) {
			//trace(name, confTextureLayer.get(name));
			var v:StringMap<Int> = confTextureLayer.get(name);
			
			var layer = (name == "__default__") ? maxLayer : v.get("layer");
			
			var unit = "vUnit";
			if (v.exists("texUnit")) unit += v.get("texUnit");
			else if (default_unit != "") unit += default_unit;
			else unit = "0.0";
			
			var texPosX  = "0.0";
			var texPosY  = "0.0";
			var texSizeW = "::SLOTS_WIDTH::";
			var texSizeH = "::SLOTS_HEIGHT::";

			var slot = "vSlot";
			if (v.exists("texSlot")) slot += v.get("texSlot");
			else if (default_slot != "") slot += default_slot;
			else slot = "";
			if (slot != "") {
				texSizeW = '::SLOT_WIDTH::';
				texSizeH = '::SLOT_HEIGHT::';
				texPosX  = ((texPosX != "0.0") ? '$texPosX + ' : "") + 'mod(floor($slot), ::SLOTS_X::) * $texSizeW';
				texPosY  = ((texPosY != "0.0") ? '$texPosY + ' : "") + 'floor(floor($slot)/::SLOTS_X::) * $texSizeH';
			}
			
			var texX = "vTexX";
			if (v.exists("texX")) texX += v.get("texX");
			else if (default_texX != "") texX += default_texX;
			else texX = "";
			if (texX != "") texPosX = ((texPosX != "0.0") ? '$texPosX + ' : "") + texX;
						
			var texY = "vTexY";
			if (v.exists("texY")) texY += v.get("texY");
			else if (default_texY != "") texY += default_texY;
			else texY = "";
			if (texY != "") texPosY = ((texPosY != "0.0") ? '$texPosY + ' : "") + texY;
			
			var texW = "vTexW";
			if (v.exists("texW")) texW += v.get("texW");
			else if (default_texW != "") texW += default_texW;
			else texW = "";
			if (texW != "") texSizeW = texW;
			
			var texH = "vTexH";
			if (v.exists("texH")) texH += v.get("texH");
			else if (default_texH != "") texH += default_texH;
			else texH = "";
			if (texH != "") texSizeH = texH;
			
			
			var tile = "vTile";
			if (v.exists("texTile")) tile += v.get("texTile");
			else if (default_tile != "") tile += default_tile;
			else tile = "";
			if (tile != "") {
				texSizeW = '$texSizeW / ::TILES_X::';
				texSizeH = '$texSizeH / ::TILES_Y::';
				texPosX  = ((texPosX != "0.0") ? '$texPosX + ' : "") + 'mod(floor($tile), ::TILES_X::) * $texSizeW';
				texPosY  = ((texPosY != "0.0") ? '$texPosY + ' : "") + 'floor(floor($tile)/::TILES_X::) * $texSizeH';
			}
			
			var texPos = (texPosX != "0.0" || texPosY != "0.0") ? '+ vec2($texPosX, $texPosY)' : "";
			glConf.ELEMENT_LAYERS.push({
				UNIT:unit,
				TEXCOORD:'(vTexCoord * vec2($texSizeW, $texSizeH) $texPos) / vec2(::TEXTURE_WIDTH::, ::TEXTURE_HEIGHT::)',
				if_ELEMENT_LAYER:'::if (LAYER ${(name == "__default__") ? ">" : "="}= $layer)::',
				end_ELEMENT_LAYER:"::end::"
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
		// create static vars for texture identifiers that is additional inside DEFAULT_FORMULA_VARS
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
				kind: FieldType.FVar(macro:haxe.ds.StringMap<Color>, macro new haxe.ds.StringMap<Color>()),
				pos: Context.currentPos(),
			});
		}
		
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
		for (v in getterFun) genConstGetter(v.type, v.name, v.value);
		
		// setters for anim
		for (v in setterFun) genSetter(v);
		
		// start/end vars for animation attributes - TODO: do in loop also for optimizing macro
		if (conf.posX.isAnim) {
			genVar(macro:Int, conf.posX.name+"Start", conf.posX.vStart, !conf.posX.isStart);
			genVar(macro:Int, conf.posX.name+"End",   conf.posX.vEnd,   !conf.posX.isEnd);
		}
		if (conf.posY.isAnim) {
			genVar(macro:Int, conf.posY.name+"Start", conf.posY.vStart, !conf.posY.isStart);
			genVar(macro:Int, conf.posY.name+"End",   conf.posY.vEnd,   !conf.posY.isEnd);
		}
		
		if (conf.sizeX.isAnim) {
			genVar(macro:Int, conf.sizeX.name+"Start", conf.sizeX.vStart, !conf.sizeX.isStart);
			genVar(macro:Int, conf.sizeX.name+"End",   conf.sizeX.vEnd,   !conf.sizeX.isEnd);
		}
		if (conf.sizeY.isAnim) {
			genVar(macro:Int, conf.sizeY.name+"Start", conf.sizeY.vStart, !conf.sizeY.isStart);
			genVar(macro:Int, conf.sizeY.name+"End",   conf.sizeY.vEnd,   !conf.sizeY.isEnd);
		}
		if (conf.rotation.isAnim) {
			genVar(macro:Float, conf.rotation.name+"Start", conf.rotation.vStart, !conf.rotation.isStart);
			genVar(macro:Float, conf.rotation.name+"End",   conf.rotation.vEnd,   !conf.rotation.isEnd);
		}
		if (conf.zIndex.isAnim) {
			genVar(macro:Int, conf.zIndex.name+"Start", conf.zIndex.vStart, !conf.zIndex.isStart);
			genVar(macro:Int, conf.zIndex.name+"End",   conf.zIndex.vEnd,   !conf.zIndex.isEnd);
		}
		if (conf.pivotX.isAnim) {
			genVar(macro:Int, conf.pivotX.name+"Start", conf.pivotX.vStart, !conf.pivotX.isStart);
			genVar(macro:Int, conf.pivotX.name+"End",   conf.pivotX.vEnd,   !conf.pivotX.isEnd);
		}
		if (conf.pivotY.isAnim) {
			genVar(macro:Int, conf.pivotY.name+"Start", conf.pivotY.vStart, !conf.pivotY.isStart);
			genVar(macro:Int, conf.pivotY.name+"End",   conf.pivotY.vEnd,   !conf.pivotY.isEnd);
		}		
		for (c in conf.color) if (c.isAnim) {
			genVar(macro:Color, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Color, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texUnit) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texSlot) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texTile) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texX) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texY) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texW) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		for (c in conf.texH) if (c.isAnim) {		
			genVar(macro:Int, c.name+"Start", c.vStart, !c.isStart);
			genVar(macro:Int, c.name+"End",   c.vEnd,   !c.isEnd);
		}
		
		// ------------------------- calc buffer size ----------------------------------------		
		var vertex_count:Int = 6;
		
		var buff_size_instanced:Int = Std.int(timers.length * 8
			+ 4 * (conf.rotation.n + conf.zIndex.n)
			+ 2 * (conf.posX.n  + conf.posY.n)
			+ 2 * (conf.sizeX.n + conf.sizeY.n)
			+ 2 * (conf.pivotX.n + conf.pivotY.n)
		);
		for (c in conf.color) buff_size_instanced += Std.int(c.n * 4);
		for (c in conf.texUnit) buff_size_instanced += Std.int(c.n);
		for (c in conf.texSlot) buff_size_instanced += Std.int(c.n * 2);
		for (c in conf.texTile) buff_size_instanced += Std.int(c.n * 2);
		for (c in conf.texX) buff_size_instanced += Std.int(c.n * 2);
		for (c in conf.texY) buff_size_instanced += Std.int(c.n * 2);
		for (c in conf.texW) buff_size_instanced += Std.int(c.n * 2);
		for (c in conf.texH) buff_size_instanced += Std.int(c.n * 2);
		
		var buff_size:Int = buff_size_instanced +2;
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
			kind: FieldType.FVar(macro:Bool, macro $v{(conf.color.length > 0)}), 
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "ZINDEX_ENABLED",
			meta:  allowForBuffer,
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Bool, macro $v{(conf.zIndex.name != "")}), 
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
		for (i in 0...Std.int((timers.length+1) / 2)) {
			fields.push({
				name:  "aTIME"+i,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}
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
		for (k in 0...conf.texUnit.length) {
			if (conf.texUnit[k].n > 0) {
				fields.push({
					name:  "aUNIT"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
		for (k in 0...conf.texSlot.length) {
			if (conf.texSlot[k].n > 0) {
				fields.push({
					name:  "aSLOT"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
		for (k in 0...conf.texTile.length) {
			if (conf.texTile[k].n > 0) {
				fields.push({
					name:  "aTILE"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
		for (k in 0...conf.texX.length) {
			if (conf.texX[k].n > 0) {
				fields.push({
					name:  "aTEXX"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
		for (k in 0...conf.texY.length) {
			if (conf.texY[k].n > 0) {
				fields.push({
					name:  "aTEXY"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
		for (k in 0...conf.texW.length) {
			if (conf.texW[k].n > 0) {
				fields.push({
					name:  "aTEXW"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
		for (k in 0...conf.texH.length) {
			if (conf.texH[k].n > 0) {
				fields.push({
					name:  "aTEXH"+k,
					access:  [Access.APrivate, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
					pos: Context.currentPos(),
				});
			}			
		}
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
						trace("create bytes for instance GLbuffer");
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
					trace("fill full instance GLbuffer");
					gl.bindBuffer (gl.ARRAY_BUFFER, glInstanceBuffer);
					gl.bufferData (gl.ARRAY_BUFFER, instanceBytes.length, instanceBytes, gl.STATIC_DRAW);
					gl.bindBuffer (gl.ARRAY_BUFFER, null);
				},
				ret: null
			})
		});
		
		// ----------------------------- writeBytes -----------------------------------------
		function writeBytesExpr(verts:Array<Array<Int>>=null):Array<Expr> {
			var i:Int = 0;
			var exprBlock = new Array<Expr>();
			var len = 1;
			if (verts != null) len = verts.length;			
			for (j in 0...len)
			{
				// -------------- setInt32 ------------------------------
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
				
				// -------------- setUInt16 ------------------------------
				// POSITION for non-instancedrawing
				if (verts != null) {
					exprBlock.push( macro bytes.set(bytePos + $v{i}, $v{verts[j][0]}) ); i++;
					exprBlock.push( macro bytes.set(bytePos + $v{i}, $v{verts[j][1]}) ); i++;
				}
				
				// POS
				if (conf.posX.isAnim && conf.posX.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name+"Start"}) ); i+=2; }
				if (!conf.posX.isAnim && conf.posX.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name }) ); i+=2; }
				if (conf.posY.isAnim && conf.posY.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name+"Start"}) ); i+=2; }
				if (!conf.posY.isAnim && conf.posY.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name }) ); i+=2; }
				if (conf.posX.isAnim && conf.posX.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name+"End"}) ); i+=2; }
				if (conf.posY.isAnim && conf.posY.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name+"End"}) ); i+=2; }
				// SIZE
				if (conf.sizeX.isAnim && conf.sizeX.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name+"Start"}) ); i+=2; }
				if (!conf.sizeX.isAnim && conf.sizeX.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name}) ); i+=2; }
				if (conf.sizeY.isAnim && conf.sizeY.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name+"Start"}) ); i+=2; }
				if (!conf.sizeY.isAnim && conf.sizeY.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name}) ); i+=2; }
				if (conf.sizeX.isAnim && conf.sizeX.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name+"End"}) ); i+=2; }
				if (conf.sizeY.isAnim && conf.sizeY.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name+"End"}) ); i+=2; }
				// PIVOT
				if (conf.pivotX.isAnim && conf.pivotX.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.pivotX.name+"Start"}) ); i+=2; }
				if (!conf.pivotX.isAnim && conf.pivotX.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.pivotX.name}) ); i+=2; }
				if (conf.pivotY.isAnim && conf.pivotY.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.pivotY.name+"Start"}) ); i+=2; }
				if (!conf.pivotY.isAnim && conf.pivotY.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.pivotY.name}) ); i+=2; }
				if (conf.pivotX.isAnim && conf.pivotX.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.pivotX.name+"End"}) ); i+=2; }
				if (conf.pivotY.isAnim && conf.pivotY.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.pivotY.name+"End"}) ); i+=2; }
				
				// SLOTS
				for (k in 0...conf.texSlot.length) {
					if (conf.texSlot[k].isAnim && conf.texSlot[k].isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texSlot[k].name+"Start"}) ); i+=2; }
					if (!conf.texSlot[k].isAnim && conf.texSlot[k].isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texSlot[k].name}) ); i+=2; }
					if (conf.texSlot[k].isAnim && conf.texSlot[k].isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texSlot[k].name+"End"}) ); i+=2; }
				}
				// TILES
				for (k in 0...conf.texTile.length) {
					if (conf.texTile[k].isAnim && conf.texTile[k].isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texTile[k].name+"Start"}) ); i+=2; }
					if (!conf.texTile[k].isAnim && conf.texTile[k].isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texTile[k].name}) ); i+=2; }
					if (conf.texTile[k].isAnim && conf.texTile[k].isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texTile[k].name+"End"}) ); i+=2; }
				}
				// TEXX
				for (k in 0...conf.texX.length) {
					if (conf.texX[k].isAnim && conf.texX[k].isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texX[k].name+"Start"}) ); i+=2; }
					if (!conf.texX[k].isAnim && conf.texX[k].isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texX[k].name}) ); i+=2; }
					if (conf.texX[k].isAnim && conf.texX[k].isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texX[k].name+"End"}) ); i+=2; }
				}
				// TEXY
				for (k in 0...conf.texY.length) {
					if (conf.texY[k].isAnim && conf.texY[k].isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texY[k].name+"Start"}) ); i+=2; }
					if (!conf.texY[k].isAnim && conf.texY[k].isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texY[k].name}) ); i+=2; }
					if (conf.texY[k].isAnim && conf.texY[k].isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texY[k].name+"End"}) ); i+=2; }
				}
				// TEXW
				for (k in 0...conf.texW.length) {
					if (conf.texW[k].isAnim && conf.texW[k].isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texW[k].name+"Start"}) ); i+=2; }
					if (!conf.texW[k].isAnim && conf.texW[k].isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texW[k].name}) ); i+=2; }
					if (conf.texW[k].isAnim && conf.texW[k].isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texW[k].name+"End"}) ); i+=2; }
				}
				// TEXH
				for (k in 0...conf.texH.length) {
					if (conf.texH[k].isAnim && conf.texH[k].isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texH[k].name+"Start"}) ); i+=2; }
					if (!conf.texH[k].isAnim && conf.texH[k].isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texH[k].name}) ); i+=2; }
					if (conf.texH[k].isAnim && conf.texH[k].isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.texH[k].name+"End"}) ); i+=2; }
				}
				
				// ----------------- Bytes --------------------------------
				// UNITS
				for (k in 0...conf.texUnit.length) {
					if (conf.texUnit[k].isAnim && conf.texUnit[k].isStart) { exprBlock.push( macro bytes.set(bytePos + $v{i}, $i{conf.texUnit[k].name+"Start"}) ); i++; }
					if (!conf.texUnit[k].isAnim && conf.texUnit[k].isStart){ exprBlock.push( macro bytes.set(bytePos + $v{i}, $i{conf.texUnit[k].name}) ); i++; }
					if (conf.texUnit[k].isAnim && conf.texUnit[k].isEnd)   { exprBlock.push( macro bytes.set(bytePos + $v{i}, $i{conf.texUnit[k].name+"End"}) ); i++; }
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
		var exprBlock = [ macro gl.bindAttribLocation(glProgram, aPOSITION, "aPosition") ];
		if (conf.posX.n  + conf.posY.n  > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aPOS,  "aPos" ) );
		if (conf.sizeX.n + conf.sizeY.n > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aSIZE, "aSize") );
		if (conf.pivotX.n + conf.pivotY.n > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aPIVOT, "aPivot") );
		if (conf.rotation.n + conf.zIndex.n > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aROTZ, "aRotZ") );
		for (k in 0...Std.int((timers.length+1) / 2)) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTIME" + k}, $v{"aTime"+k} ) );
		for (k in 0...conf.color.length) {
			if (conf.color[k].isStart) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aCOLORSTART"+k}, $v{"aColorStart"+k} ) );
			if (conf.color[k].isEnd)   exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aCOLOREND"  +k}, $v{"aColorEnd"  +k} ) );
		}
		for (k in 0...conf.texUnit.length) if (conf.texUnit[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aUNIT"+k}, $v{"aUnit"+k} ) );
		for (k in 0...conf.texSlot.length) if (conf.texSlot[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aSLOT"+k}, $v{"aSLOT"+k} ) );
		for (k in 0...conf.texTile.length) if (conf.texTile[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTILE"+k}, $v{"aTILE"+k} ) );
		for (k in 0...conf.texX.length) if (conf.texX[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTEXX"+k}, $v{"aTEXX"+k} ) );
		for (k in 0...conf.texY.length) if (conf.texY[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTEXY"+k}, $v{"aTEXY"+k} ) );
		for (k in 0...conf.texW.length) if (conf.texW[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTEXW"+k}, $v{"aTEXW"+k} ) );
		for (k in 0...conf.texH.length) if (conf.texH[k].n > 0) exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTEXH"+k}, $v{"aTEXH"+k} ) );
		
		fields.push({
			name: "bindAttribLocations",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glProgram", type:macro:peote.view.PeoteGL.GLProgram}
				],
				expr: macro $b{exprBlock},
				ret: null
			})
		});
				
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
			
			// COLOR
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
			// POSITION for non-instancedrawing
			if (!isInstanced) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, $v{stride}, $v{i} )); i += 2;
			}
			// POS
			n = conf.posX.n + conf.posY.n;
			if (n > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOS) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOS, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aPOS, 1) );			
			}
			// SIZE
			n = conf.sizeX.n + conf.sizeY.n;
			if (n > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aSIZE) );
				exprBlock.push( macro gl.vertexAttribPointer(aSIZE, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aSIZE, 1) );			
			}
			// PIVOT
			n = conf.pivotX.n + conf.pivotY.n;
			if (n > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPIVOT) );
				exprBlock.push( macro gl.vertexAttribPointer(aPIVOT, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aPIVOT, 1) );			
			}
			// SLOT
			for (k in 0...conf.texSlot.length) {
				n = conf.texSlot[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aSLOT"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aSLOT"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aSLOT"+k}, 1) );
				}
			}
			// TILE
			for (k in 0...conf.texTile.length) {
				n = conf.texTile[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTILE"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aTILE"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTILE"+k}, 1) );
				}
			}
			// TEXX
			for (k in 0...conf.texX.length) {
				n = conf.texX[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTEXX"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aTEXX"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTEXX"+k}, 1) );
				}
			}
			// TEXY
			for (k in 0...conf.texY.length) {
				n = conf.texY[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTEXY"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aTEXY"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTEXY"+k}, 1) );
				}
			}
			// TEXW
			for (k in 0...conf.texW.length) {
				n = conf.texW[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTEXW"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aTEXW"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTEXW"+k}, 1) );
				}
			}
			// TEXH
			for (k in 0...conf.texH.length) {
				n = conf.texH[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTEXH"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aTEXH"+k}, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTEXH"+k}, 1) );
				}
			}
			// UNIT
			for (k in 0...conf.texUnit.length) {
				n = conf.texUnit[k].n;
				if (n > 0 ) {
					exprBlock.push( macro gl.enableVertexAttribArray ($i{"aUNIT"+k}) );
					exprBlock.push( macro gl.vertexAttribPointer($i{"aUNIT"+k}, $v{n}, gl.UNSIGNED_BYTE, false, $v{stride}, $v{i} ) ); i += n;
					if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aUNIT"+k}, 1) );
				}
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
		exprBlock = [ macro gl.disableVertexAttribArray (aPOSITION) ];
		if (conf.posX.n  + conf.posY.n  > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aPOS ) );
		if (conf.sizeX.n + conf.sizeY.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aSIZE) );
		if (conf.pivotX.n + conf.pivotY.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aPIVOT) );
		if (conf.rotation.n + conf.zIndex.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aROTZ) );
		for (k in 0...Std.int((timers.length+1) / 2)) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTIME"+k}) );
		for (k in 0...conf.color.length) {
			if (conf.color[k].isStart) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aCOLORSTART"+k}) );
			if (conf.color[k].isEnd)   exprBlock.push( macro gl.disableVertexAttribArray ($i{"aCOLOREND"  +k}) );
		}
		for (k in 0...conf.texUnit.length) if (conf.texUnit[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aUNIT"+k}) );
		for (k in 0...conf.texSlot.length) if (conf.texSlot[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aSLOT"+k}) );
		for (k in 0...conf.texTile.length) if (conf.texTile[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTILE"+k}) );
		for (k in 0...conf.texX.length) if (conf.texX[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTEXX"+k}) );
		for (k in 0...conf.texY.length) if (conf.texY[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTEXY"+k}) );
		for (k in 0...conf.texW.length) if (conf.texW[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTEXW"+k}) );
		for (k in 0...conf.texH.length) if (conf.texH[k].n > 0) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTEXH"+k}) );
			
		fields.push({
			name: "disableVertexAttrib",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL}
				],
				expr: macro $b{exprBlock},
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