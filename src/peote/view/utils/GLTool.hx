package peote.view.utils;

import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;

class GLTool 
{

	static public inline function createFramebuffer(gl:PeoteGL):GLFramebuffer
	{
		return (gl.createFramebuffer());
	}
	
	static public inline function compileGLShader(gl:PeoteGL, type:Int, shaderSrc:String):GLShader
	{
		trace('compile ${(type==gl.VERTEX_SHADER) ? "vertex":"fragment"} shader');
		var glShader:GLShader = gl.createShader(type);
		gl.shaderSource(glShader, shaderSrc);
		gl.compileShader(glShader);
		if (gl.getShaderParameter(glShader, gl.COMPILE_STATUS) == 0) {
			trace('ERROR compiling ${(type==gl.VERTEX_SHADER) ? "vertex":"fragment"} shader\n' + gl.getShaderInfoLog(glShader));
			return null;
		} else return glShader;		
	}
	
	static public inline function linkGLProgram(gl:PeoteGL, glProgram:GLProgram):Bool 
	{
		gl.linkProgram(glProgram);

		if (gl.getProgramParameter(glProgram, gl.LINK_STATUS) == 0) // glsl compile error
		{
			trace(gl.getProgramInfoLog(glProgram)
				+ "VALIDATE_STATUS: " + gl.getProgramParameter(glProgram, gl.VALIDATE_STATUS)
				+ "ERROR: " + gl.getError()
			);
			return false;
		}
		else return true;
	}
		
}