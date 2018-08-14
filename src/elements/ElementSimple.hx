package elements;

import peote.view.Element;

class ElementSimple implements Element
{
	@:positionX public var x:Int=0;
	@positionY  public var y:Int=0;
	@width  public var w:Int=100;
	@height public var h:Int=100;
	
	
	public function new()
	{
		
	}
	
	// ----------------------------------------------------------------------------------
	@:allow(peote.view) var bytePos:Int = -1;
	@:allow(peote.view) var dataPointer: lime.utils.DataPointer;
	
	#if peoteview_instancedrawing
	static var glInstanceBuffer: lime.graphics.opengl.GLBuffer;
	@:allow(peote.view) static function createInstanceBuffer(gl: peote.view.PeoteGL):Void
	{
		var bytes = haxe.io.Bytes.alloc(BUFF_SIZE);
		var x = 0;
		var y = 0;
		var w = 1;
		var h = 1;
		var xw = x + w;
		var yh = y + h;
		bytes.setUInt16(0 , xw); bytes.setUInt16(2,  yh);
		bytes.setUInt16(4 , xw); bytes.setUInt16(6,  yh);
		bytes.setUInt16(8 , x ); bytes.setUInt16(10, yh);
		bytes.setUInt16(12, xw); bytes.setUInt16(14, y );
		bytes.setUInt16(16, x ); bytes.setUInt16(18, y );
		bytes.setUInt16(20, x ); bytes.setUInt16(22, y );
		
		gl.bindBuffer (gl.ARRAY_BUFFER, glInstanceBuffer);
		gl.bufferData (gl.ARRAY_BUFFER, bytes.length, bytes, gl.STATIC_DRAW);
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}	
	#end
	
	@:allow(peote.view) private function writeBytes(bytes:haxe.io.Bytes):Void
	{
		#if peoteview_instancedrawing
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
	@:allow(peote.view) inline function updateGlBuffer(gl: peote.view.PeoteGL, glBuffer: lime.graphics.opengl.GLBuffer):Void
	{
		gl.bindBuffer (gl.ARRAY_BUFFER, glBuffer);
		gl.bufferSubData(gl.ARRAY_BUFFER, bytePos, BUFF_SIZE, dataPointer );
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}
		
	// ----------------------------------------------------------------------------------
	public static inline var aPOSITION:Int  = 0;
	#if peoteview_instancedrawing
	public static inline var aPOSSIZE:Int  = 1;
	#end
	
	@:allow(peote.view) static inline function bindAttribLocations(gl: peote.view.PeoteGL, glProgram: lime.graphics.opengl.GLProgram):Void
	{
		gl.bindAttribLocation(glProgram, aPOSITION, "aPosition");
		#if peoteview_instancedrawing
		gl.bindAttribLocation(glProgram, aPOSSIZE, "aPossize");
		#end
	}
	
	@:allow(peote.view) static inline var VERTEX_COUNT:Int = 6;
	@:allow(peote.view) static inline var VERTEX_STRIDE:Int  = 4;
	@:allow(peote.view) static inline var BUFF_SIZE:Int = VERTEX_COUNT * VERTEX_STRIDE;
	
	@:allow(peote.view) static inline function render(maxElements:Int, gl: peote.view.PeoteGL, glBuffer: lime.graphics.opengl.GLBuffer):Void
	{
		#if peoteview_instancedrawing
		gl.bindBuffer(gl.ARRAY_BUFFER, glInstanceBuffer);
		gl.enableVertexAttribArray (aPOSITION);
		gl.vertexAttribPointer(aPOSITION, 2, gl.SHORT, false, VERTEX_STRIDE, 0 ); // vertexstride 0 should calc automatically
		
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
		gl.vertexAttribPointer(aPOSITION, 2, gl.SHORT, false, VERTEX_STRIDE, 0 ); // vertexstride 0 should calc automatically
		
		gl.drawArrays (gl.TRIANGLE_STRIP,  0,  maxElements*VERTEX_COUNT);
		
		gl.disableVertexAttribArray (aPOSITION);
		#end
		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}

	// ----------------------------------------------------------------------------------	
	// #extension GL_ARB_uniform_buffer_object : enable
	@:allow(peote.view) static inline function getVertexShader():String {
		return vertexShader;
	}
	@:allow(peote.view) static inline var vertexShader:String =
	#if peoteview_uniformbuffers
	"	#version 300 es
		layout(std140) uniform UProgram
        {
            vec2 uResolution;
		};
		
		in vec2 aPosition;
	"
	#else
	"
		uniform vec2 uResolution;
		
		attribute vec2 aPosition;
	"
	#end

	#if peoteview_instancedrawing
	+ "
		attribute vec4 aPossize;
	"
	#end
	+ "
		void main(void) {
	"
	#if peoteview_instancedrawing
	+ "
			aPosition = (aPosition * vec2(aPossize.x, aPossize.y)) + vec2(aPossize.z, aPossize.w);
	"
	#end	
	+ "
			float zoom = 1.0;
			float width = uResolution.x;
			float height = uResolution.y;
			float deltaX = 0.0;
			float deltaY = 0.0;
			
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
			* vec4 (aPosition ,
				0.0
				, 1.0
				);
		}
	";
	
	@:allow(peote.view) static inline var fragmentShader:String =	
	#if peoteview_ubo
	"	#version 300 es
        precision highp float;
		
		out vec4 color;

		void main(void)
		{	
			color = vec4 (1.0, 0.0, 0.0, 1.0);
		}
	";
	#else
	"	precision highp float;
		
		void main(void)
		{	
			gl_FragColor = vec4 (1.0, 0.0, 0.0, 1.0);
		}
	";
	#end	
}
