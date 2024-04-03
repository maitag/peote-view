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

@:allow(peote.view)
class Texture 
{
	var gl:PeoteGL = null;

	public var glTexture(default, null):GLTexture = null;	
	
	var framebuffer:GLFramebuffer = null;
	var glDepthBuffer:GLRenderbuffer = null;
	
	public var clearOnRenderInto = true;
	
	public var format(default, null):TextureFormat;
	public var smoothExpand(default, set):Bool = false; // while pixels are expanding (zoom in)
	inline function set_smoothExpand(b:Bool):Bool {
		if (gl != null) TexUtils.setMinMagFilter(gl, smoothExpand, null, null, glTexture);
		return smoothExpand = b;
	}
	public var smoothShrink(default, set):Bool = false; // while pixels are shrinking (zoom out)
	inline function set_smoothShrink(b:Bool):Bool {
		if (gl != null) TexUtils.setMinMagFilter(gl, null, smoothShrink, (mipmap) ? smoothMipmap : null, glTexture);
		return smoothShrink = b;
	}

	private var mipmapIsCreated:Bool = false;

	public var mipmap(default, null):Bool = false; // enable to generate mipmap levels
	inline function set_mipmap(b:Bool):Bool {
		if (gl != null && b && !mipmapIsCreated) {
			TexUtils.createMipmap(gl, glTexture);
			mipmapIsCreated = true;
		}
		return mipmap = b;
	}

	public var smoothMipmap(default, set):Bool = false;
	inline function set_smoothMipmap(b:Bool):Bool {
		if (gl != null) TexUtils.setMinMagFilter(gl, null, smoothShrink, (mipmap) ? smoothMipmap : null, glTexture);
		return smoothMipmap = b;
	}

	
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	
	public var maxSlots(default, null):Int = 1;
	
	public var slotsX(default, null):Int = 1;
	public var slotsY(default, null):Int = 1;
	public var slotWidth(default, null):Int;
	public var slotHeight(default, null):Int;

	public var tilesX:Int = 1;
	public var tilesY:Int = 1;
	
	public var usedSlots = new IntMap<TextureData>();
	
	var updated:Bool = false;
	
	var programs = new Array<Program>();
	var displays = new Array<Display>();
	
	// TODO: return error if not fit into maxTextureSize!
	public function new(slotWidth:Int, slotHeight:Int, ?slots:Null<Int>, ?textureConfig:TextureConfig)
	{
		if (textureConfig == null) textureConfig = {};

		this.slotWidth = slotWidth;
		this.slotHeight = slotHeight;

		this.tilesX = textureConfig.tilesX;
		this.tilesY = textureConfig.tilesY;
		
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
			if (width > textureConfig.maxTextureSize || height > textureConfig.maxTextureSize) throw('Error: max texture-size (${textureConfig.maxTextureSize}) is to small for $slots images ($slotWidth x $slotHeight)');
		}
		else {
			var p = TexUtils.optimalTextureSize(slots, slotWidth, slotHeight, textureConfig.maxTextureSize, textureConfig.powerOfTwo);
			width = p.width;
			height = p.height;
			slotsX = p.slotsX;
			slotsY = p.slotsY;
		}

		maxSlots = slotsX * slotsY;

		#if peoteview_debug_texture
		trace('${maxSlots} slots ($slotsX * $slotsY) on a ${width} x ${height} Texture');
		#end
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

	private inline function removeFromProgram(program:Program) 
	{
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
			for (slot => textureData in usedSlots) 
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

	public function readPixelsUInt8(x:Int, y:Int, w:Int, h:Int, data:UInt8Array = null):UInt8Array {
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
	
	public function readPixelsFloat32(x:Int, y:Int, w:Int, h:Int, data:Float32Array = null):Float32Array {
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
	public function setData(textureData:TextureData, slot:Int = 0) {
		if (format.isFloat != textureData.format.isFloat)
			throw('Error: Can not use ${(textureData.format.isFloat) ? "float" : "integer"} TextureData for ${(format.isFloat) ? "float" : "integer"} Texture');
		else if (format.channels != textureData.format.channels) 
			throw("Error: Number of colorchannels of TextureData and Texture don't match");

		#if peoteview_debug_texture
		trace('Set TextureData (${textureData.format}) to Texture (${format}) into Slot' + slot);
		if (format != textureData.format) trace("Warning: Textureformat of Texture and TextureData don't match");
		#end
		
		usedSlots.set(slot, textureData);

		if (gl != null) {
			// TODO: optimize here to also setData while creation if there is only 1 slot and textureData already set
			if (glTexture == null) createTexture();
			TexUtils.dataToTexture(gl, slotWidth * (slot % slotsX), slotHeight * Std.int(slot / slotsX), format, textureData, mipmap, glTexture);
			if (mipmap) mipmapIsCreated = true;
			updated = true; // to reset peoteView.glStateTexture  <-- TODO: check isTextureStateChange()
		}
	}
	
	// TODO: clear with color, save what need to clear if get gl-context later!
	
	// frees a Texture-Slot from linked TextureData
	public function clearSlot(slot:Int) {
		#if peoteview_debug_texture
		trace("Clear Texture slot");
		#end
		var textureData = usedSlots.get(slot);
		usedSlots.remove(slot);

		// TODO: test it into sample!
		if (gl != null) {			
			var emptyTextureData = new TextureData(slotWidth, slotHeight, format);
			emptyTextureData.clear(0);
			TexUtils.dataToTexture(gl, slotWidth * (slot % slotsX), slotHeight * Std.int(slot / slotsX), format, emptyTextureData, false, glTexture);
			updated = true; // to reset peoteView.glStateTexture  <-- TODO: check isTextureStateChange()
		}
	}

	public function setSmooth(smoothExpand:Bool, smoothShrink:Bool, smoothMipmap:Null<Bool> = null) {
		this.smoothExpand = smoothExpand;
		this.smoothShrink = smoothShrink;
		if (smoothMipmap != null) this.smoothMipmap = smoothMipmap;
		if (gl != null) TexUtils.setMinMagFilter(gl, smoothExpand, smoothShrink, (mipmap) ? this.smoothMipmap : null, glTexture);
	}

	public static function fromData(textureData:TextureData):Texture {
		var texture = new Texture(textureData.width, textureData.height, 1, {format:textureData.format} );
		texture.setData(textureData);
		return texture;
	}
}