package peote.view.utils;

import peote.view.PeoteGL.GLBuffer;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;
import peote.view.PeoteGL.BytePointer;

import haxe.io.Bytes;


// for rendering a colored background-GL-quad
class Background 
{
	var gl:PeoteGL;

	var buffer:GLBuffer;
	var glProgram:GLProgram;
	
	static inline var aPOSITION:Int = 0;
	var uRGBA:GLUniformLocation;

	public function new(gl:PeoteGL) {
		this.gl = gl;
		createBuffer();
		createProgram();
	}
	
	public function createBuffer():Void
	{
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
	
	public function createProgram():Void
	{
		var glVertexShader:GLShader = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,
		"	
			attribute vec2 aPosition;
			void main(void)
			{
				gl_Position = mat4 (
					vec4(2.0, 0.0, 0.0, 0.0),
					vec4(0.0, -2.0, 0.0, 0.0),
					vec4(0.0, 0.0, -1.0, 0.0),
					vec4(-1.0, 1.0, 0.0, 1.0)
				) * vec4 (aPosition, -1.0 ,1.0);
			}
		"
		);
		
		var glFragmentShader:GLShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER,
		"
			precision mediump float;
			
			uniform vec4 uRGBA;
			void main(void)
			{
				gl_FragColor = uRGBA;
				
				// TODO: Fix for old FF
				gl_FragColor.w = clamp(uRGBA.w, 0.003, 1.0);
			}
		"			
		);

		glProgram = gl.createProgram();

		gl.attachShader(glProgram, glVertexShader);
		gl.attachShader(glProgram, glFragmentShader);
		
		gl.deleteShader(glVertexShader);
		gl.deleteShader(glFragmentShader);
		
		gl.bindAttribLocation(glProgram, aPOSITION, "aPosition");

		GLTool.linkGLProgram(gl, glProgram);
		
		uRGBA = gl.getUniformLocation (glProgram, "uRGBA");		
	}
	
	public function render(r:Float, g:Float, b:Float, a:Float):Void
	{
		gl.bindBuffer (gl.ARRAY_BUFFER, buffer);
		
		gl.enableVertexAttribArray (aPOSITION);
		gl.vertexAttribPointer (aPOSITION, 2, gl.FLOAT, false, 8, 0);
		
		gl.useProgram (glProgram);
		gl.uniform4f ( uRGBA, r,g,b,a);
		
		gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
		gl.disableVertexAttribArray (aPOSITION);
		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
	}
	
	
}