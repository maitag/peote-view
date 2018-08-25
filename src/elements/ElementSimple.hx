package elements;

import peote.view.Element;

class ElementSimple implements Element
{
	@positionX @const public var x:Int=0; // signed 2 bytes integer
	@positionY  public var y:Int=0; // signed 2 bytes integer
	@positionZ  public var z:Int=0; // signed 2 bytes integer
	@width @const public var w:Int=100;
	@height public var h:Int=100;
	@color  public var c:Int = 0x000000;  // unsigned 4 bytes integer
	
	/*
	@positionX  public var x:Array<Int>=[0,0]; // signed 2 bytes integer
	@positionY  public var y:Int=0; // signed 2 bytes integer
	@timesteps  public var t:Array<Int>;
	*/
	
	public function new()
	{
		
	}
	
	// ----------------------------------------------------------------------------------
	@:allow(peote.view) var bytePos:Int = -1;
	@:allow(peote.view) var dataPointer: lime.utils.DataPointer;
	
	#if (peoteview_es3 && peoteview_instancedrawing)
	static var instanceBytes: haxe.io.Bytes;
	#end
	
	@:allow(peote.view) static inline function createInstanceBytes():Void
	{
		#if (peoteview_es3 && peoteview_instancedrawing)
		trace("create instance buffer");
		instanceBytes = haxe.io.Bytes.alloc(VERTEX_COUNT * 4);
		var x = 0;
		var y = 0;
		var w = 1;
		var h = 1;
		var xw = x + w;
		var yh = y + h;
		instanceBytes.setUInt16(4 , xw); instanceBytes.setUInt16(6,  yh);
		instanceBytes.setUInt16(0 , xw); instanceBytes.setUInt16(2,  yh);
		instanceBytes.setUInt16(8 , x ); instanceBytes.setUInt16(10, yh);
		instanceBytes.setUInt16(12, xw); instanceBytes.setUInt16(14, y );
		instanceBytes.setUInt16(16, x ); instanceBytes.setUInt16(18, y );
		instanceBytes.setUInt16(20, x ); instanceBytes.setUInt16(22, y );
		#end
	}	
	
	@:allow(peote.view) static inline function updateInstanceGLBuffer(gl: peote.view.PeoteGL, glInstanceBuffer: lime.graphics.opengl.GLBuffer):Void
	{
		#if (peoteview_es3 && peoteview_instancedrawing)
		trace("update instance GLbuffer");
		gl.bindBuffer (gl.ARRAY_BUFFER, glInstanceBuffer);
		gl.bufferData (gl.ARRAY_BUFFER, instanceBytes.length, instanceBytes, gl.STATIC_DRAW);
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
		#end
	}	
	
	@:allow(peote.view) private function writeBytes(bytes:haxe.io.Bytes):Void
	{
		#if (peoteview_es3 && peoteview_instancedrawing)
		bytes.setUInt16(bytePos + 0 , x); bytes.setUInt16(bytePos + 2,  y);
		bytes.setUInt16(bytePos + 4 , w); bytes.setUInt16(bytePos + 6,  h);
		#else
		var xw = x + w;
		var yh = y + h;
		bytes.setUInt16(bytePos + 0 , xw); bytes.setUInt16(bytePos + 2,  yh);
		bytes.setUInt16(bytePos + 4 , xw); bytes.setUInt16(bytePos + 6,  yh);
		bytes.setUInt16(bytePos + 8 , x ); bytes.setUInt16(bytePos + 10, yh);
		bytes.setUInt16(bytePos + 12, xw); bytes.setUInt16(bytePos + 14, y );
		bytes.setUInt16(bytePos + 16, x ); bytes.setUInt16(bytePos + 18, y );
		bytes.setUInt16(bytePos + 20, x ); bytes.setUInt16(bytePos + 22, y );
		#end
	}
	
	// ----------------------------------------------------------------------------------		
	@:allow(peote.view) inline function updateGLBuffer(gl: peote.view.PeoteGL, glBuffer: lime.graphics.opengl.GLBuffer):Void
	{
		gl.bindBuffer (gl.ARRAY_BUFFER, glBuffer);
		gl.bufferSubData(gl.ARRAY_BUFFER, bytePos, BUFF_SIZE, dataPointer );
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}
		
	// ----------------------------------------------------------------------------------
	public static inline var aPOSITION:Int  = 0;
	
	#if (peoteview_es3 && peoteview_instancedrawing)
	public static inline var aPOSSIZE:Int  = 1;
	#end
	
	@:allow(peote.view) static inline function bindAttribLocations(gl: peote.view.PeoteGL, glProgram: lime.graphics.opengl.GLProgram):Void
	{
		gl.bindAttribLocation(glProgram, aPOSITION, "aPosition");
		#if (peoteview_es3 && peoteview_instancedrawing)
		gl.bindAttribLocation(glProgram, aPOSSIZE, "aPossize");
		#end
	}
	
	@:allow(peote.view) static inline var VERTEX_COUNT:Int = 6;
	
	#if (peoteview_es3 && peoteview_instancedrawing)
	@:allow(peote.view) static inline var BUFF_SIZE:Int = 8;
	#else
	@:allow(peote.view) static inline var BUFF_SIZE:Int = VERTEX_COUNT * 4;
	#end
	
