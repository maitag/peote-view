package peote.view.intern;

import peote.view.PeoteGL.GLTexture;
import peote.view.TextureConfig;

class TexUtils 
{

	// TODO: also let use optional Data here
	public static function createEmptyTexture(gl:PeoteGL, width:Int, height:Int, format:TextureFormat,
	                                          smoothExpand:Bool = false, smoothShrink:Bool = false,
	                                          mipmap:Bool = false, smoothMipmap:Bool = false):GLTexture
	{
		// mabye better by using ARB-STORAGE (its like malloc!), loot at here:
		// https://registry.khronos.org/OpenGL/extensions/ARB/ARB_texture_storage.txt
		// https://www.khronos.org/opengl/wiki/Texture_Storage#Immutable_storage
		var glTexture:GLTexture = gl.createTexture();
		
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		GLTool.clearGlErrorQueue(gl);
		// <-- TODO: using only shared RAM on neko/cpp with "0" .. better using empty image-data or maybe ARB-STORAGE
		if (format.isFloat) {
			// sometimes 32 float is essential for multipass-rendering,
			// needs EXT_color_buffer_float or OES_texture_float extension

			// CHECK: ( at now only in Texture.hx -> createFramebuffer()  
			// if (gl.getExtension("EXT_color_buffer_float") != null) {}
			// else if (gl.getExtension("OES_texture_float") != null) {}


			gl.texImage2D(gl.TEXTURE_2D, 0, format.float32(gl), width, height, 0, format.formatFloat(gl), gl.FLOAT, 0);
			if (GLTool.getLastGlError(gl) == gl.INVALID_VALUE) {
				#if peoteview_debug_texture
				trace("switching to lower float precision while texture creation");
				#end
				gl.texImage2D(gl.TEXTURE_2D, 0, format.float16(gl), width, height, 0, format.formatFloat(gl), gl.FLOAT, 0);
				if (GLTool.getLastGlError(gl) == gl.INVALID_VALUE) {
					#if peoteview_debug_texture
					trace("fallback for float precision while texture creation");
					#end
					gl.texImage2D(gl.TEXTURE_2D, 0, format.formatFloat(gl), width, height, 0, format.formatFloat(gl), gl.FLOAT, 0);
				}
			}
		}
		else gl.texImage2D(gl.TEXTURE_2D, 0, format.integer(gl), width, height, 0, format.formatInteger(gl), gl.UNSIGNED_BYTE, 0);
		
		if (GLTool.getLastGlError(gl) == gl.OUT_OF_MEMORY) throw("OUT OF GPU MEMORY while texture creation");
		
		setMinMagFilter(gl, smoothExpand, smoothShrink, (mipmap) ? smoothMipmap : null);
		
		// firefox needs this texture wrapping for gl.texSubImage2D if imagesize is non power of 2 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		//peoteView.glStateTexture.set(gl.getInteger(gl.ACTIVE_TEXTURE), null); // TODO: check with multiwindows (gl.getInteger did not work on html5)
		gl.bindTexture(gl.TEXTURE_2D, null);
		
		return glTexture;
	}

