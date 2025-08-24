package peote.view;

import haxe.io.Bytes;
import haxe.io.UInt8Array;
import haxe.io.Float32Array;
import haxe.ds.IntMap;

import peote.view.TextureData;
import peote.view.PeoteGL.GLTexture;
import peote.view.PeoteGL.GLFramebuffer;
import peote.view.PeoteGL.GLRenderbuffer;
import peote.view.intern.GLTool;
import peote.view.intern.TexUtils;
import peote.view.intern.IntUtil;

/**
	A `Texture` can be used inside of `Program`s to render image data.  
	It can store multiple `TextureData` in slots that can be divided into tiles for texture atlases.  
	The precision (int/float) and amount of colorchannels can be defined by `TextureFormat`. Mipmapping and filtering is supported.
**/
@:allow(peote.view)
class Texture
{
	var gl:PeoteGL;
	var framebuffer:GLFramebuffer;
	var glDepthBuffer:GLRenderbuffer;
	var programs = new Array<Program>();
	var displays = new Array<Display>();
	var mipmapIsCreated:Bool = false;
	var updated:Bool = false;
		
	/**
		The used `TextureFormat`.
	**/
	public var format(default, null):TextureFormat;

	/**
		The OpenGL representation of the texture.
	**/
	public var glTexture(default, null):GLTexture;

	/**
		Maps a slot number to the used `TextureData`.
	**/
	public var textureDataSlots(default, null):IntMap<TextureData>;
		
	/**
		The total horizontal texturesize in pixels.
	**/
	public var width(default, null):Int;

	/**
		The total vertical texturesize in pixels.
	**/
	public var height(default, null):Int;
	
	/**
		The total number of slots in which the texture can store texture data.
	**/
	public var slots(get, never):Int;
	inline function get_slots():Int return slotsX*slotsY;

	/**
		The horizontal number of slots into which the texture is divided.
	**/
	public var slotsX(default, null):Int;

	/**
		The vertical number of slots into which the texture is divided.
	**/
	public var slotsY(default, null):Int;

	/**
		Horizontal slot size in pixels.
	**/
	public var slotWidth(default, null):Int;

	/**
		Vertical slot size in pixels.
	**/
	public var slotHeight(default, null):Int;

	/**
		Horizontal tiling, the program needs "update()" if changing this while in use
	**/
	public var tilesX:Int;

	/**
		Vertical tiling, the program needs "update()" if changing this while in use
	**/
	public var tilesY:Int;
	
	/**
		If the texture have to generate mipmaps for filtering.
	**/
	public var mipmap(default, set):Bool = false;
	inline function set_mipmap(b:Bool):Bool {
		if (gl != null && b && !mipmapIsCreated) {
			TexUtils.createMipmap(gl, glTexture);
			mipmapIsCreated = true;
		}
		return mipmap = b;
	}

	/**
		Use smooth interpolation between the mipmap-levels for texture filtering.
	**/
	public var smoothMipmap(default, set):Bool = false;
	inline function set_smoothMipmap(b:Bool):Bool {
		if (gl != null) TexUtils.setMinMagFilter(gl, null, smoothShrink, (mipmap) ? smoothMipmap : null, glTexture);
		return smoothMipmap = b;
	}

	/**
		Use smooth filtering if the texture is displayed at a enlarged size.
	**/
	public var smoothExpand(default, set):Bool = false;
	inline function set_smoothExpand(b:Bool):Bool {
		if (gl != null) TexUtils.setMinMagFilter(gl, smoothExpand, null, null, glTexture);
		return smoothExpand = b;
	}

	/**
		Use smooth filtering if the texture is displayed at a reduced size.
	**/
	public var smoothShrink(default, set):Bool = false;
	inline function set_smoothShrink(b:Bool):Bool {
		if (gl != null) TexUtils.setMinMagFilter(gl, null, smoothShrink, (mipmap) ? smoothMipmap : null, glTexture);
		return smoothShrink = b;
	}

