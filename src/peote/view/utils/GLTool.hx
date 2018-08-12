package peote.view.utils;

import lime.graphics.opengl.GLFramebuffer;

class GLTool 
{

	static public inline function createFramebuffer(gl:PeoteGL):GLFramebuffer
	{
		return (gl.createFramebuffer());
	}
		
}