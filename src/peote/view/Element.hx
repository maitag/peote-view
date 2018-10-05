package peote.view;

#if !macro
@:remove @:autoBuild(peote.view.ElementImpl.build())
interface Element {}
class ElementImpl {}
#else

import haxe.ds.StringMap;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Printer;

typedef ConfParam =
{
	posX :ConfSubParam,
	posY :ConfSubParam,
	sizeX:ConfSubParam,
	sizeY:ConfSubParam,
	color:ConfSubParam,
}
typedef ConfSubParam =
{
	vStart:Dynamic, vEnd:Dynamic, n:Int, isAnim:Bool, name:String, isStart:Bool, isEnd:Bool, time:String,
}

typedef GLConfParam =
{			isPICK:Bool,
			UNIFORM_TIME:String,
			ATTRIB_TIME:String, ATTRIB_SIZE:String, ATTRIB_POS:String, ATTRIB_COLOR:String,
			OUT_COLOR:String, IN_COLOR:String,
			FRAGMENT_CALC_COLOR:String,
			CALC_TIME:String, CALC_SIZE:String, CALC_POS:String, CALC_COLOR:String,
};

class ElementImpl
{
	static inline function debug(s:String):Void	{
		#if peoteview_debug_macro
		trace(s);
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
	
	static inline function camelCase(a:String, b:String):String return a + b.substr(0, 1).toUpperCase() + b.substr(1);
	
	static inline function toFloatString(value:Dynamic):String {
		var s:String = Std.string(value);
		return (s.indexOf('.') != -1) ? s : s + ".0";
	}
	
	static inline function color2vec4(c:UInt):String {
		return 'vec4(${toFloatString(((c & 0xFF000000)>>24)/255)}, ${toFloatString(((c & 0x00FF0000)>>16)/255)},' + 
		            ' ${toFloatString(((c & 0x0000FF00)>>8)/255)}, ${toFloatString((c & 0x000000FF)/255)})';
	}
	
	static inline function hasMeta(f:Field, s:String):Bool {
		var itHas:Bool = false;
		for (m in f.meta) {
			if (m.name == s || m.name == ':$s') {
				itHas = true; break; 
			}
		}
		return itHas;
	}
	
	static inline function getMetaParam(f:Field, s:String):String {
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
	
	static var allowForBuffer = [{name:":allow", params:[macro peote.view], pos:Context.currentPos()}];
	
	static inline function genVar(type:ComplexType, name:String, value:Dynamic, isConstant:Bool = false) {
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
	
	static inline function checkSet(f:Field, isAnim:Bool = false, isAnimStart:Bool = false, isAnimEnd:Bool = false )
	{
		var param:String = getMetaParam(f, "set");
		if (param != null) {
			param = camelCase("set", param);
			var v = setFun.get(param);
			if (v == null) {
				v = {args:[], expr:[]};
				setFun.set( param, v);
			}
			var name:String = f.name;
			v.args.push( {name:name, type:macro:Int} );
			if (!isAnim) v.expr.push( macro this.$name = $i{name} );
			else {
				var nameStart:String = name + "Start";
				var nameEnd:String = name + "End";
				if (isAnimStart) v.expr.push( macro this.$nameStart = $i{name} );
				if (isAnimEnd)   v.expr.push( macro this.$nameEnd   = $i{name} );
			}
		}		
	}
	
	static inline function checkAnim(f:Field, isAnimStart:Bool, isAnimEnd:Bool)
	{
		var param:String = getMetaParam(f, "anim");
		if (param != null) {
			param = camelCase("anim", param);
			var v = animFun.get(param);
			if (v == null) {
				v = {argsStart:[], argsEnd:[], exprStart:[], exprEnd:[]};
				animFun.set( param, v);
			}			
			if (isAnimStart) {
				var nameStart:String = f.name + "Start";
				v.argsStart.push( {name:nameStart, type:macro:Int} );
				v.exprStart.push( macro this.$nameStart   = $i{nameStart} );
			}
			if (isAnimEnd) {
				var nameEnd:String   = f.name + "End";
				v.argsEnd.push( {name:nameEnd, type:macro:Int} );
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
	
	
	static inline function checkMetas(f:Field, expectedType:ComplexType, type:ComplexType, val:Expr, confItem:ConfSubParam, getter:String, setter:String)
	{
		if (confItem.name == "") confItem.name = f.name;
		else throw Context.error('Error: attribute already defined for "${f.name}"', f.pos);
		
		if (f.access.indexOf(Access.AStatic) != -1) throw Context.error('Error: "${f.name}" can not be static', f.pos);
		
		var printer = new Printer();
		var expType:String = printer.printComplexType(expectedType);
		//trace('var ${f.name}:${(type==null)? null : printer.printComplexType(type)} - expected type:${expType}');
		
		if (type == null) {
			type = expectedType; debug('set type of ${f.name} to ${printer.printComplexType(expectedType)}');
			f.kind = FieldType.FVar( type, val );
		}
		else if (printer.printComplexType(type) != expType) throw Context.error('Error: type of "${f.name}" should be ${ printer.printComplexType(expectedType) }', f.pos);
				
		var defaultVal:Dynamic;
		if (val != null) {
			var v = ExprTools.getValue(val);
			if (expType=="Int" && Type.typeof(v) != Type.ValueType.TInt)
				throw Context.error('Error: init value "$v" for "${f.name}" had to be Int', f.pos);
			else if (expType=="Float" && Type.typeof(v) != Type.ValueType.TFloat)
				throw Context.error('Error: init value "$v" for "${f.name}" had to be Float', f.pos);
			defaultVal = ExprTools.getValue(val);
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
				checkSet(f, true, confItem.isStart, confItem.isEnd);
				checkAnim(f, confItem.isStart, confItem.isEnd);
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
				checkSet(f);
				confItem.n++;
			}							
		}
		//trace(confItem);
	}
	
	static inline function configure(f:Field, type:ComplexType, val:Expr, getter:String=null, setter:String=null)
	{
		//trace(f.name, type, val, getter, setter);
		if      ( hasMeta(f, "posX")  ) checkMetas(f, macro:Int, type, val, conf.posX, getter, setter);
		else if ( hasMeta(f, "posY")  ) checkMetas(f, macro:Int, type, val, conf.posY, getter, setter);
		else if ( hasMeta(f, "sizeX") ) checkMetas(f, macro:Int, type, val, conf.sizeX, getter, setter);
		else if ( hasMeta(f, "sizeY") ) checkMetas(f, macro:Int, type, val, conf.sizeY, getter, setter);
		else if ( hasMeta(f, "color") ) checkMetas(f, macro:Int, type, val, conf.color, getter, setter);
		// TODO
		// rotation, pivot
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
		
	// -------------------------------------- BUILD -------------------------------------------------
	public static function build()
	{
		conf = {
			posX :{ vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },
			posY :{ vStart:0,   vEnd:0,   n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },		
			sizeX:{ vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },
			sizeY:{ vStart:100, vEnd:100, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },
			color:{ vStart:0xFF000000, vEnd:0xFF000000, n:0, isAnim:false, name:"", isStart:false, isEnd:false, time: "" },			
		};
		glConf = {
			isPICK:false,
			UNIFORM_TIME:"",
			ATTRIB_TIME:"", ATTRIB_SIZE:"", ATTRIB_POS:"", ATTRIB_COLOR:"",
			OUT_COLOR:"", IN_COLOR:"",
			FRAGMENT_CALC_COLOR:"",
			CALC_TIME:"", CALC_SIZE:"", CALC_POS:"", CALC_COLOR:""
		};		
		setFun  = new StringMap<Dynamic>();
		animFun = new StringMap<Dynamic>();
		getterFun = new Array<Dynamic>();
		setterFun = new Array<Dynamic>();
		timers = new Array<String>();
		fieldnames = new Array<String>();	
		fields = new Array<Field>();
		
		var hasNoNew:Bool = true;		
		var classname:String = Context.getLocalClass().get().name;
		//var classpackage = Context.getLocalClass().get().pack;
		
		// trace(Context.getLocalClass().get().superClass); 
		debug('----- generating Class: $classname -----');

		// TODO: childclasses!
		
		fields = Context.getBuildFields();
		for (f in fields)
		{	
			fieldnames.push(f.name);
			if (f.name == "new") hasNoNew = false;
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
		
		var n:Int;
		n = conf.sizeX.n + conf.sizeY.n;
		if (n > 0) glConf.ATTRIB_SIZE = '::IN:: ${ (n==1) ? "float" : "vec"+n} aSize;';
		n = conf.posX.n + conf.posY.n;
		if (n > 0) glConf.ATTRIB_POS  = '::IN:: ${ (n==1) ? "float" : "vec"+n } aPos;';
		
		if (conf.color.name != "") {
			if (conf.color.isStart) glConf.ATTRIB_COLOR  = '::IN:: vec4 aColorStart;';
			if (conf.color.isEnd)   glConf.ATTRIB_COLOR += '::IN:: vec4 aColorEnd;';
			glConf.OUT_COLOR = "::VAROUT:: vec4 vColor;";
			glConf.IN_COLOR  = "::VARIN::  vec4 vColor;";
		}
		
		// CALC TIME-MUTLIPLICATORS:
		for (i in 0...timers.length) {
			var t:String = "" + Std.int(i / 2);
			var d:String = "" + Std.int(i/2);
			if (i % 2 == 0) { t += ".x"; d += ".y"; } else { t += ".z"; d += ".w"; } 
			glConf.CALC_TIME += 'float time$i = clamp( (uTime - aTime$t) / aTime$d, 0.0, 1.0);';
		}
		if (timers.length > 0) glConf.UNIFORM_TIME = "uniform float uTime;";
		
		// pack -----------------------------------------------------------------------
		function pack2in1(name:String, x:ConfSubParam, y:ConfSubParam):String {
			var start = name; var end = name;
			var n:Int = x.n + y.n;
			if (x.isStart && !y.isStart) {
				if (n > 1) { start += ".x"; end += ".y"; }
				start = 'vec2( $start, ${toFloatString(y.vStart)} )';
			}
			else if (!x.isStart && y.isStart) {
				if (n > 1) { start += ".x"; end += ".y"; }
				start = 'vec2( ${toFloatString(x.vStart)}, $start )';
			}
			else if (!x.isStart && !y.isStart)
				start= 'vec2( ${toFloatString(x.vStart)}, ${toFloatString(y.vStart)} )';
			else if (n > 2) {
				start += ".xy"; end += ".z";
			}
			// ANIM
			if (x.isAnim || y.isAnim) {
				if (x.isEnd && !y.isEnd)       end = 'vec2( $end, ${toFloatString(y.vEnd)} )';
				else if (!x.isEnd && y.isEnd)  end = 'vec2( ${toFloatString(x.vEnd)}, $end )';
				else if (!x.isEnd && !y.isEnd) end = 'vec2( ${toFloatString(x.vEnd)}, ${toFloatString(y.vEnd)} )';
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
		// pos
		glConf.CALC_POS  = "vec2 pos  = size + "      + pack2in1("aPos" , conf.posX,  conf.posY ) + ";";
		// color
		if (conf.color.name != "") {
			var start = (conf.color.isStart) ? "aColorStart.wzyx" : color2vec4(conf.color.vStart);
			if (conf.color.isAnim) {
				var end = (conf.color.isEnd) ? "aColorEnd.wzyx" : color2vec4(conf.color.vEnd);
				start = '$start + ($end - $start) * time' + timers.indexOf(conf.color.time);
			}
			glConf.CALC_COLOR = 'vColor = $start;';
			glConf.FRAGMENT_CALC_COLOR = "vColor"; // TODO: methods for texel-recoloring
		} else glConf.FRAGMENT_CALC_COLOR = color2vec4(conf.color.vStart);
		
		// rotation
		
		// ---------------------- generate helper vars and functions ---------------------------
		debug("-- generate:");
		
		// add constructor ("new") if it is not there
		if (hasNoNew) fields.push({
			name: "new",
			access: [Access.APublic],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro {},
				params: [],
				ret: null
			})
		});
		debugLastField(fields);
		
		for (t in timers) {
			var name = camelCase("time", t);
			genVar(macro:Float, name + "Start",    0.0);
			genVar(macro:Float, name + "Duration", 1.0);
			if (fieldnames.indexOf(name) == -1) {
				fields.push({
					name: name,
					access: [Access.APublic], //, Access.AInline
					pos: Context.currentPos(),
					kind: FFun({
						args:[ {name:"startTime", type:macro:Float},{name:"duration", type:macro:Float} ],
						expr:  macro {
							$i{"time" + t + "Start"} = startTime;
							$i{"time" + t + "Duration"} = duration;
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
		
		if (conf.color.isAnim) {		
			genVar(macro:Int, conf.color.name+"Start", conf.color.vStart, !conf.color.isStart); // TODO: uint?
			genVar(macro:Int, conf.color.name+"End",   conf.color.vEnd,   !conf.color.isEnd);
		}
		
		// ------------------------- calc buffer size ----------------------------------------		
		var vertex_count:Int = 6;
		
		var buff_size_instanced:Int = Std.int(timers.length * 8
			+ 2 * (conf.posX.n  + conf.posY.n)
			+ 2 * (conf.sizeX.n + conf.sizeY.n)
			+ 4 *  conf.color.n
		);
		var fillStride_instanced:Int = buff_size_instanced % 4; // this fix the stride offset-Problem
		var fillStride:Int = (buff_size_instanced + 2) % 4;
		var buff_size:Int = vertex_count * ( buff_size_instanced + 2 + fillStride);		
		
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
		for (i in 0...Std.int((timers.length+1) / 2)) {
			fields.push({
				name:  "aTIME"+i,
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}
		if (conf.color.isStart) {
			fields.push({
				name:  "aCOLORSTART",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}	
		if (conf.color.isEnd) {
			fields.push({
				name:  "aCOLOREND",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		}	
		
		// TODO: rotation ...
		

		// -------------------------- instancedrawing --------------------------------------
		fields.push({
			name:  "instanceBytes", // only for instanceDrawing
			access:  [Access.APrivate, Access.AStatic],
			kind: FieldType.FVar(macro:haxe.io.Bytes, macro null), 
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
						instanceBytes = haxe.io.Bytes.alloc(VERTEX_COUNT * 2);
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
				// TIMERS
				for (t in timers) {
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{"time"+t+"Start"}) ); i+=4;
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{"time"+t+"Duration"}) ); i+=4;
				}
				// COLOR
				if (conf.color.isAnim && conf.color.isStart) { exprBlock.push( macro bytes.setInt32(bytePos + $v{i}, $i{conf.color.name+"Start"}) ); i+=4; }
				if (!conf.color.isAnim && conf.color.isStart){ exprBlock.push( macro bytes.setInt32(bytePos + $v{i}, $i{conf.color.name}) ); i+=4; }
				if (conf.color.isAnim && conf.color.isEnd)   { exprBlock.push( macro bytes.setInt32(bytePos + $v{i}, $i{conf.color.name+"End"}) ); i+=4; }
				
				// POSITION for non-instancedrawing
				if (verts != null) {
					exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $v{verts[j][0]}) ); i++;
					exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $v{verts[j][1]}) ); i++;
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
				
				if (verts != null) i += fillStride else i += fillStride_instanced;
			}
			return exprBlock;
		}

		fields.push({
			name: "writeBytesInstanced",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"bytes", type:macro:haxe.io.Bytes}
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
				args:[ {name:"bytes", type:macro:haxe.io.Bytes}
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
		if (conf.color.isStart) exprBlock.push( macro gl.bindAttribLocation(glProgram, aCOLORSTART, "aColorStart") );
		if (conf.color.isEnd)   exprBlock.push( macro gl.bindAttribLocation(glProgram, aCOLOREND,   "aColorEnd") );
		for (j in 0...Std.int((timers.length+1) / 2) )
			exprBlock.push( macro gl.bindAttribLocation(glProgram, $i{"aTIME" + j}, $v{"aTime"+j} ) );
				
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
			var stride = buff_size_instanced;
			if (isInstanced) {
				exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glInstanceBuffer) );
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, 2, 0 ) );
				stride += fillStride_instanced;
			} else stride += 2 + fillStride;

			exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer) );
			
			// TIMERS
			for (j in 0...Std.int((timers.length+1) / 2) ) {
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTIME" + j}) );
				n = ((j==Std.int(timers.length / 2)) && (timers.length % 2 != 0)) ? 2 : 4;
				exprBlock.push( macro gl.vertexAttribPointer($i{"aTIME"+j}, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTIME"+j}, 1) );			
			}
			// COLOR
			if (conf.color.isStart) {
				exprBlock.push( macro gl.enableVertexAttribArray (aCOLORSTART) );
				exprBlock.push( macro gl.vertexAttribPointer(aCOLORSTART, 4, gl.UNSIGNED_BYTE, true, $v{stride}, $v{i} ) ); i += 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aCOLORSTART, 1) );			
			}			
			if (conf.color.isEnd) {
				exprBlock.push( macro gl.enableVertexAttribArray (aCOLOREND) );
				exprBlock.push( macro gl.vertexAttribPointer(aCOLOREND, 4, gl.UNSIGNED_BYTE, true, $v{stride}, $v{i} ) ); i += 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aCOLOREND, 1) );			
			}
			// POSITION for non-instancedrawing
			if (!isInstanced) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, $v{stride}, $v{i} )); i+=2;
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
		if (conf.color.isStart) exprBlock.push( macro gl.disableVertexAttribArray (aCOLORSTART) );
		if (conf.color.isEnd)   exprBlock.push( macro gl.disableVertexAttribArray (aCOLOREND) );
		for (i in 0...Std.int((timers.length+1) / 2)) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTIME"+i}) );
		
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