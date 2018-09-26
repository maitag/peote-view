package peote.view;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.ds.StringMap;
#end

@:remove @:autoBuild(peote.view.ElementImpl.build())
interface Element {}

class ElementImpl
{
#if macro
	static var rComments:EReg = new EReg("//.*?$","gm");
	static var rEmptylines:EReg = new EReg("([ \t]*\r?\n)+", "g");
	static var rStartspaces:EReg = new EReg("^([ \t]*\r?\n)+", "g");
	
	static inline function parseShader(shader:String):String {
		var template = new utils.MultipassTemplate(shader);
		var s = rStartspaces.replace(rEmptylines.replace(rComments.replace(template.execute(glConf), ""), "\n"), "");
		return s;
	}
	
	static function hasMeta(f:Field, s:String):Bool {for (m in f.meta) { if (m.name == s || m.name == ':$s') return true; } return false; }
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
			} else return "";
		} else return null;
	}
	static var allowForBuffer = [{ name:":allow", params:[macro peote.view], pos:Context.currentPos()}];
	
	static var glConf = {
		isPICK:false,
		UNIFORM_TIME:"",
		ATTRIB_TIME:"", ATTRIB_SIZE:"", ATTRIB_POS:"",
		CALC_TIME:"", CALC_SIZE:"", CALC_POS:"",
	};
	
	static var timers:Array<String> = [];
	
	static var conf = {
		sizeX: { n:0, isAnim:false, name:"", isStart:false, isEnd:false, vStart:100, vEnd:100, time: "" },
		sizeY: { n:0, isAnim:false, name:"", isStart:false, isEnd:false, vStart:100, vEnd:100, time: "" },
		
		posX: { n:0, isAnim:false, name: "", isStart:false, isEnd:false, vStart:0, vEnd:0, time: "" },
		posY: { n:0, isAnim:false, name: "", isStart:false, isEnd:false, vStart:0, vEnd:0, time: "" },		
		
	};
	static function camelCase(a:String, b:String):String {
		return a + b.substr(0,1).toUpperCase() + b.substr(1);
	}
	
	static var setFun :StringMap<Dynamic> = new StringMap<Dynamic>();
	static function checkSet(f:Field, isAnim:Bool = false, isAnimStart:Bool = false, isAnimEnd:Bool = false )
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
			var nameStart:String = name + "Start";
			var nameEnd:String = name + "End";
			v.args.push( {name:name, type:macro:Int} ); // todo: default param
			if (!isAnim) v.expr.push( macro this.$name = $i{name} );
			else {
				if (isAnimStart) v.expr.push( macro this.$nameStart = $i{name} );
				if (isAnimEnd)   v.expr.push( macro this.$nameEnd   = $i{name} );
			}
		}		
	}
	
	static var animFun:StringMap<Dynamic> = new StringMap<Dynamic>();
	static function checkAnim(f:Field, isAnimStart:Bool = false, isAnimEnd:Bool = false)
	{
		var param:String = getMetaParam(f, "anim");
		if (param != null) {
			param = camelCase("anim", param);
			var v = animFun.get(param);
			if (v == null) {
				v = {argsStart:[], argsEnd:[], exprStart:[], exprEnd:[]};
				animFun.set( param, v);
			}			
			var nameStart:String = f.name + "Start";
			var nameEnd:String   = f.name + "End";
			if (isAnimStart) {
				v.argsStart.push( {name:nameStart, type:macro:Int} ); // todo: default param
				v.exprStart.push( macro this.$nameStart   = $i{nameStart} );
			}
			if (isAnimEnd) {
				v.argsEnd.push( {name:nameEnd, type:macro:Int} ); // todo: default param
				v.exprEnd.push( macro this.$nameEnd   = $i{nameEnd} );
			}
		}		
	}
	
	static function checkMetas(f:Field, sizeX:Dynamic, toRemove:Array<Field>)
	{
		sizeX.name = f.name;
		var param = getMetaParam(f, "time");
		if (param != null) {
			sizeX.isAnim = true;
			if (timers.indexOf(param) == -1) timers.push( param );
			sizeX.time = param;
			param = getMetaParam(f, "constStart");
			if (param != null) {
				if (param == "") throw Context.error('Error: @constStart needs a value', f.pos);
				sizeX.vStart = Std.parseInt(param);
			} else {
				sizeX.isStart = true;
				sizeX.n++;
			}
			param = getMetaParam(f, "constEnd");
			if (param != null) {
				if (param == "") throw Context.error('Error: @constEnd needs a value', f.pos);
				sizeX.vEnd = Std.parseInt(param);
			} else {
				sizeX.isEnd = true;
				sizeX.n++;
			}
			if (sizeX.isStart || sizeX.isEnd) {
				checkSet(f, true, sizeX.isStart, sizeX.isEnd);
				checkAnim(f, sizeX.isStart, sizeX.isEnd);
			}
			toRemove.push(f);// remove field
			
		} else {
			param = getMetaParam(f, "const");
			if (param != null) {
				if (param == "") throw Context.error('Error: @const needs a value', f.pos);
				sizeX.vStart = Std.parseInt(param);
				if (f.access.indexOf(Access.AStatic) == -1) f.access.push(Access.AStatic);
				if (f.access.indexOf(Access.AInline) == -1) f.access.push(Access.AInline);
			} else {
				sizeX.isStart = true;
				checkSet(f);
				sizeX.n++;
			}							
		}
		//trace(f.name,sizeX);
	}
	
	static var fieldnames = new Array<String>();
	
	static function genVarInt(fields:Array<Field>, name:String, value:Int) {
		if (fieldnames.indexOf(name) == -1)
			fields.push({
				name:  name,
				//meta:  allowForBuffer,
				access:  [Access.APublic],
				kind: FieldType.FVar( macro:Int, macro $v{value} ), 
				pos: Context.currentPos(),
			});
	}
	
	static function genVarFloat(fields:Array<Field>, name:String, value:Float) {
		if (fieldnames.indexOf(name) == -1)
			fields.push({
				name:  name,
				//meta:  allowForBuffer,
				access:  [Access.APublic],
				kind: FieldType.FVar( macro:Float, macro $v{value} ), 
				pos: Context.currentPos(),
			});
	}
	
	public static function build()
	{
		var hasNoNew:Bool = true;
		
		
		var classname = Context.getLocalClass().get().name;
		//var classpackage = Context.getLocalClass().get().pack;
		
		trace("--------------- " + classname + " -------------------");
		
		// trace(Context.getLocalClass().get().superClass); 
		trace("autogenerate shaders and attributes");

		// TODO: childclasses!
		
		var toRemove = new Array<Field>();
		
		var fields = Context.getBuildFields();
		for (f in fields)
		{	
			fieldnames.push(f.name);
			if (f.name == "new") hasNoNew = false;
			else switch (f.kind)
			{
				case FVar(t): //trace("attribute:",f.name ); // t: TPath({ name => Int, pack => [], params => [] })
					if      ( hasMeta(f, "posX")  ) checkMetas(f, conf.posX,  toRemove);
					else if ( hasMeta(f, "posY")  ) checkMetas(f, conf.posY,  toRemove);
					else if ( hasMeta(f, "sizeX") ) checkMetas(f, conf.sizeX, toRemove);
					else if ( hasMeta(f, "sizeY") ) checkMetas(f, conf.sizeY, toRemove);
					// TODO
					
				default: //throw Context.error('Error: attribute has to be an variable.', f.pos);
			}

		}
		// remove anim-fields
		for (f in toRemove) fields.remove(f);
		
		// add constructor ("new") if it is not there
		if (hasNoNew) fields.push({
			name: "new",
			access: [APublic],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro {},
				params: [],
				ret: null
			})
		});
		
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
		if (n  > 0) glConf.ATTRIB_POS = '::IN:: ${ (n==1) ? "float" : "vec"+n } aPos;';
		
		// CALC TIME-MUTLIPLICATORS:
		for (i in 0...timers.length) {
			var t:String = "" + Std.int(i / 2);
			var d:String = "" + Std.int(i/2);
			if (i % 2 == 0) { t += ".x"; d += ".y"; } else { t += ".z"; d += ".w"; } 
			glConf.CALC_TIME += 'float time$i = clamp( (uTime - aTime$t) / aTime$d, 0.0, 1.0);';
		}
		if (timers.length > 0) glConf.UNIFORM_TIME = "uniform float uTime;";
		
		// PREPARE -----------------------------------------------------------                             <- SIZE, POS
		function prepare(name:String, sizeX:Dynamic, sizeY:Dynamic):String {
			var start = name; var end = name;
			var n:Int = sizeX.n + sizeY.n;
			if (sizeX.isStart && !sizeY.isStart) {
				if (n > 1) { start += ".x"; end += ".y"; }
				start = 'vec2( $start, ${sizeY.vStart}.0 )';
			}
			else if (!sizeX.isStart && sizeY.isStart) {
				if (n > 1) { start += ".x"; end += ".y"; }
				start = 'vec2( ${sizeX.vStart}.0, $start )';
			}
			else if (!sizeX.isStart && !sizeY.isStart)
				start= 'vec2( ${sizeX.vStart}.0, ${sizeY.vStart}.0 )';
			else if (n > 2) {
				start += ".xy"; end += ".z";
			}
			// ANIM
			if (sizeX.isAnim || sizeY.isAnim) {
				if (sizeX.isEnd && !sizeY.isEnd)       end = 'vec2( $end, ${sizeY.vEnd}.0 )';
				else if (!sizeX.isEnd && sizeY.isEnd)  end = 'vec2( ${sizeX.vEnd}.0, $end )';
				else if (!sizeX.isEnd && !sizeY.isEnd) end = 'vec2( ${sizeX.vEnd}.0, ${sizeY.vEnd}.0 )';
				else {
					if      (end == name+".y") end += "z";
					else if (end == name+".z") end += "w";
				}
				var iX = timers.indexOf(sizeX.time);
				var iY = timers.indexOf(sizeY.time);
				if (iX == -1)      return '( $start + ($end - $start) * vec2( 0.0, time$iY ) )';
				else if (iY == -1) return '( $start + ($end - $start) * vec2( time$iX, 0.0 ) )';
				else               return '( $start + ($end - $start) * vec2( time$iX, time$iY ) )';
			} else return start;
		}
		
		glConf.CALC_SIZE = "vec2 size = aPosition * " + prepare("aSize", conf.sizeX, conf.sizeY) + ";";
		glConf.CALC_POS  = "vec2 pos  = size + "      + prepare("aPos" , conf.posX,  conf.posY ) + ";";
		// TODO: color
		
		
		
		// ---------------------- generate helper vars and functions ---------------------------
		for (t in timers) {
			genVarFloat(fields, "time" + t + "Start",    0.0);
			genVarFloat(fields, "time" + t + "Duration", 1.0);
			
			var name = camelCase("time", t);
			if (fieldnames.indexOf(name) == -1)
				fields.push({
					name: name,
					//meta:  allowForBuffer,
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
		}
		// @set
		for (name in setFun.keys()) {
			if (fieldnames.indexOf(name) == -1)
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
		}
		// @anim
		for (name in animFun.keys()) {
			if (fieldnames.indexOf(name) == -1)
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
		}
		// anim start/end vars
		if (conf.posX.isAnim) {
			if (conf.posX.isStart) genVarInt(fields, conf.posX.name+"Start", conf.posX.vStart);
			if (conf.posX.isEnd)   genVarInt(fields, conf.posX.name+"End",   conf.posX.vEnd);
		}
		if (conf.posY.isAnim) {
			if (conf.posY.isStart) genVarInt(fields, conf.posY.name+"Start", conf.posY.vStart);
			if (conf.posY.isEnd)   genVarInt(fields, conf.posY.name+"End",   conf.posY.vEnd);
		}
		
		if (conf.sizeX.isAnim) {
			if (conf.sizeX.isStart) genVarInt(fields, conf.sizeX.name+"Start", conf.sizeX.vStart);
			if (conf.sizeX.isEnd)   genVarInt(fields, conf.sizeX.name+"End",   conf.sizeX.vEnd);
		}
		if (conf.sizeY.isAnim) {
			if (conf.sizeY.isStart) genVarInt(fields, conf.sizeY.name+"Start", conf.sizeY.vStart);
			if (conf.sizeY.isEnd)   genVarInt(fields, conf.sizeY.name+"End",   conf.sizeY.vEnd);
		}
				
		
		// ------------------------- calc buffer size ----------------------------------------
		
		var vertex_count = 6;
		
		var buff_size_instanced = timers.length * 8
			+ 2 * (conf.posX.n  + conf.posY.n)
			+ 2 * (conf.sizeX.n + conf.sizeY.n)
		;
		var fillStride_instanced = buff_size_instanced % 4; // this fix the stride offset-Problem
		var fillStride = (buff_size_instanced + 2) % 4;
		var buff_size = vertex_count * ( buff_size_instanced + 2 + fillStride);
		
		
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

		// TODO: COLOR...
		/*fields.push({
			name:  "aCOLOR",
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{3}), 
			pos: Context.currentPos(),
		});*/
			
		
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
				for (t in timers) {
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{"time"+t+"Start"}) ); i+=4;
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{"time"+t+"Duration"}) ); i+=4;
				}

				if (verts != null) {
					exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $v{verts[j][0]}) ); i++;
					exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $v{verts[j][1]}) ); i++;
				}
				
				if (conf.posX.isAnim && conf.posX.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name+"Start"}) ); i+=2; }
				if (!conf.posX.isAnim && conf.posX.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name }) ); i+=2; }
				if (conf.posY.isAnim && conf.posY.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name+"Start"}) ); i+=2; }
				if (!conf.posY.isAnim && conf.posY.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name }) ); i+=2; }
				if (conf.posX.isAnim && conf.posX.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name+"End"}) ); i+=2; }
				if (conf.posY.isAnim && conf.posY.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name+"End"}) ); i+=2; }
				
				if (conf.sizeX.isAnim && conf.sizeX.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name+"Start"}) ); i+=2; }
				if (!conf.sizeX.isAnim && conf.sizeX.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name}) ); i+=2; }
				if (conf.sizeY.isAnim && conf.sizeY.isStart) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name+"Start"}) ); i+=2; }
				if (!conf.sizeY.isAnim && conf.sizeY.isStart){ exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name}) ); i+=2; }
				if (conf.sizeX.isAnim && conf.sizeX.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name+"End"}) ); i+=2; }
				if (conf.sizeY.isAnim && conf.sizeY.isEnd)   { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name+"End"}) ); i+=2; }
				
				if (verts != null) i += fillStride else i += fillStride_instanced;
				//if (j == 1) for (e in exprBlock) trace(ExprTools.toString( e)); //debug
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
			
			for (j in 0...Std.int((timers.length+1) / 2) ) {
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTIME" + j}) );
				n = ((j==Std.int(timers.length / 2)) && (timers.length % 2 != 0)) ? 2 : 4;
				exprBlock.push( macro gl.vertexAttribPointer($i{"aTIME"+j}, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTIME"+j}, 1) );			
			}
			
			if (!isInstanced) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, $v{stride}, $v{i} )); i+=2;
			}
			
			n = conf.posX.n + conf.posY.n;
			if (n > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOS) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOS, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aPOS, 1) );			
			}
			
			n = conf.sizeX.n + conf.sizeY.n;
			if (n > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aSIZE) );
				exprBlock.push( macro gl.vertexAttribPointer(aSIZE, $v{n}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += n * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aSIZE, 1) );			
			}
			//for (e in exprBlock) trace(ExprTools.toString( e)); //debug
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
		// -------------------------
		exprBlock = [ macro gl.disableVertexAttribArray (aPOSITION) ];
		if (conf.posX.n  + conf.posY.n  > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aPOS ) );
		if (conf.sizeX.n + conf.sizeY.n > 0 ) exprBlock.push( macro gl.disableVertexAttribArray (aSIZE) );
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
	
	

#end
}