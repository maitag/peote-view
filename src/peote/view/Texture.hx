package peote.view;

import peote.view.PeoteGL.Image;
import peote.view.PeoteGL.GLTexture;
import peote.view.PeoteGL.GLFramebuffer;
import peote.view.utils.GLTool;
import peote.view.utils.TexUtils;

typedef ImgProp = {imageSlot:Int}; //isRotated

@:allow(peote.view)
class Texture 
{
	var gl:PeoteGL = null;

	public var glTexture(default, null):GLTexture = null;	
	
	var glDepthTexture:GLTexture;	
	var framebuffer:GLFramebuffer;
	var hasFramebuffer:Bool = false;	
	
	var used:Int = 0; //TODO (from program)
	
	public var colorChannels(default, null):Int=4;
	
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	
	public var imageSlots(default, null):Int = 1;
	
	public var slotsX(default, null):Int = 1;
	public var slotsY(default, null):Int = 1;
	public var slotWidth(default, null):Int;
	public var slotHeight(default, null):Int;

	public var tilesX:Int = 1;
	public var tilesY:Int = 1;
	
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
	
	private inline function setToProgram(program:Program):Bool{
		// TODO if(program.gl != null) ...check gl-context of all programs and displays that using this texture 
		return useIt(program.gl);
	}
	private inline function removeFromProgram(program:Program):Void unUseIt();
	
	private inline function setFramebufferToDisplay(display:Display) {
		hasFramebuffer = true;

		if (useIt(display.gl)) {
			createFramebuffer();
			return true;
		} else return false;
	}
	private inline function removeFramebufferFromDisplay(display:Display):Void {
		hasFramebuffer = true;
		unUseIt();
	}
	// TODO: better store all programs and displays that using this texture and check gl-context inside-> setNewGLContext
	private function useIt(newGl:PeoteGL):Bool
	{
		if (gl != newGl) // new or different GL-Context
		{	
			if (gl != null) {
				if (used > 0) return false; // already used by another gl-context
				else clearOldGLContext();
			}
			setNewGLContext(newGl);
		}
		used++;
		return true;
	}

	private inline function unUseIt():Void
	{
		used--;
	}
	
	private inline function setNewGLContext(newGl:PeoteGL)
	{
		trace("Texture setNewGLContext");
		// TODO:  check gl-context of all programs and displays that using this texture 
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
		deleteFramebuffer();
	}
	
	private inline function createTexture()
	{
		trace("Create new Texture");
		if (width > gl.getParameter(gl.MAX_TEXTURE_SIZE) || height > gl.getParameter(gl.MAX_TEXTURE_SIZE))
			throw("Error, texture size is greater then gl.MAX_TEXTURE_SIZE");
		glTexture = TexUtils.createEmptyTexture(gl, width, height, colorChannels, createMipmaps, magFilter, minFilter);			
	}

	private inline function createFramebuffer() {
		if (!hasFramebuffer) {
			framebuffer = GLTool.createFramebuffer(gl, glTexture, glDepthTexture, width, height); 
		}

	}

	private inline function deleteFramebuffer() {
		if (hasFramebuffer) {
			gl.deleteFramebuffer(framebuffer);
			gl.deleteTexture(glDepthTexture);
		}
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
		                   image, createMipmaps );		
		
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
			//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.NICEST);
			//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.FASTEST);
			gl.generateMipmap(gl.TEXTURE_2D); // TODO: check speed vs quality
		}
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
}