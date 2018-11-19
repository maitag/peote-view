package peote.view.utils;

import peote.view.PeoteGL.GLFramebuffer;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import utils.MultipassTemplate;

class GLTool 
{

	static public inline function createFramebuffer(gl:PeoteGL):GLFramebuffer
	{
		return (gl.createFramebuffer());
	}
	
	static public inline function compileGLShader(gl:PeoteGL, type:Int, shaderSrc:String):GLShader
	{
		//trace('compile ${(type==gl.VERTEX_SHADER) ? "vertex":"fragment"} shader');
		//trace("\n"+shaderSrc);
		var glShader:GLShader = gl.createShader(type);
		gl.shaderSource(glShader, shaderSrc);
		gl.compileShader(glShader);
		if (gl.getShaderParameter(glShader, gl.COMPILE_STATUS) == 0) {
			throw('ERROR compiling ${(type==gl.VERTEX_SHADER) ? "vertex":"fragment"} shader\n' + gl.getShaderInfoLog(glShader));
			return null;
		} else return glShader;		
	}
	
	static public inline function linkGLProgram(gl:PeoteGL, glProgram:GLProgram):Bool 
	{
		gl.linkProgram(glProgram);

		if (gl.getProgramParameter(glProgram, gl.LINK_STATUS) == 0) // glsl compile error
		{
			throw(gl.getProgramInfoLog(glProgram)
				+ "VALIDATE_STATUS: " + gl.getProgramParameter(glProgram, gl.VALIDATE_STATUS)
				+ "ERROR: " + gl.getError()
			);
			return false;
		}
		else return true;
	}

	static var rComments:EReg = new EReg("//.*?$","gm");
	static var rEmptylines:EReg = new EReg("([ \t]*\r?\n)+", "g");
	static var rStartspaces:EReg = new EReg("^([ \t]*\r?\n)+", "g");

	static public inline function parseShader(shader:String, conf:Dynamic):String {
		var template = new MultipassTemplate(shader);
		return rStartspaces.replace(rEmptylines.replace(rComments.replace(template.execute(conf), ""), "\n"), "");
	}

}