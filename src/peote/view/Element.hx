package peote.view;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;

@:remove @:autoBuild(peote.view.ElementImpl.build())
interface Element {}

class ElementImpl
{
#if macro
	static var rComments:EReg = new EReg("//.*?$","gm");
	static var rEmptylines:EReg = new EReg("([ \t]*\r?\n)+", "g");
	static var rStartspaces:EReg = new EReg("^([ \t]*\r?\n)+", "g");

	static inline function parseExpr(s:String):Expr {
		return Context.parse(new haxe.Template(s).execute(conf), Context.currentPos());
	}
	
	@:access(haxe.Template.splitter)
	static inline function parseShader(shader:String):String {
		var template = new utils.MultipassTemplate(shader);
		var s = rStartspaces.replace(rEmptylines.replace(rComments.replace(template.execute(conf), ""), "\n"), "");
		return s;
	}
	
	static function hasMeta(f:Field, s:String):Bool {for (m in f.meta) { if (m.name == s || m.name == ':$s') return true; } return false; }
	static var allowForBuffer = [{ name:":allow", params:[macro peote.view], pos:Context.currentPos()}];
	
	static var conf = {
		isPICK:false,
	};

	public static function build()
	{
		var hasNoNew:Bool = true;
		
		
		var classname = Context.getLocalClass().get().name;
		var classpackage = Context.getLocalClass().get().pack;
		
		trace("--------------- " + classname + " -------------------");
		
		// trace(Context.getLocalClass().get().superClass); 
		trace("autogenerate shaders and buffers");

		// TODO: childclasses!
		
// { module => elements.ElementSimpleChild, init => null, kind => KNormal,
// meta => { ??? => #function:1, add => #function:3, get => #function:0, has => #function:1, remove => #function:1 }, 
// name => ElementSimpleChild, pack => [elements], interfaces => [], params => [], __t => #abstract, doc => null,
// fields => class fields, isPrivate => false, constructor => null, isInterface => false, isExtern => false,
// superClass => { params => [], t => elements.ElementSimple }, exclude => #function:0, statics => class fields, overrides => [] }

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
					if ( hasMeta(f, "positionX") ) {
						trace(f.name);
					}
					else if ( hasMeta(f, "positionY") ) {
						trace(f.name);
					}
					/*else if ( hasMeta(f, "positionZ") ) {
						trace(f.name);
					}*/
					
					// TODO
					// TODO
					// TODO
					
				default: //throw Context.error('Error: attribute has to be an variable.', f.pos);
			}

		}
		// -----------------------------------------------------------------------------------
		
		var vertex_count = 6;
		var buff_size = vertex_count * 4;
		var buff_size_instanced = 8;
		
		
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
		fields.push({
			name:  "aPOSITION",
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{0}), 
			pos: Context.currentPos(),
		});
		fields.push({
			name:  "aPOSSIZE", // only for instanceDrawing
			access:  [Access.APrivate, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:Int, macro $v{1}), 
			pos: Context.currentPos(),
		});
			
		// TODO: COLOR...
		
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
						instanceBytes = haxe.io.Bytes.alloc(VERTEX_COUNT * 4);
						instanceBytes.setUInt16(0 , 1); instanceBytes.setUInt16(2,  1);
						instanceBytes.setUInt16(4 , 1); instanceBytes.setUInt16(6,  1);
						instanceBytes.setUInt16(8 , 0); instanceBytes.setUInt16(10, 1);
						instanceBytes.setUInt16(12, 1); instanceBytes.setUInt16(14, 0);
						instanceBytes.setUInt16(16, 0); instanceBytes.setUInt16(18, 0);
						instanceBytes.setUInt16(20, 0); instanceBytes.setUInt16(22, 0);
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
		//var i:Int = 0;
		fields.push({
			name: "writeBytes",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"bytes", type:macro:haxe.io.Bytes}
				],
				expr: macro {
					if (peote.view.PeoteGL.Version.isINSTANCED)
					{
						bytes.setUInt16(bytePos + 0 , x); bytes.setUInt16(bytePos + 2,  y);
						bytes.setUInt16(bytePos + 4 , w); bytes.setUInt16(bytePos + 6,  h);
					}
					else 
					{	var xw = x + w;
						var yh = y + h;
						bytes.setUInt16(bytePos + 0 , xw); bytes.setUInt16(bytePos + 2,  yh);
						bytes.setUInt16(bytePos + 4 , xw); bytes.setUInt16(bytePos + 6,  yh);
						bytes.setUInt16(bytePos + 8 , x ); bytes.setUInt16(bytePos + 10, yh);
						bytes.setUInt16(bytePos + 12, xw); bytes.setUInt16(bytePos + 14, y );
						bytes.setUInt16(bytePos + 16, x ); bytes.setUInt16(bytePos + 18, y );
						bytes.setUInt16(bytePos + 20, x ); bytes.setUInt16(bytePos + 22, y );
					}
				},
				/*macro $b{[
					macro {bytes.setUInt16(bytePos + $v{i}    , x); bytes.setUInt16(bytePos + $v{i+=2},  y);},
					macro {bytes.setUInt16(bytePos + $v{i+=2} , w); bytes.setUInt16(bytePos + $v{i+=2},  h);},
				]}*/
				/*parseExpr('{
					bytes.setUInt16(bytePos + 0 , x); bytes.setUInt16(bytePos + 2,  y);
					bytes.setUInt16(bytePos + 4 , w); bytes.setUInt16(bytePos + 6,  h);
				}')*/
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
		
		// ------------------ bind vertex attributes tp program ----------------------------------
		fields.push({
			name: "bindAttribLocations",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL},
				       {name:"glProgram", type:macro:peote.view.PeoteGL.GLProgram}
				],
				expr: macro {
					if (peote.view.PeoteGL.Version.isINSTANCED)
						gl.bindAttribLocation(glProgram, aPOSITION, "aPosition");
					gl.bindAttribLocation(glProgram, aPOSSIZE, "aPossize");
				},
				ret: null
			})
		});
				
		// ------------------------ enable/disable vertex attributes ------------------------------
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
				expr: macro {
					gl.bindBuffer(gl.ARRAY_BUFFER, glInstanceBuffer);
					gl.enableVertexAttribArray (aPOSITION);
					gl.vertexAttribPointer(aPOSITION, 2, gl.SHORT, false, 4, 0 ); // vertexstride 0 should calc automatically					
					gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
					gl.enableVertexAttribArray (aPOSSIZE);
					gl.vertexAttribPointer(aPOSSIZE, 4, gl.SHORT, false, 8, 0 ); // vertexstride 0 should calc automatically
					gl.vertexAttribDivisor(aPOSSIZE, 1); // one per instance
					
					// TODO.. rest of attributes
				},
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
				expr: macro {
					gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);						
					gl.enableVertexAttribArray (aPOSITION);
					gl.vertexAttribPointer(aPOSITION, 2, gl.SHORT, false, 4, 0 ); // vertexstride 0 should calc automatically
				
					// TODO.. rest of attributes
				},
				ret: null
			})
		});
		// -------------------------
		fields.push({
			name: "disableVertexAttrib",
			meta: allowForBuffer,
			access: [Access.APrivate, Access.AStatic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"gl", type:macro:peote.view.PeoteGL}
				],
				expr: macro {
					gl.disableVertexAttribArray (aPOSITION);
					if (peote.view.PeoteGL.Version.isINSTANCED) 
						gl.disableVertexAttribArray (aPOSSIZE);
					
					// TODO.. rest of attributes
				},
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