	/**
		The texture will be cleared before a `Display` is rendering into it.
	**/
	public var clearOnRenderInto = true;
	

	// TODO: return error if not fit into maxTextureSize!

	/**
		Creates a new `Texture` instance. Slot-tiling and texturesize is automatic calculated if you give the `slots` parameter a number.		
		@param slotWidth width of each slot in pixels
		@param slotHeight height of each slot in pixels
		@param slots number of slots, leave it at `null` to use `slotX` and `slotY` tiling by textureConfig
		@param textureConfig options by `TextureConfig`
	**/
	public function new(slotWidth:Int, slotHeight:Int, ?slots:Null<Int>, ?textureConfig:TextureConfig)
	{
		textureDataSlots = new IntMap<TextureData>();

		if (textureConfig == null) textureConfig = {};

		this.slotWidth = slotWidth;
		this.slotHeight = slotHeight;

		tilesX = textureConfig.tilesX;
		tilesY = textureConfig.tilesY;
		
		format = textureConfig.format;

		smoothExpand = textureConfig.smoothExpand;
		smoothShrink = textureConfig.smoothShrink;
		mipmap = textureConfig.mipmap;
		smoothMipmap = textureConfig.smoothMipmap;
		
		if (slots == null) {
			slotsX = textureConfig.slotsX;
			slotsY = textureConfig.slotsY;
			width = slotsX * slotWidth;
			height = slotsY * slotHeight;
			if (textureConfig.powerOfTwo) {
				width = IntUtil.nextPowerOfTwo(width);
				height = IntUtil.nextPowerOfTwo(height);
			}
			if (width > textureConfig.maxTextureSize || height > textureConfig.maxTextureSize) throw('Error: max texture-size (${textureConfig.maxTextureSize}) is to small for ${this.slots} images ($slotWidth x $slotHeight)');
		}
		else {
			var p = TexUtils.optimalTextureSize(slots, slotWidth, slotHeight, textureConfig.maxTextureSize, textureConfig.powerOfTwo);
			width = p.width;
			height = p.height;
			slotsX = p.slotsX;
			slotsY = p.slotsY;
		}

		#if peoteview_debug_texture
		trace('${this.slots} slots ($slotsX * $slotsY) on a ${width} x ${height} Texture');
		#end
	}
	
	/**
		Returns `true` if a `Program` instance is using this texture.
		@param program Program instance
	**/
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
	
	private inline function removeFromProgram(program:Program) 
	{
		#if peoteview_debug_texture
		trace("Texture removed from Program");
		#end
		if (!programs.remove(program)) throw("Error, this texture is not used by program anymore");
	}
	
	/**
		Returns `true` if a `Display` instance is using this texture to render into.
		@param display Display instance
	**/
	public inline function usedByDisplay(display:Display):Bool return (displays.indexOf(display) >= 0);

	private inline function addToDisplay(display:Display) {
		#if peoteview_debug_texture
		trace("Add Display to Texture");
		#end
		if ( usedByDisplay(display) ) throw("Error, texture is already used by display");
		setNewGLContext(display.gl);
		displays.push(display);
		if (gl != null) createFramebuffer();
	}
	