	public static function dataToTexture(gl:PeoteGL, x:Int, y:Int, format:TextureFormat, textureData:TextureData, genMipmap:Bool, ?glTexture:GLTexture)
	{
		#if peoteview_debug_texture
		trace("send TextureData to Texture");
		#end

		if (glTexture != null) gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		GLTool.clearGlErrorQueue(gl);

		if (format.isFloat) {
			gl.texSubImage2D_Float(gl.TEXTURE_2D, 0, x, y, textureData.width, textureData.height, format.formatFloat(gl), gl.FLOAT, textureData);
			if (GLTool.getLastGlError(gl) == gl.INVALID_VALUE) {
				#if peoteview_debug_texture
				trace("Error while dataToTexture for float-texture");
				#end
			}
		}
		else gl.texSubImage2D(gl.TEXTURE_2D, 0, x, y, textureData.width, textureData.height, format.formatInteger(gl), gl.UNSIGNED_BYTE, textureData);

		if (GLTool.getLastGlError(gl) == gl.OUT_OF_MEMORY) throw("OUT OF GPU MEMORY while texture creation");

		if (genMipmap) createMipmap(gl);
		
		if (glTexture != null) gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
	public static inline function setMinMagFilter(gl:PeoteGL, ?smoothExpand:Null<Bool>, ?smoothShrink:Null<Bool>, ?smoothMipmap:Null<Bool>, ?glTexture:GLTexture) {
		if (glTexture != null) gl.bindTexture(gl.TEXTURE_2D, glTexture);

		// magnification filter:
		if (smoothExpand != null) gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, (smoothExpand) ? gl.LINEAR : gl.NEAREST);
		
		// minification filter:
		if (smoothShrink != null)
		{
			if (smoothMipmap != null)
			{
				//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.NICEST);
				//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.FASTEST);
				if (smoothMipmap) 
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, (smoothShrink) ? gl.LINEAR_MIPMAP_LINEAR : gl.NEAREST_MIPMAP_LINEAR);
				else 
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, (smoothShrink) ? gl.LINEAR_MIPMAP_NEAREST : gl.NEAREST_MIPMAP_NEAREST);
			}
			else gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, (smoothShrink) ? gl.LINEAR : gl.NEAREST);
		}

		if (glTexture != null) gl.bindTexture(gl.TEXTURE_2D, null);
	}

	public static inline function createMipmap(gl:PeoteGL, ?glTexture:GLTexture) {
		if (glTexture != null) gl.bindTexture(gl.TEXTURE_2D, glTexture);
		//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.NICEST);
		//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.FASTEST);
		gl.generateMipmap(gl.TEXTURE_2D);
		if (glTexture != null) gl.bindTexture(gl.TEXTURE_2D, null);
	}

	/*
	public static function createDepthTexture(gl:PeoteGL, width:Int, height:Int):GLTexture
	{
		var glTexture:GLTexture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT24, width, height, 0, gl.DEPTH_COMPONENT, gl.UNSIGNED_INT, 0);
		// TODO: check later like here -> 
		//       https://github.com/KhronosGroup/WebGL/blob/master/sdk/tests/conformance2/renderbuffers/framebuffer-object-attachment.html#L63
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
	*/
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
	


	
	public static function optimalTextureSize(slots:Int, slotWidth:Int, slotHeight:Int, maxTextureSize:Int, powerOfTwo=true, errorIfNotFit=true, debug=true):{width:Int, height:Int, slotsX:Int, slotsY:Int}
	{
		if (powerOfTwo) return optimalTextureSizePowerTwo(slots, slotWidth, slotHeight, maxTextureSize, errorIfNotFit, debug);
		
		if (slots < 1) throw('Error: the slots have to be greater then 1');
		else if (slots == 1) {
			if (slotWidth > maxTextureSize || slotHeight > maxTextureSize) 
				throw('Error: max texture-size ($maxTextureSize) is to small for image ($slotWidth x $slotHeight)');
			else return {
				width:  slotWidth,
				height: slotHeight,
				slotsX: 1,
				slotsY: 1,
			};
		}

		var wMax:Int = Std.int(maxTextureSize/slotWidth);
		var hMax:Int = Std.int(maxTextureSize/slotHeight);

		var w:Int = Std.int( Math.sqrt( (slots * slotHeight) / slotWidth ) );
		var best:Int = w;
		var h:Int = Math.ceil(slots / w);
		var r:Int = w * h - slots;
		var aspect:Null<Float> = null;
		
		if (h <= hMax && w <= wMax)
		{
			while (r > 0 && w < slots && w < wMax) {
				w++;
				h = Math.ceil(slots / w);
				if (w * h - slots < r) { 
					r = w * h - slots; 
					best = w;
				}
			}
			w = best;
			h = Math.ceil(slots / w);
			aspect = ((w*slotWidth) > (h*slotHeight)) ? (w*slotWidth)/(h*slotHeight) : (h*slotHeight)/(w*slotWidth);
		}

		if (aspect == null || aspect != 1.0) 
		{
			var _h:Int = Std.int( Math.sqrt( (slots * slotWidth) / slotHeight ) );
			best = _h;
			var _w:Int = Math.ceil(slots / _h);
			var _r:Int = _w * _h - slots;
			var _aspect:Null<Float> = null;
		
			if (_w <= wMax && _h <= hMax) 
			{
				while (_r > 0 && _h < slots && _h < hMax) {
					_h++;
					_w = Math.ceil(slots / _h);
					if (_w * _h - slots < _r) {
						_r = _w * _h - slots;		
						best = _h;
					}
				}
				_h = best;
				_w = Math.ceil(slots / _h);
				aspect = (((_w*slotWidth) > (_h*slotHeight)) ? (_w*slotWidth)/(_h*slotHeight) : (_h*slotHeight)/(_w*slotWidth));
			}
		
			if (aspect == null && _aspect == null) {
				if (errorIfNotFit) throw('Error: max texture-size ($maxTextureSize) is to small for $slots images ($slotWidth x $slotHeight)');
				w = wMax;
				h = hMax;
			}
			else if (aspect == null || (_aspect != null && (_r < r || ( _r == r && aspect > _aspect))) )
			{
				w = _w;
				h = _h;
			}
		}
		
		return ({
			width:  w*slotWidth,
			height: h*slotHeight,
			slotsX: w,
			slotsY: h,
		});
	}

	static inline function optimalTextureSizePowerTwo(slots:Int, slotWidth:Int, slotHeight:Int, maxTextureSize:Int, errorIfNotFit=true, debug=true):{width:Int, height:Int, slotsX:Int, slotsY:Int}
    {
        var mts = Math.ceil( Math.log(maxTextureSize) / Math.log(2) );
        
        var a:Int = Math.ceil( Math.log(slots * slotWidth * slotHeight ) / Math.log(2) );  //trace(a);
        var r:Int; // unused area -> minimize!
        var w:Int = 1;
        var h:Int = a-1;
        var delta:Int = Math.floor(Math.abs(w - h));
        var rmin:Int = (1 << mts) * (1 << mts);
        var found:Bool = false;
        var n:Int = Math.floor(Math.min( mts, a ));
		var m:Int;
        
        while ((1 << n) >= slotWidth)
        {
 	        m = Math.floor(Math.min( mts, a - n + 1 ));
            while ((1 << m) >= slotHeight)
            {	//trace('  $n,$m - ${1<<n} w ${1<<m}');  
                if (Math.floor((1 << n) / slotWidth) * Math.floor((1 << m) / slotHeight) < slots) break;
                r = ( (1 << n) * (1 << m) ) - (slots * slotWidth * slotHeight);    //trace('$r');   
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
    	
        if (found)
        {
			//trace('optimal:$w,$h - ${1<<w} x ${1<<h}');
			w = 1 << w;
			h = 1 << h;
        }
        else
		{
			if (errorIfNotFit) throw('Error: max texture-size ($maxTextureSize) is to small for $slots images ($slotWidth x $slotHeight)');
			if (slotWidth > maxTextureSize || slotHeight > maxTextureSize) throw('Error: max texture-size ($maxTextureSize) is to small for image ($slotWidth x $slotHeight)');
			w = h = maxTextureSize;
		}
				
		return ({
			width:  w,
			height: h,
			slotsX: Std.int(w/slotWidth),
			slotsY: Std.int(h/slotHeight),
		});
		
    }


}