package peote.view.utils;

import peote.view.PeoteGL.GLTexture;

class TexUtils 
{

	public static function createEmptyTexture(gl:PeoteGL, width:Int, height:Int, colorChannels:Int = 4,
	                                          createMipmaps:Bool=false, magFilter:Int=0, minFilter:Int=0):GLTexture
	{
		// TODO: colorchannels !
		
		var glTexture:GLTexture = gl.createTexture();
		
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, 0);
		// sometimes 32 float is essential for multipass-rendering (needs extension EXT_color_buffer_float)
		// gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32F, width, height, 0, gl.RGBA, gl.FLOAT, 0);
		
		
		// TODO: outsource into other function ?
		// magnification filter (only this values are usual):
		switch (magFilter) {
			default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST); //bilinear
			case 1: gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);  //trilinear
		}
		
		// minification filter:
		if (createMipmaps)
		{
			//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.NICEST);
			//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.FASTEST);
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
		
		if (createMipmaps) { // re-create for full texture ?
			//gl.hint(GL.GENERATE_MIPMAP_HINT, gl.NICEST);
			//gl.hint(GL.GENERATE_MIPMAP_HINT, gl.FASTEST);
			gl.generateMipmap(gl.TEXTURE_2D); // again after texSubImage2D!
		}

		//peoteView.glStateTexture.set(gl.getInteger(gl.ACTIVE_TEXTURE), null); // TODO: check with multiwindows (gl.getInteger did not work on html5)
		gl.bindTexture(gl.TEXTURE_2D, null);
		
		return glTexture;
	}
	
	public static function createDepthTexture(gl:PeoteGL, width:Int, height:Int):GLTexture
	{
		var glTexture:GLTexture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT24, width, height, 0, gl.DEPTH_COMPONENT, gl.UNSIGNED_INT, 0);
		// TODO: check later like here -> https://github.com/KhronosGroup/WebGL/blob/master/sdk/tests/conformance2/renderbuffers/framebuffer-object-attachment.html#L63
		//gl.texImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT16, width, height, 0, gl.DEPTH_COMPONENT, gl.UNSIGNED_SHORT, 0);
		//gl.texImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT, width, height, 0, gl.DEPTH_COMPONENT, gl.UNSIGNED_SHORT, 0);
		//gl.texImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT24, width, height, 0, gl.DEPTH_COMPONENT, gl.UNSIGNED_SHORT, 0);
		
				
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST); // <- bilinear 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		
		// firefox needs this texture wrapping for gl.texSubImage2D if imagesize is non power of 2 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		gl.bindTexture(gl.TEXTURE_2D, null);		
		return glTexture;
	}

	public static function createPickingTexture(gl:PeoteGL, isRGBA32I:Bool=false):GLTexture
	{
		var glTexture:GLTexture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		if (isRGBA32I) gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32I, 1, 1, 0, gl.RGBA_INTEGER, gl.INT,           0);
		else           gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA,    1, 1, 0, gl.RGBA,         gl.UNSIGNED_BYTE, 0);
		// TODO better check gl-error here -> var err; while ((err = gl.getError()) != gl.NO_ERROR) trace(err);
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST); // <- bilinear 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		
		// firefox needs this texture wrapping for gl.texSubImage2D if imagesize is non power of 2 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		gl.bindTexture(gl.TEXTURE_2D, null);		
		return glTexture;
	}
	
	public static function optimalTextureSize(imageSlots:Int, slotWidth:Int, slotHeight:Int, maxTextureSize:Int):Dynamic
    {
        maxTextureSize = Math.ceil( Math.log(maxTextureSize) / Math.log(2) );
        
        var a:Int = Math.ceil( Math.log(imageSlots * slotWidth * slotHeight ) / Math.log(2) );  //trace(a);
        var r:Int; // unused area -> minimize!
        var w:Int = 1;
        var h:Int = a-1;
        var delta:Int = Math.floor(Math.abs(w - h));
        var rmin:Int = (1 << maxTextureSize) * (1 << maxTextureSize);
        var found:Bool = false;
        var n:Int = Math.floor(Math.min( maxTextureSize, a ));
		var m:Int;
        
        while ((1 << n) >= slotWidth)
        {
 	        m = Math.floor(Math.min( maxTextureSize, a - n + 1 ));
            while ((1 << m) >= slotHeight)
            {	//trace('  $n,$m - ${1<<n} w ${1<<m}');  
                if (Math.floor((1 << n) / slotWidth) * Math.floor((1 << m) / slotHeight) < imageSlots) break;
                r = ( (1 << n) * (1 << m) ) - (imageSlots * slotWidth * slotHeight);    //trace('$r');   
				if (r < 0) break;
                if (r <= rmin)
                {
                    if (r == rmin)
                    {
                        if (Math.abs(n - m) < delta)
                        {
                            delta = Math.floor(Math.abs(n - m));
                            w = n; h = m;
                            found = true;
                        }
                    }
                    else
                    {
                        w = n; h = m;
                        rmin = r;
                        found = true;
                    } 
                    //trace('$r  -  $n,$m - ${1<<n} w ${1<<m}');
                }
                m--;
            }
            n--;
        }
    	
		var param:Dynamic = {};
        if (found)
        {	//trace('optimal:$w,$h - ${1<<w} x ${1<<h}');
            param.slotsX = Math.floor((1 << w) / slotWidth);
            param.slotsY = Math.floor((1 << h) / slotHeight);
			param.imageSlots = param.slotsX * param.slotsY;
			param.width = 1 << w;
			param.height = 1 << h;
			#if peoteview_debug_texture
            trace('${imageSlots} imageSlots (${param.slotsX} * ${param.slotsY}) on ${param.width} x ${param.height} Texture');
			#end
        }
        else
		{
			param = null;
			throw("Error: texture size can not be calculated");			
		}
		return(param);
		
    }
	
}