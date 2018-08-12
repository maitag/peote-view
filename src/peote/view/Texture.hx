package peote.view;

import lime.graphics.opengl.GLTexture;
import lime.utils.UInt8Array;

class Texture 
{

	public function new() 
	{
	}
	
	public static inline function createEmptyTexture(gl:PeoteGL, width:Int, height:Int, mipmap:Bool=false, magFilter:Int=0, minFilter:Int=0):GLTexture
	{
		var t:GLTexture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, t);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, 0);
		
		// magnification filter (only this values usual):
		switch (magFilter) {
			default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST); //bilinear
			case 1: gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);  //trilinear
		}
		
		// minification filter:
		if (mipmap)
		{
			switch (minFilter) {
				default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST); //bilinear
				case 1: gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);  //trilinear
				case 2:	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_NEAREST);
				case 3:	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR);				
			}
		}
		else
		{
			switch (minFilter) {
				default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				case 1:	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
			}
		}
		
		// firefox needs this texture wrapping for gl.texSubImage2D if imagesize is non power of 2 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		//gl.generateMipmap(gl.TEXTURE_2D);
		gl.bindTexture(gl.TEXTURE_2D, null);
		return t;
	}
	
}