	private inline function removeFromDisplay(display:Display) {
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

			// TODO: optimize to not check every time!
			// enables the extension (needs ONLY for ES 3)
			if (PeoteGL.Version.isES3 && format.isFloat) {
				if (gl.getExtension("EXT_color_buffer_float") != null) {}
				else if (gl.getExtension("OES_texture_float") != null) {}
			}

			glDepthBuffer = gl.createRenderbuffer();
			framebuffer = GLTool.createFramebuffer(gl, glTexture, glDepthBuffer, width, height);
			updated = true;
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
			//updated = true;
		}
	}
	
	private inline function setNewGLContext(newGl:PeoteGL) {
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

			// TODO: optimize here to also setData while creation if there is only 1 slot and textureData already set
			createTexture();
			createFramebuffer();
			// all slot data to gpu
			gl.bindTexture(gl.TEXTURE_2D, glTexture);
			for (slot => textureData in textureDataSlots) 
				TexUtils.dataToTexture(gl, slotWidth * (slot % slotsX), slotHeight * Std.int(slot / slotsX), format, textureData, false);
			if (mipmap) {
				TexUtils.createMipmap(gl);
				mipmapIsCreated = true;
			}
			gl.bindTexture(gl.TEXTURE_2D, null);
			updated = true; // to reset peoteView.glStateTexture  <-- TODO: check isTextureStateChange()
		}
	}
	
	private inline function clearOldGLContext() {
		#if peoteview_debug_texture
		trace("Texture clearOldGLContext");
		#end
		//TODO
		gl.deleteTexture(glTexture);
		glTexture = null;
		deleteFramebuffer();
	}
	
	private inline function createTexture()	{
		#if peoteview_debug_texture
		trace("Create new Texture");
		#end
		if (width > gl.getParameter(gl.MAX_TEXTURE_SIZE) || height > gl.getParameter(gl.MAX_TEXTURE_SIZE))
			throw("Error, texture size is greater then gl.MAX_TEXTURE_SIZE");
		glTexture = TexUtils.createEmptyTexture(gl, width, height, format, smoothExpand, smoothShrink, mipmap, smoothMipmap);
	}

	/**
		Reads the data of a rectangular area from the texture inside an `UInt8Array`. The `TextureFormat` have to be of type integer.
		@param x left position of the area
		@param y top position of the area
		@param w area width
		@param h area height
		@param data an UInt8Array to store the data, if it is `null` a new one will be created
	**/
	public function readPixelsUInt8(x:Int, y:Int, w:Int, h:Int, ?data:UInt8Array):UInt8Array {
		if (programs == null) throw("Error, texture is disposed.");
		if (gl == null) throw("Error, texture have no data yet.");
		if (format.isFloat) throw ('Error, for float textureformat you have to use "readPixelsFloat32()".');
		if (data == null) data = new UInt8Array(w * h * 4);
		// read pixels
		gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
		if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) == gl.FRAMEBUFFER_COMPLETE) {
			gl.readPixels(x, y, w, h, format.formatInteger(gl), gl.UNSIGNED_BYTE, data);
		}
		else throw("Error: opengl-Picking - Framebuffer not complete!");
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		return data;
	}
	
	/**
		Reads the data of a rectangular area from the texture inside a `Float32Array`. The `TextureFormat` have to be of type float.
		@param x left position of the area
		@param y top position of the area
		@param w area width
		@param h area height
		@param data a Float32Array to store the data, if it is `null` a new one will be created
	**/
	public function readPixelsFloat32(x:Int, y:Int, w:Int, h:Int, ?data:Float32Array):Float32Array {
		if (programs == null) throw("Error, texture is disposed.");
		if (gl == null) throw("Error, texture have no data yet.");
		if (!format.isFloat) throw ('Error, for integer textureformat you have to use "readPixelsUInt8()".');
		if (data == null) data = new Float32Array(w * h * 4);
		// read pixels
		gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
		if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) == gl.FRAMEBUFFER_COMPLETE) {
			gl.readPixels_Float32(x, y, w, h, format.formatFloat(gl), gl.FLOAT, data);
		}
		else throw("Error: opengl-Picking - Framebuffer not complete!");
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		return data;
	}
	
