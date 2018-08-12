package peote.view.utils;

import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.BytePointer;

import haxe.io.Bytes;


// for rendering a colored background-GL-quad
class Background 
{
	var gl:PeoteGL;

	var buffer:GLBuffer;
	var program:GLProgram;
	var	aPosition:Int;
	var uRGBA:GLUniformLocation;

	public function new(gl:PeoteGL) {
		this.gl = gl;
		createBuffer();
	}
	
	public function createBuffer():Void
	{
		program = GLProgram.fromSources ( gl,
			// ---------------------------- VERTEX SHADER ---
			"
			attribute vec2 aPosition;
			void main(void)
			{
				gl_Position = mat4 ( // TODO: mathstar-optimize this ;)=
					vec4(2.0, 0.0, 0.0, 0.0),
					vec4(0.0, -2.0, 0.0, 0.0),
					vec4(0.0, 0.0, 0.0, 0.0),
					vec4(-1.0, 1.0, 0.0, 1.0)
				) * vec4 (aPosition, -65000.0 ,1.0); // 65000? -> zIndex (todo for <zero)
			}
			",
			// -------------------------- FRAGMENT SHADER ---
			"precision mediump float;" +
			"
			uniform vec4 uRGBA;
			void main(void)
			{
				gl_FragColor = uRGBA;
			}
			"				
		);
		
		aPosition = gl.getAttribLocation (program, "aPosition");
		uRGBA = gl.getUniformLocation (program, "uRGBA");
		
		var bytes:Bytes = Bytes.alloc(8 * 4);

		bytes.setFloat(0,  1);bytes.setFloat(4,  1);
		bytes.setFloat(8,  0);bytes.setFloat(12, 1);
		bytes.setFloat(16, 1);bytes.setFloat(20, 0);
		bytes.setFloat(24, 0);bytes.setFloat(28, 0);
		
		buffer = gl.createBuffer ();
		gl.bindBuffer (gl.ARRAY_BUFFER, buffer);
		//gl.bufferData (gl.ARRAY_BUFFER, new Float32Array (data), gl.STATIC_DRAW);
		gl.bufferData (gl.ARRAY_BUFFER, 8*4, new BytePointer(bytes), gl.STATIC_DRAW);
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}
	
	public function render(r:Float, g:Float, b:Float, a:Float):Void
	{
		gl.bindBuffer (gl.ARRAY_BUFFER, buffer);
		
		gl.enableVertexAttribArray (aPosition);
		gl.vertexAttribPointer (aPosition, 2, gl.FLOAT, false, 8, 0);
		
		gl.useProgram (program);
		gl.uniform4f ( uRGBA, r,g,b,a);
		
		gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
		gl.disableVertexAttribArray (aPosition);
	}
	
	
}