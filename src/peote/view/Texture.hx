package peote.view;

import peote.view.PeoteGL.Image;
import peote.view.PeoteGL.GLTexture;

typedef ImgProp = {imageSlot:Int}; //isRotated

@:allow(peote.view)
class Texture 
{
	var gl:PeoteGL = null;

	public var glTexture(default, null):GLTexture = null;	
	
	var used:Int = 0; //TODO (from program)
	
	public var colorChannels(default, null):Int=4;
	
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	
	public var imageSlots(default, null):Int = 1;
	public var slotsX(default, null):Int = 1;
	public var slotsY(default, null):Int = 1;
	
	public var slotWidth(default, null):Int;
	public var slotHeight(default, null):Int;
	
	public var images = new Map<Image, ImgProp>();
	
	public var createMipmaps:Bool = false;
	public var magFilter:Int = 0;
	public var minFilter:Int = 0;


	var updated:Bool = false;
	
	public function new(slotWidth:Int, slotHeight:Int, imageSlots:Int=1, colorChannels:Int=4, createMipmaps:Bool=false, magFilter:Int=0, minFilter:Int=0)
	{
		this.slotWidth = slotWidth;
		this.slotHeight = slotHeight;
		this.imageSlots = imageSlots;
		this.colorChannels = colorChannels;
		this.createMipmaps = createMipmaps;
		this.magFilter = magFilter;
		this.minFilter = minFilter;
	}
	
	private function setToProgram(program:Program):Bool
	{
		if (gl != program.gl) // new or different GL-Context
		{
			if (gl != null) {
				if (used > 0) return false; // already used by another gl-context
				else clearOldGLContext();
			}
			setNewGLContext(program.gl);
		}
		used++;
		return true;
	}

	private inline function removedFromProgram():Void
	{
		used--;
	}
	
	private inline function setNewGLContext(newGl:PeoteGL)
	{
		trace("Texture setNewGLContext");
		gl = newGl;
		createTexture();
		// all images to gpu
		for (image in images.keys()) bufferImage(image,images.get(image));
	}
	
	private inline function clearOldGLContext() 
	{
		trace("Texture clearOldGLContext");
		if (used > 1) throw("Error, texture can not change gl context if used by another program");
		//TODO
		gl.deleteTexture(glTexture);
		glTexture = null;
	}
	
	private inline function createTexture()
	{
		trace("Create new Texture");
		// optimal size!
		var p = optimalTextureSize(imageSlots, slotWidth, slotHeight, gl.getParameter(gl.MAX_TEXTURE_SIZE));
		width = p.width;
		height = p.height;
		slotsX = p.slotsX;
		slotsY = p.slotsY;
		glTexture = createEmptyTexture(gl, width, height, colorChannels, createMipmaps, magFilter, minFilter);			
	}

	public function setImage(image:Image, imageSlot:Int = 0) {
		trace("Set Image into Texture Slot"+imageSlot);
		images.set(image, {imageSlot:imageSlot}); // TODO: is already set?
		if (gl != null) {
			if (glTexture == null) createTexture();
			bufferImage(image, {imageSlot:imageSlot});
		}
	}
	
	private function bufferImage(image:Image, imgProp:ImgProp) {
		trace("buffer Image to Texture");
		
		// TODO
		imageToTexture(gl, glTexture,
		                   slotWidth * (imgProp.imageSlot % slotsX),
		                   slotHeight * Math.floor(imgProp.imageSlot / slotsX),
		                   image.width, image.height, //slotWidth, slotHeight,
		                   image, false );		
		
		// to reset peoteView.glStateTexture
		updated = true;
	}
	
	private static inline function imageToTexture(gl:PeoteGL, glTexture:PeoteGL.GLTexture, x:Int, y:Int, w:Int, h:Int, 
	                                              image:Image, createMipmaps:Bool=false):Void
	{
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		//gl.texSubImage2D(gl.TEXTURE_2D, 0, x, y, w, h, gl.RGBA, gl.UNSIGNED_BYTE,  image.buffer.data );
		gl.texSubImage2D(gl.TEXTURE_2D, 0, x, y, w, h, gl.RGBA, gl.UNSIGNED_BYTE,  image.data );
		
		if (createMipmaps) { // re-create for full texture ?
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.NICEST);
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.FASTEST);
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
	
	private static inline function createEmptyTexture(gl:PeoteGL, width:Int, height:Int, colorChannels:Int = 4,
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
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.NICEST);
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.FASTEST);
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

		if (createMipmaps) gl.generateMipmap(gl.TEXTURE_2D);
		
		//peoteView.glStateTexture.set(gl.getInteger(gl.ACTIVE_TEXTURE), null); // TODO: check with multiwindows (gl.getInteger did not work on html5)
		gl.bindTexture(gl.TEXTURE_2D, null);
		
		return glTexture;
	}

	public inline function optimalTextureSize(imageSlots:Int, slotWidth:Int, slotHeight:Int, maxTextureSize:Int):Dynamic
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
            trace('${imageSlots} imageSlots (${param.slotsX} * ${param.slotsY}) on ${param.width} x ${param.height} Texture'); 
        }
        else
		{
			param = null;
			throw("Error: texture size can not be calculated");			
		}
		return(param);
		
    }

}