	@:allow(peote.view) static inline function render(maxElements:Int, gl: peote.view.PeoteGL, glBuffer: lime.graphics.opengl.GLBuffer, glInstanceBuffer: lime.graphics.opengl.GLBuffer):Void
	{
		#if (peoteview_es3 && peoteview_instancedrawing)
		gl.bindBuffer(gl.ARRAY_BUFFER, glInstanceBuffer);
		gl.enableVertexAttribArray (aPOSITION);
		gl.vertexAttribPointer(aPOSITION, 2, gl.SHORT, false, 4, 0 ); // vertexstride 0 should calc automatically
		
		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
		gl.enableVertexAttribArray (aPOSSIZE);
		gl.vertexAttribPointer(aPOSSIZE, 4, gl.SHORT, false, 8, 0 ); // vertexstride 0 should calc automatically
		gl.vertexAttribDivisor(aPOSSIZE, 1); // one per instance
		
		gl.drawArraysInstanced (gl.TRIANGLE_STRIP,  0, VERTEX_COUNT, maxElements);
		
		gl.disableVertexAttribArray (aPOSITION);
		gl.disableVertexAttribArray (aPOSSIZE);
		
		#else
		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
		
		gl.enableVertexAttribArray (aPOSITION);
		gl.vertexAttribPointer(aPOSITION, 2, gl.SHORT, false, 4, 0 ); // vertexstride 0 should calc automatically
		
		gl.drawArrays (gl.TRIANGLE_STRIP,  0,  maxElements*VERTEX_COUNT);
		
		gl.disableVertexAttribArray (aPOSITION);
		#end
		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}

	// ----------------------------------------------------------------------------------	
	public static var rComments:EReg = new EReg("//.*?$","gm");
	public static var rEmptylines:EReg = new EReg("([ \t]*\r?\n)+", "g");
	public static var rStartspaces:EReg = new EReg("^([ \t]*\r?\n)+", "g");

	static inline function parseShader(shader:String):String {
		var v = {
			isES3:false,
			ATTRIBUTE:"attribute",
			isUBO:false,
			isINSTANCED:false,
		};
		#if peoteview_es3
		v.isES3 = true;
		v.ATTRIBUTE = "in";
			#if peoteview_uniformbuffers
			v.isUBO = true;
			#end
			#if peoteview_instancedrawing
			v.isINSTANCED = true;
			#end
		#end
		
		var template = new haxe.Template(shader);			
		return rStartspaces.replace(rEmptylines.replace(rComments.replace(template.execute(v), ""), "\n"), "");
	}
	
	@:allow(peote.view) static inline function get_vertexShader():String {
		//trace("-------vertexShader----------");
		//trace(parseShader(vertexShader));
		return parseShader(vertexShader);
	}
	
	@:allow(peote.view) static var vertexShader(get, null):String =
	// #extension GL_ARB_uniform_buffer_object : enable
	"
	::if isES3::#version 300 es::end::
	
	// Uniforms -------------------------
	::if isUBO::
	layout(std140) uniform uboView
	{
		vec2 uResolution;
	};
	layout(std140) uniform uboDisplay
	{
		vec2 uOffset;
	};
	::else::
	uniform vec2 uResolution;
	uniform vec2 uOffset;
	::end::
	
	// Attributes -------------------------
	::ATTRIBUTE:: vec2 aPosition;
	
	::if isINSTANCED::
	::ATTRIBUTE:: vec4 aPossize;
	::end::
	
	// custom Attributes ------------------
	
	void main(void) {
		::if isINSTANCED::
		vec2 position = (aPosition * vec2(aPossize.z, aPossize.w)) + vec2(aPossize.x, aPossize.y);
		::else::
		vec2 position = aPosition;
		::end::

		float zoom = 1.0;
		float width = uResolution.x;
		float height = uResolution.y;
		float deltaX = uOffset.x;
		float deltaY = uOffset.y;
			
		float right = width-deltaX*zoom;
		float left = -deltaX*zoom;
		float bottom = height-deltaY*zoom;
		float top = -deltaY * zoom;
			
		gl_Position = mat4 (
			vec4(2.0 / (right - left)*zoom, 0.0, 0.0, 0.0),
			vec4(0.0, 2.0 / (top - bottom)*zoom, 0.0, 0.0),
			vec4(0.0, 0.0, -1.0, 0.0),
			vec4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), 0.0, 1.0)
		)
		* vec4 (position ,
			0.0
			, 1.0
			);
	}
	";
	
	@:allow(peote.view) static inline function get_fragmentShader():String {
		//trace("-------fragmentshader----------");
		//trace("parseShader(fragmentShader));
		return parseShader(fragmentShader);
	}
	
	@:allow(peote.view) static var fragmentShader(get, null):String =	
	"
	::if isES3::#version 300 es::end::
	
    precision highp float;
	
	::if isES3::
	out vec4 color;
	::end::


	void main(void)
	{	
		::if isES3::color::else::gl_FragColor::end:: = vec4 (1.0, 0.0, 0.0, 1.0);
	}
	";


}
