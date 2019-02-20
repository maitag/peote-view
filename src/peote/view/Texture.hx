package peote.view;

import lime.graphics.opengl.GLRenderbuffer;
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
	
	var framebuffer:GLFramebuffer = null;
	var glDepthBuffer:GLRenderbuffer = null;	
	
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
	
	var programs = new Array<Program>();
	var displays = new Array<Display>();
	
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
	
 	public inline function usedByProgram(program:Program):Bool return (programs.indexOf(program) >= 0);
	
	private inline function addToProgram(program:Program)
	{
		#if peoteview_debug_texture
		trace("Add Program to Texture");
		#end
		if ( usedByProgram(program) ) throw("Error, texture is already used by program");
		setNewGLContext(program.gl);
		programs.push(program);
	}
	
 	public inline function usedByDisplay(display:Display):Bool return (displays.indexOf(display) >= 0);

	private inline function removeFromProgram(program:Program):Void {
		#if peoteview_debug_texture
		trace("Texture removed from Program");
		#end
		if (!programs.remove(program)) throw("Error, this texture is not used by program anymore");
	}
	
	private inline function addToDisplay(display:Display) {
		#if peoteview_debug_texture
		trace("Add Display to Texture");
		#end
		if ( usedByDisplay(display) ) throw("Error, texture is already used by display");
		setNewGLContext(display.gl);
		displays.push(display);
		createFramebuffer();
	}
	
	private inline function removeFromDisplay(display:Display):Void {
		#if peoteview_debug_texture
		trace("Texture (Framebuffer) removed from Display");
		#end
		if (!displays.remove(display)) throw("Error, this texture (Framebuffer) is not used by display anymore");
		deleteFramebuffer();
	}
		
	private inline function createFramebuffer() {
		if (displays.length > 0 && framebuffer == null) {
			#if peoteview_debug_texture 
			trace("Create Framebuffer");
			#end
			framebuffer = GLTool.createFramebuffer(gl, glTexture, glDepthBuffer, width, height); 
		}
	}

	private inline function deleteFramebuffer() {
		if (displays.length == 0 && framebuffer != null) {
			#if peoteview_debug_texture
			trace("Delete Framebuffer");
			#end
			gl.deleteFramebuffer(framebuffer);
			framebuffer = null;
			if (glDepthBuffer != null) gl.deleteRenderbuffer(glDepthBuffer);
			glDepthBuffer = null;
		}
	}
	
	private inline function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// check gl-context of all parents
			for (p in programs)
				if (p.gl != null && p.gl != newGl) throw("Error, texture can not used inside different gl-contexts");
			for (d in displays)
				if (d.gl != null && d.gl != newGl) throw("Error, texture can not used inside different gl-contexts");
				
			// clear old gl-context if there is one
			if (gl != null) clearOldGLContext();
			#if peoteview_debug_texture
			trace("Texture setNewGLContext");
			#end
			gl = newGl;
			createTexture();
			createFramebuffer();
			// all images to gpu
			for (image in images.keys()) bufferImage(image, images.get(image));
		}
	}
	
	private inline function clearOldGLContext() 
	{
		#if peoteview_debug_texture
		trace("Texture clearOldGLContext");
		#end
		//TODO
		gl.deleteTexture(glTexture);
		glTexture = null;
		deleteFramebuffer();
	}
	
	private inline function createTexture()
	{
		#if peoteview_debug_texture
		trace("Create new Texture");
		#end
		if (width > gl.getParameter(gl.MAX_TEXTURE_SIZE) || height > gl.getParameter(gl.MAX_TEXTURE_SIZE))
			throw("Error, texture size is greater then gl.MAX_TEXTURE_SIZE");
		glTexture = TexUtils.createEmptyTexture(gl, width, height, colorChannels, createMipmaps, magFilter, minFilter);			
	}

	public function setImage(image:Image, imageSlot:Int = 0) {
		#if peoteview_debug_texture
		trace("Set Image into Texture Slot" + imageSlot);
		#end
		images.set(image, {imageSlot:imageSlot}); // TODO: is already set?
		if (gl != null) {
			if (glTexture == null) createTexture();
			bufferImage(image, {imageSlot:imageSlot});
		}
	}
	
	private function bufferImage(image:Image, imgProp:ImgProp) {
		#if peoteview_debug_texture
		trace("buffer Image to Texture");
		#end
		// TODO: overwrite and fit-parameters
		imageToTexture(gl, glTexture,
		                   slotWidth * (imgProp.imageSlot % slotsX),
		                   slotHeight * Math.floor(imgProp.imageSlot / slotsX),
		                   image.width, image.height, //slotWidth, slotHeight,
		                   image, createMipmaps );	
						   
		updated = true; // to reset peoteView.glStateTexture  <-- TODO: check isTextureStateChange()
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