/*	public function writePixelFloat32(x:Int, y:Int, r:Float, g:Float, b:Float, a:Float) {
	}
	
	public function writePixelsFloat32(x:Int, y:Int, w:Int, h:Int, data:Float32Array = null) {		
	}
*/

	/**
		Specifies a `TextureData` instance to use inside a texture slot.
		@param textureData TextureData instance
		@param slot slot number in wich the texturedata is to be used
	**/
	public function setData(textureData:TextureData, slot:Int = 0) {
		if (programs == null) throw("Error, texture is disposed.");
		if (format.isFloat != textureData.format.isFloat)
			throw('Error: Can not use ${(textureData.format.isFloat) ? "float" : "integer"} TextureData for ${(format.isFloat) ? "float" : "integer"} Texture');
		else if (format.channels != textureData.format.channels) 
			throw("Error: Number of colorchannels of TextureData and Texture don't match");

		#if peoteview_debug_texture
		trace('Set TextureData (${textureData.format}) to Texture (${format}) into Slot' + slot);
		if (format != textureData.format) trace("Warning: Textureformat of Texture and TextureData don't match");
		#end
		
		textureDataSlots.set(slot, textureData);

		if (gl != null) {
			// TODO: optimize here to also setData while creation if there is only 1 slot and textureData already set
			if (glTexture == null) createTexture();
			TexUtils.dataToTexture(gl, slotWidth * (slot % slotsX), slotHeight * Std.int(slot / slotsX), format, textureData, mipmap, glTexture);
			if (mipmap) mipmapIsCreated = true;
			updated = true; // to reset peoteView.glStateTexture  <-- TODO: check isTextureStateChange()
		}
	}
	
	// TODO: clear with color, save what need to clear if get gl-context later!
	
	/**
		Frees a texture slot from the linked `TextureData`.
		@param slot slot number in wich the texturedata is used
	**/
	public function clearSlot(slot:Int) {
		if (programs == null) throw("Error, texture is disposed.");
		#if peoteview_debug_texture
		trace("Clear Texture slot");
		#end
		var textureData = textureDataSlots.get(slot);
		textureDataSlots.remove(slot);

		// TODO: test it into sample!
		if (gl != null) {			
			var emptyTextureData = new TextureData(slotWidth, slotHeight, format);
			emptyTextureData.clear(0);
			TexUtils.dataToTexture(gl, slotWidth * (slot % slotsX), slotHeight * Std.int(slot / slotsX), format, emptyTextureData, false, glTexture);
			updated = true; // to reset peoteView.glStateTexture  <-- TODO: check isTextureStateChange()
		}
	}

	/**
		Changes the texture filtering at runtime.
		@param smoothExpand to enable smooth filtering if the texture is displayed at a enlarged size
		@param smoothShrink to enable smooth filtering if the texture is displayed at a reduced size
		@param smoothMipmap to enable smooth interpolation between mipmap-levels (if the texture have mipmaps)
	**/
	public function setSmooth(smoothExpand:Bool, smoothShrink:Bool, smoothMipmap:Null<Bool> = null) {
		this.smoothExpand = smoothExpand;
		this.smoothShrink = smoothShrink;
		if (smoothMipmap != null) this.smoothMipmap = smoothMipmap;
		if (gl != null) TexUtils.setMinMagFilter(gl, smoothExpand, smoothShrink, (mipmap) ? this.smoothMipmap : null, glTexture);
	}
	
	/**
		Removes the texture from all programs/display-framebuffers and frees texture-ram by OpenGL. It can not be used again.
	**/
	public function dispose() {
		if (programs == null) throw("Error, texture is already disposed.");
		#if peoteview_debug_texture
		trace("Texture is disposed");
		#end
		// remove from all Programs
		for (p in programs) p.removeTexture(this);
		// remove from all Displays
		for (d in displays) d.removeFramebuffer();
		gl.deleteTexture(glTexture);
		glTexture = null;
		programs = null;
		displays = null;
		gl = null;
	}
	
	/**
		Creates a new texture with one slot directly from a `TextureData` instance.
		@param textureData TextureData instance
	**/
	public static function fromData(textureData:TextureData):Texture {
		var texture = new Texture(textureData.width, textureData.height, 1, {format:textureData.format} );
		texture.setData(textureData);
		return texture;
	}
}