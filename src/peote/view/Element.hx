package peote.view;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
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
		var s = rStartspaces.replace(rEmptylines.replace(rComments.replace(template.execute(conf), ""), "\n"), "");
		return s;
	}
	
	static function hasMeta(f:Field, s:String):Bool {for (m in f.meta) { if (m.name == s || m.name == ':$s') return true; } return false; }
	static var allowForBuffer = [{ name:":allow", params:[macro peote.view], pos:Context.currentPos()}];
	
	static var conf = {
		isPICK:false,
		
		UNIFORM_TIME:"",
		ATTRIB_TIME:"",
		ATTRIB_SIZE:"",
		ATTRIB_POS:"",
		
		CALC_TIME:"",		
		CALC_SIZE:"",
		CALC_POS:"",
		
		// TODO: SPLIT conf HERE -------------
		
		time: [ "Size" ],
		
		isSizeAnim:true, // if isSizeXEnd and isSizeYEnd is false, this can be true (for constant anim)
		sizeN:4, // 0
		sizeType:"",			
		
		isSizeX:true,
		isSizeXEnd:true,
		sizeX: {
			name: "w",
			value: 100,
			valueEnd: 100,
			anim: "Size", 
			time: "Size",
		},
		
		isSizeY:true,
		isSizeYEnd:true,
		sizeY: {
			name: "h",
			value: 100,
			valueEnd: 100,
			anim: "Size",
			time: "Size",
		},
		
		isPosAnim:false, // if isPosXEnd and isPosYEnd is false, this can be true (for constant anim)
		posN:2, // 0
		posType:"",			
		
		isPosX:true,
		isPosXEnd:false,
		posX: {
			name: "x",
			value: 0,
			valueEnd: 0,
			anim: "",
			time: "",
		},
		
		isPosY:true,
		isPosYEnd:false,
		posY: {
			name: "y",
			value: 0,
			valueEnd: 0,
			anim: "Position",
			time: "Position",
		},
		
		
	};

	public static function build()
	{
		var hasNoNew:Bool = true;
		
		
		var classname = Context.getLocalClass().get().name;
		//var classpackage = Context.getLocalClass().get().pack;
		
		trace("--------------- " + classname + " -------------------");
		
		// trace(Context.getLocalClass().get().superClass); 
		trace("autogenerate shaders and buffers");

		// TODO: childclasses!
		

		// TODO
		trace("TODO: custom attributes");

		var fields = Context.getBuildFields();
		for (f in fields)
		{
			
			if (f.name == "new") {
				hasNoNew = false;
			}
			else
			switch (f.kind)
			{
				case FVar(t): //trace("attribute:",f.name ); // t: TPath({ name => Int, pack => [], params => [] })
					if ( hasMeta(f, "posX") ) {
						trace(f.name, f.meta[1].params[1]);
						//conf.posN++;
					}
					else if ( hasMeta(f, "posY") ) {
						trace(f.name);
						//conf.posN++;
					}
					else if ( hasMeta(f, "sizeX") ) {
						trace(f.name);
						//conf.sizeN++;
					}
					else if ( hasMeta(f, "sizeY") ) {
						trace(f.name);
						//conf.sizeN++;
					}
					
					// TODO
					// TODO
					// TODO
					
				default: //throw Context.error('Error: attribute has to be an variable.', f.pos);
			}

		}
		// -----------------------------------------------------------------------------------
		if (conf.sizeN > 0) {
			if (conf.sizeN == 1) conf.sizeType = "float";
			else conf.sizeType = "vec"+conf.sizeN;
		}
		if (conf.posN > 0) {
			if (conf.posN == 1) conf.posType = "float";
			else conf.posType = "vec"+conf.posN;
		}

		for (i in 0...Std.int((conf.time.length + 1) / 2)) {
			if ((i == Std.int(conf.time.length / 2)) && (conf.time.length % 2 != 0))
			     conf.ATTRIB_TIME += '::IN:: vec2 aTime$i;';
			else conf.ATTRIB_TIME += '::IN:: vec4 aTime$i;';
		}
		
		if (conf.sizeType != "") conf.ATTRIB_SIZE = '::IN:: ${conf.sizeType} aSize;';
		if (conf.posType  != "") conf.ATTRIB_POS  = '::IN:: ${conf.posType} aPos;';
		
		// CALC TIME-MUTLIPLICATOR:
		for (i in 0...conf.time.length) {
			var t:String = "" + Std.int(i / 2);
			var d:String = "" + Std.int(i/2);
			if (i % 2 == 0) { t += ".x"; d += ".y"; } else { t += ".z"; d += ".w"; } 
			conf.CALC_TIME += 'float time$i = clamp( (uTime - aTime$t) / aTime$d, 0.0, 1.0);';
		}
		if (conf.time.length > 0) conf.UNIFORM_TIME = "uniform float uTime;";
		
		// PREPARE -----------------------------------------------------------                             <- SIZE
		var size = "aSize";
		var sizeEnd = size;
		if (conf.isSizeX && !conf.isSizeY) {
			if (conf.sizeN > 1) { size += ".x"; sizeEnd += ".y"; }
			size = 'vec2( $size, ${conf.sizeY.value}.0 )';
		}
		else if (!conf.isSizeX && conf.isSizeY) {
			if (conf.sizeN > 1) { size += ".x"; sizeEnd += ".y"; }
			size = 'vec2( ${conf.sizeX.value}.0, $size )';
		}
		else if (!conf.isSizeX && !conf.isSizeY) size= 'vec2( ${conf.sizeX.value}.0, ${conf.sizeY.value}.0 )';
		else if (conf.sizeN > 2) { size += ".xy"; sizeEnd += ".z"; }

		// ANIM
		if (conf.isSizeAnim) {
			if (conf.isSizeXEnd && !conf.isSizeYEnd)       sizeEnd = 'vec2( $sizeEnd, ${conf.sizeY.valueEnd}.0 )';
			else if (!conf.isSizeXEnd && conf.isSizeYEnd)  sizeEnd = 'vec2( ${conf.sizeX.valueEnd}.0, $sizeEnd )';
			else if (!conf.isSizeXEnd && !conf.isSizeYEnd) sizeEnd = 'vec2( ${conf.sizeX.valueEnd}.0, ${conf.sizeY.valueEnd}.0 )';
			else { if (sizeEnd == "aSize.y") sizeEnd += "z"; else if (sizeEnd == "aSize.z") sizeEnd += "w";	}
			var iX = conf.time.indexOf(conf.sizeX.time);
			var iY = conf.time.indexOf(conf.sizeY.time);
			if (iX == -1)
				conf.CALC_SIZE = 'vec2 size = aPosition * ( $size + ($sizeEnd - $size) * vec2( 0.0, time$iY ) );';
			else if (iY == -1)
				conf.CALC_SIZE = 'vec2 size = aPosition * ( $size + ($sizeEnd - $size) * vec2( time$iX, 0.0 ) );';
			else
				conf.CALC_SIZE = 'vec2 size = aPosition * ( $size + ($sizeEnd - $size) * vec2( time$iX, time$iY ) );';
		}
		else conf.CALC_SIZE = 'vec2 size = aPosition * $size;';
		
		
		// PREPARE -----------------------------------------------------------                             <- POS
			
		// TODO
		var pos = "aPos"; // .xy etc
		if (conf.isPosX && !conf.isPosY) pos = 'vec2( $pos, ${conf.posY.value}.0 )';
		else
		if (!conf.isPosX && conf.isPosY) pos = 'vec2( ${conf.posX.value}.0, $pos )';
		else 
		if (!conf.isPosX && !conf.isPosY) pos= 'vec2( ${conf.posX.value}.0, ${conf.posY.value}.0 )';
				
		conf.CALC_POS = 'vec2 pos = size + $pos;'; // + (pos1 - pos) * timeStep;
		

		
		// -----------------------------------------------------------------------------------
		
		var vertex_count = 6;
		
		var buff_size_instanced = conf.posN*2 + conf.sizeN*2 + conf.time.length*8;
		var buff_size = vertex_count * (2+buff_size_instanced);
		
		
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
		if (conf.posN > 0) 
			fields.push({
				name:  "aPOS",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		if (conf.sizeN > 0)
			fields.push({
				name:  "aSIZE",
				access:  [Access.APrivate, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:Int, macro $v{attrNumber++}), 
				pos: Context.currentPos(),
			});
		for (i in 0...Std.int((conf.time.length+1) / 2)) {
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
				if (verts != null) {
					exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $v{verts[j][0]}) ); i++;
					exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $v{verts[j][1]}) ); i++;
				}
				if (conf.isPosX ) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posX.name }) ); i+=2; }
				if (conf.isPosY ) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.posY.name }) ); i+=2; }
				
				if (conf.isSizeAnim) {
					if (conf.isSizeX) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name+"Start"}) ); i+=2; }
					if (conf.isSizeY) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name+"Start"}) ); i+=2; }
					if (conf.isSizeXEnd) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name+"End"}) ); i+=2; }
					if (conf.isSizeYEnd) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name+"End"}) ); i+=2; }
				} else {
					if (conf.isSizeX) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeX.name}) ); i+=2; }
					if (conf.isSizeY) { exprBlock.push( macro bytes.setUInt16(bytePos + $v{i}, $i{conf.sizeY.name}) ); i+=2; }
				}
				
				for (t in conf.time) {
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{"time"+t+"Start"}) ); i+=4;
					exprBlock.push( macro bytes.setFloat(bytePos + $v{i}, $i{"time"+t+"Duration"}) ); i+=4;
				}
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
		if (conf.posN  > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aPOS,  "aPos" ) );
		if (conf.sizeN > 0 ) exprBlock.push( macro gl.bindAttribLocation(glProgram, aSIZE, "aSize") );
		for (j in 0...Std.int((conf.time.length+1) / 2) )
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
			var exprBlock = new Array<Expr>();
			var stride = buff_size_instanced;
			if (isInstanced) {
				exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glInstanceBuffer) );
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, 2, 0 ) );
				exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer) );
			} else {
				stride += 2;
				exprBlock.push( macro gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer) );
				exprBlock.push( macro gl.enableVertexAttribArray (aPOSITION) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOSITION, 2, gl.UNSIGNED_BYTE, false, $v{stride}, 0 )); i+=2;
			}
			
			if (conf.posN  > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aPOS) );
				exprBlock.push( macro gl.vertexAttribPointer(aPOS, $v{conf.posN}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += conf.posN * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aPOS, 1) );			
			}
			if (conf.sizeN > 0 ) {
				exprBlock.push( macro gl.enableVertexAttribArray (aSIZE) );
				exprBlock.push( macro gl.vertexAttribPointer(aSIZE, $v{conf.sizeN}, gl.SHORT, false, $v{stride}, $v{i} ) ); i += conf.sizeN * 2;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor(aSIZE, 1) );			
			}
			
			for (j in 0...Std.int((conf.time.length+1) / 2) ) {
				exprBlock.push( macro gl.enableVertexAttribArray ($i{"aTIME" + j}) );
				var n = ((j==Std.int(conf.time.length / 2)) && (conf.time.length % 2 != 0)) ? 2 : 4;
				exprBlock.push( macro gl.vertexAttribPointer($i{"aTIME"+j}, $v{n}, gl.FLOAT, false, $v{stride}, $v{i} ) ); i += n * 4;
				if (isInstanced) exprBlock.push( macro gl.vertexAttribDivisor($i{"aTIME"+j}, 1) );			
			}
			//for (e in exprBlock) trace(ExprTools.toString( e));
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
		if (conf.posN  >0 ) exprBlock.push( macro gl.disableVertexAttribArray (aPOS ) );
		if (conf.sizeN >0 ) exprBlock.push( macro gl.disableVertexAttribArray (aSIZE) );
		for (i in 0...Std.int((conf.time.length+1) / 2)) exprBlock.push( macro gl.disableVertexAttribArray ($i{"aTIME"+i}) );
		
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