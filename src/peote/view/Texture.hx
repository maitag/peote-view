package peote.view;

import peote.view.PeoteGL.Image;
import peote.view.PeoteGL.GLTexture;
import peote.view.utils.TexUtils;

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

	public var tilesX(default, null):Int = 1;
	public var tilesY(default, null):Int = 1;
	
	public var images = new Map<Image, ImgProp>();
	
	public var createMipmaps:Bool = false;
	public var magFilter:Int = 0;
	public var minFilter:Int = 0;


	var updated:Bool = false;
	
	public function new(slotWidth:Int, slotHeight:Int, imageSlots:Int=1, colorChannels:Int=4, createMipmaps:Bool=false, magFilter:Int=0, minFilter:Int=0, maxTextureSize:Int=16384)
	{
		this.slotWidth = slotWidth;
		this.slotHeight = slotHeight;
		this.imageSlots = imageSlots;
		this.colorChannels = colorChannels;
		this.createMipmaps = createMipmaps;
		this.magFilter = magFilter;
		this.minFilter = minFilter;
		// optimal size!
		var p = TexUtils.optimalTextureSize(imageSlots, slotWidth, slotHeight, maxTextureSize);
		width = p.width;
		height = p.height;
		slotsX = p.slotsX;
		slotsY = p.slotsY;
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
		if (width > gl.getParameter(gl.MAX_TEXTURE_SIZE) || height > gl.getParameter(gl.MAX_TEXTURE_SIZE))
			throw("Error, texture size is greater then gl.MAX_TEXTURE_SIZE");
		glTexture = TexUtils.createEmptyTexture(gl, width, height, colorChannels, createMipmaps, magFilter, minFilter);			
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
		
		// TODO: overwrite and fit-parameters
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
	
	


}