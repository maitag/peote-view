package peote.view;

import haxe.Timer;
import haxe.ds.Vector;
import haxe.io.Int32Array;
import haxe.io.UInt8Array;

import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.graphics.opengl.GLRenderbuffer;

import peote.view.Mask;
import peote.view.intern.Background;
import peote.view.intern.GLTool;
import peote.view.intern.RenderList;
import peote.view.intern.RenderListItem;
import peote.view.intern.TexUtils;
import peote.view.intern.UniformBufferView;

import peote.view.PeoteGL.GLTexture;
import peote.view.PeoteGL.GLFramebuffer;

/*
    o-o    o-o  o-o-o  o-o
   o   o  o        o      o
  o-o-o  o-o  \|/   o    o-o
 o      o     <O>    o      o
o      o-o            o    o-o

*/

@:allow(peote.view)
class PeoteView 
{
	public var window(default, null):Window = null;
	public var gl(default, null):PeoteGL;
	
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var color(default, set):Color = 0x000000FF;
	inline function set_color(c:Color):Color {
		red   = c.red   / 255.0;			
		green = c.green / 255.0;			
		blue  = c.blue  / 255.0;
		alpha = c.alpha / 255.0;
		return c;
	}
	var red:Float = 0.0;
	var green:Float = 0.0;
	var blue:Float = 0.0;
	var alpha:Float = 1.0;
	
	var maxTextureImageUnits:Int;
	var glStateTexture:Vector<GLTexture>;
	public function isTextureStateChange(activeTextureUnit:Int, texture:Texture):Bool {
		if (texture.updated) {
			texture.updated = false;
			// TODO: textures can be unbind inside texture or for renderTotexture!
			glStateTexture = new Vector<GLTexture>(maxTextureImageUnits); // clear full -> todo: optimize
			glStateTexture.set(activeTextureUnit, texture.glTexture);			
			return true;
		}
		if (glStateTexture.get(activeTextureUnit) != texture.glTexture) {
			glStateTexture.set(activeTextureUnit, texture.glTexture);
			return true;
		} else return false;
	}
	
	public var xz(default, null):Float = 1.0;
	public var yz(default, null):Float = 1.0;
	
	public var zoom(default, set):Float = 1.0;
	public inline function set_zoom(z:Float):Float {
		xz = xZoom * z;
		yz = yZoom * z;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateZoom(gl, xz, yz);
		return zoom = z;
	}
	public var xZoom(default, set):Float = 1.0;
	public inline function set_xZoom(z:Float):Float {
		xz = zoom * z;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXZoom(gl, xz);
		return xZoom = z;
	}
	public var yZoom(default, set):Float = 1.0;
	public inline function set_yZoom(z:Float):Float {
		yz = zoom * z;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYZoom(gl, yz);
		return yZoom = z;
	}
	public var xOffset(default, set):Float = 0;
	public inline function set_xOffset(xo:Float):Float {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXOffset(gl, xo);//TODO:->float
		return xOffset = xo;
	}
	public var yOffset(default, set):Float = 0;
	public inline function set_yOffset(yo:Float):Float {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYOffset(gl, yo);
		return yOffset = yo;
	}
	
	var displayList:RenderList<Display>;
	var framebufferDisplayList:RenderList<Display>;
	
	var background:Background;
	
	var uniformBuffer:UniformBufferView;
	
	public var isRun(default, null):Bool = false;
	var startTime:Float = 0;
	var stopTime:Float = 0;
	var speed:Float = 1.0; // TODO
	public var time(get,set):Float;
	public inline function get_time():Float
	{
		return ((isRun) ? Timer.stamp() - startTime : stopTime)*speed;
	}
	public inline function set_time(t:Float):Float
	{
		startTime = stopTime = Timer.stamp() - t;
		return t;
	}
	public function start():Void
	{
		if (!isRun) {
			time = stopTime;
			isRun = true;
		}
	}
	public function stop():Void
	{
		if (isRun) {
			stopTime = time;
			isRun = false;
		}
	}

	public function new(window:Window, color:Color = 0x000000FF, registerEvents = true)
	{
		#if peoteview_debug_view
		trace (window.context.type + " " + window.context.version);
		#end
		
		this.window = window;
		gl = window.context;
		width = window.width;
		height = window.height;
		this.color = color;
				
		if (PeoteGL.Version.isUBO) {
            #if peoteview_debug_view
			trace("OpenGL Uniform Buffer Objects enabled.");
			trace("GL.UNIFORM_BUFFER_OFFSET_ALIGNMENT:" + gl.getParameter(gl.UNIFORM_BUFFER_OFFSET_ALIGNMENT));
			trace("GL.MAX_UNIFORM_BLOCK_SIZE:" + gl.getParameter(gl.MAX_UNIFORM_BLOCK_SIZE));
			#end
			uniformBuffer = new UniformBufferView();
			uniformBuffer.createGLBuffer(gl, width, height, xOffset, yOffset, xz, yz);			
        }
        else {
			#if peoteview_debug_view
            trace("OpenGL Uniform Buffer Objects disabled.");
			#end
        }
		#if peoteview_debug_view
		if (PeoteGL.Version.isINSTANCED) {
            trace("OpenGL InstanceDrawing enabled.");
        }
        else {
            trace("OpenGL InstanceDrawing disabled.");
        }
		#end
		maxTextureImageUnits = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS);
		glStateTexture = new Vector<GLTexture>(maxTextureImageUnits);
		#if peoteview_debug_view
		trace("GL.MAX_TEXTURE_SIZE:" + gl.getParameter(gl.MAX_TEXTURE_SIZE));
		trace("GL.MAX_TEXTURE_IMAGE_UNITS:" + gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS));
		trace("GL.MAX_COMBINED_TEXTURE_IMAGE_UNITS:" + gl.getParameter(gl.MAX_COMBINED_TEXTURE_IMAGE_UNITS));
		trace("GL.MAX_VERTEX_TEXTURE_IMAGE_UNITS:" + gl.getParameter(gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS));
		trace("GL.MAX_VERTEX_ATTRIBS:" + gl.getParameter(gl.MAX_VERTEX_ATTRIBS));
		trace("GL.MAX_VARYING_VECTORS:" + gl.getParameter(gl.MAX_VARYING_VECTORS));
		trace("GL.MAX_VERTEX_UNIFORM_VECTORS:" + gl.getParameter(gl.MAX_VERTEX_UNIFORM_VECTORS));
		trace("GL.MAX_FRAGMENT_UNIFORM_VECTORS:" + gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS));
		trace("EXTENSIONS:\n" + gl.getSupportedExtensions());
		#end
		// to use internal 32 bit float-textures for webgl enable: gl.getExtension("EXT_color_buffer_float");
		// or look here https://stackoverflow.com/questions/45571488/webgl-2-readpixels-on-framebuffers-with-float-textures
		
		
		PeoteGL.Precision.init(gl); // init precision		
		
		initGlPicking();
		
		background = new Background(gl);
		
		displayList = new RenderList<Display>(new Map<Display,RenderListItem<Display>>());
		framebufferDisplayList = new RenderList<Display>(new Map<Display,RenderListItem<Display>>());
		
		if (registerEvents) {
			window.onRender.add(render);
			window.onResize.add(resize);
		}
	}
	

 	public inline function hasDisplay(display:Display):Bool return display.isIn(this);
			
	/**
		Adds an Display instance to the RenderList.
		Can be also used to change the order (relative to another display) if it's already added.
		@param  display Display instance to add into the RenderList or to change it's order
		@param  atDisplay (optional) to add or move the display before or after another display in the Renderlist (at default it adds at start or end)
		@param  addBefore (optional) set to `true` to add the display before another display or at start of the Renderlist (at default it adds after atDisplay or at end of the list)
	**/
	public function addDisplay(display:Display, ?atDisplay:Display, addBefore:Bool=false)
	{
		display.addToPeoteView(this, atDisplay, addBefore);
	}
	
    /**
        Removes an Display instance from the RenderList.
    **/
	public function removeDisplay(display:Display):Void
	{
		display.removeFromPeoteView(this);
	}

    /**
        Swaps two Display instances inside the RenderList.
		@param  display1 first Display instance
		@param  display2 second Display instance
    **/
	public function swapDisplays(display1:Display, display2:Display):Void
	{
		display1.swapDisplay(display2);
	}

	/**
		Adds an Display instance to the hidden framebuffer RenderList (what only render to textures).
		Can be also used to change the order (relative to another display) if it's already added.
		@param  display Display instance to add into the RenderList or to change it's order
		@param  atDisplay (optional) to add or move the display before or after another display in the Renderlist (at default it adds at start or end)
		@param  addBefore (optional) set to `true` to add the display before another display or at start of the Renderlist (at default it adds after atDisplay or at end of the list)
	**/
	public function addFramebufferDisplay(display:Display, ?atDisplay:Display, addBefore:Bool=false)
	{
		display.addToPeoteViewFramebuffer(this, atDisplay, addBefore);
	}
	
    /**
        Removes an Display instance from the hidden framebuffer RenderList (what only render to textures).
    **/
	public function removeFramebufferDisplay(display:Display):Void
	{
		display.removeFromPeoteViewFramebuffer(this);
	}

	/**
		Changes the gl-context of the View and all contained Displays
		@param  newGl new opengl context
	**/
	public function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// clear old gl-context if there is one
			if (gl != null) clearOldGLContext();
			
			trace("PeoteView setNewGLContext");
			gl = newGl;
			if (PeoteGL.Version.isUBO) uniformBuffer.createGLBuffer(gl, width, height, xOffset, yOffset, xz, yz);
			
			// setNewGLContext for all displays
			for (display in framebufferDisplayList) display.setNewGLContext(newGl);
			for (display in displayList) if (! framebufferDisplayList.has(display)) display.setNewGLContext(newGl);
		}
	}

	private function clearOldGLContext() 
	{
		trace("Display clearOldGLContext");
		if (PeoteGL.Version.isUBO) uniformBuffer.deleteGLBuffer(gl);
	}

	public var onResize:Int->Int->Void;
	
	/**
		This function need to call if window-size is changed
	**/
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateResolution(gl, width, height);
		if (onResize != null) onResize(width, height);
	}

	// ----------------------------- Helpers ----------------------------------------
	
    /**
		Converts a local x-position from view-coordinates to the correspondending global screen ones.
		@param localX x-position inside of the view
    **/
	public inline function globalX(localX:Float):Float return localX * xz + xOffset;

    /**
		Converts a global x-position from screen-coordinates to the correspondending local view ones.
		@param globalX x-position at screen
    **/
	public inline function localX(globalX:Float):Float return (globalX - xOffset) / xz;

    /**
		Converts a local y-position from view-coordinates to the correspondending global screen ones.
		@param localY y-position inside of the view
    **/
	public inline function globalY(localY:Float):Float return localY * yz + yOffset;

    /**
		Converts a global y-position from screen-coordinates to the correspondending local view ones.
		@param globalY y-position at screen
    **/
	public inline function localY(globalY:Float):Float return (globalY - yOffset) / yz;
	

	// ------------------------------------------------------------------------------
	// ----------------------------- GL-Picking -------------------------------------
	// ------------------------------------------------------------------------------
	var pickFB:GLFramebuffer;
	var pickTexture:GLTexture;
	var pickDepthBuffer:GLRenderbuffer;
	var pickInt32:Int32Array;
	var pickUInt8:UInt8Array;
	
	private inline function initGlPicking()
	{
		if (PeoteGL.Version.isINSTANCED) {
			pickInt32 = new Int32Array(4);
			pickTexture = TexUtils.createPickingTexture(gl, true); // RGBA32I
		} else {
			pickUInt8  = new UInt8Array(4);
			pickTexture = TexUtils.createPickingTexture(gl); // RGBA
		}
		pickDepthBuffer = gl.createRenderbuffer();
		pickFB = GLTool.createFramebuffer(gl, pickTexture, pickDepthBuffer, 1, 1); 
	}
	
	/**
		Gets the Element-Index at a defined position on screen
		@param  posX x position in pixel
		@param  posY y position in pixel
		@param  display Display that contains the Program
		@param  program Program that contains the Buffer with Elements
	**/
	public function getElementAt(posX:Float, posY:Float, display:Display, program:Program):Int
	{
		gl.bindFramebuffer(gl.FRAMEBUFFER, pickFB);
		var element = pick(posX, posY, display, program, -1);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		return element;
	}

	/**
		Gets an array of Element-Indices at a defined position on screen.
		@param  posX x position in pixel
		@param  posY y position in pixel
		@param  display Display that contains the Program
		@param  program Program that contains the Buffer with Elements
	**/
	public function getAllElementsAt(posX:Float, posY:Float, display:Display, program:Program):Array<Int>
	{
		var elements = new Array<Int>();
		var toElement = -2; // disable z-buffer
		gl.bindFramebuffer(gl.FRAMEBUFFER, pickFB);
		do {
			toElement = pick(posX, posY, display, program, toElement);
			if (toElement >= 0) elements.push(toElement);
		} while (toElement > 0);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		return elements;
	}
	
	private function pick(posX:Float, posY:Float, display:Display, program:Program, toElement:Int):Int
	{
		if (! program.hasPicking()) throw("Error: opengl-Picking - type of buffer/element is not pickable !");
		
		//initGLViewport
		gl.viewport (0, 0, 1, 1);
		gl.scissor(0, 0, 1, 1);
		gl.enable(gl.SCISSOR_TEST);	
		
		// clear framebuffer
		if (PeoteGL.Version.isINSTANCED) {
			gl.clearBufferiv(gl.COLOR, 0, [0, 0, 0, 0]); // only the first value is the UInt32 value that clears the texture
			gl.clear(gl.DEPTH_BUFFER_BIT);
			gl.depthFunc(gl.LEQUAL);
		}
		else {
			gl.clearColor(0.0, 0.0, 0.0, 0.0);
			gl.clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT );
			gl.depthFunc(gl.LEQUAL);
		}
				
		var xOff:Float = xOffset - (xOffset + posX - xOffset) / xz;
		var yOff:Float = yOffset - (yOffset + posY - yOffset) / xz;

		display.pick(xOff, yOff, this, program, toElement); // render with picking shader
		
		// read picked pixel (element-number)
		if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) == gl.FRAMEBUFFER_COMPLETE) { // Optimizing: is check need here ?
			if (peote.view.PeoteGL.Version.isINSTANCED) {
				gl.readPixels_Int32(0, 0, 1, 1, gl.RGBA_INTEGER, gl.INT, pickInt32);
				return pickInt32[0] - 1;
			}
			else {
				gl.readPixels(0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, pickUInt8);
				return pickUInt8[3] << 24 | pickUInt8[2] << 16 | pickUInt8[1] << 8 | pickUInt8[0] - 1;
			}
		}
		else throw("Error: opengl-Picking - Framebuffer not complete!");
		return -2;
	}
	
	
	// ------------------------------------------------------------------------------
	// -------------------------- Render to Texture ---------------------------------
	// ------------------------------------------------------------------------------
    /**
		Bind a Texture to a Display to use as a framebuffer for renderToTexture()
		@param display Display
		@param texture Texture instance to render into
		@param textureSlot number of texture-slot to render into (can be changed by set the 'framebufferTextureSlot' property)
    **/
	public function setFramebuffer(display:Display, texture:Texture, ?textureSlot:Null<Int>) {
		display.setFramebuffer(texture, textureSlot, this);
	}
	
    /**
		Renders the content of a Display into a texture.
		@param display Display instance
		@param textureSlot number of texture-slot to render into (can be changed by set the 'framebufferTextureSlot' display property)
    **/
	public function renderToTexture(display:Display, ?textureSlot:Null<Int>)
	{
		if (display.fbTexture != null) _renderToTexture(display, (textureSlot != null) ? textureSlot : display.framebufferTextureSlot);
	}
	
	private inline function _renderToTexture(display:Display, ?textureSlot:Null<Int>)
	{
		if (textureSlot == null) textureSlot = display.framebufferTextureSlot;
		
		gl.bindFramebuffer(gl.FRAMEBUFFER, display.fbTexture.framebuffer);
		//gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, display.fbTexture.framebuffer);
		
		gl.viewport(
			display.fbTexture.slotWidth * (textureSlot % display.fbTexture.slotsX),
			display.fbTexture.slotHeight * Math.floor(textureSlot / display.fbTexture.slotsX),
			display.fbTexture.slotWidth, display.fbTexture.slotHeight
		);
		gl.scissor(
			display.fbTexture.slotWidth * (textureSlot % display.fbTexture.slotsX),
			display.fbTexture.slotHeight * Math.floor(textureSlot / display.fbTexture.slotsX),
			display.fbTexture.slotWidth, display.fbTexture.slotHeight
		);
		
		gl.enable(gl.SCISSOR_TEST);	
		
		gl.clearColor(0.0, 0.0, 0.0, 0.0);
		if (display.fbTexture.clearOnRenderInto) {
			gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
		}
		else gl.clear(gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
		//else gl.clear(gl.STENCIL_BUFFER_BIT); // TODO: also let draw in depend of z-buffer
		
		// Optimize: only clear depth and stencil bits if is used somewhere (hasDepth und hasStencil)
		// TODO: let a program clear at start
		//gl.clearStencil(0);
		//gl.clearDepthf(1.0);
		
		// Optimize: only set if is in use somewhere (stencilON state!)
		gl.stencilMask(0xFF);

		gl.depthFunc(gl.LEQUAL);
		
		display.renderFramebuffer(this); // <-- render display
		
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		//gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null);
		
		// re-generate mipmaps after rendering into:		
		if (display.fbTexture.mipmap) { // re-create for full texture ?
			gl.bindTexture(gl.TEXTURE_2D, display.fbTexture.glTexture);
			//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.NICEST); // OPTIMIZING
			//gl.hint(gl.GENERATE_MIPMAP_HINT, gl.FASTEST);
			gl.generateMipmap(gl.TEXTURE_2D);
			gl.bindTexture(gl.TEXTURE_2D, null); // <-- TODO: check isTextureStateChange()
			display.fbTexture.updated = true;
		}
	}
		
	// ------------------------------------------------------------------------------
	// ---------- Color, Depth, Stencil Mask and Blendmode states -------------------
	// ------------------------------------------------------------------------------
	var colorState:Bool = true;
	private inline function setColor(enabled:Bool):Void
	{	
		if (enabled != colorState) {
			colorState = enabled;
			gl.colorMask(enabled, enabled, enabled, enabled);
		}
	}

	var depthState:Bool = false;
	private inline function setGLDepth(enabled:Bool):Void
	{	
		if (enabled && !depthState) {
			depthState = true;
			gl.enable(gl.DEPTH_TEST);
		} else if (!enabled && depthState) {
			depthState = false;
			gl.disable(gl.DEPTH_TEST);
		}
	}
	
	var maskState:Mask = Mask.OFF;	
	private inline function setMask(mask:Mask, clearMask:Bool):Void
	{
		if (mask != maskState) 
		{
			if (mask == Mask.OFF) {
				gl.disable(gl.STENCIL_TEST);
				maskState = mask;
			}
			else if (mask == Mask.DRAW)
			{
				if (clearMask) gl.clear(gl.STENCIL_BUFFER_BIT);
				if (maskState == Mask.OFF) gl.enable(gl.STENCIL_TEST);
				
				gl.stencilFunc(gl.ALWAYS, 1, 0xFF);
				gl.stencilOp(gl.REPLACE, gl.REPLACE, gl.REPLACE);
				maskState = mask;
				
			}
			else
			{
				if (maskState == Mask.OFF) gl.enable(gl.STENCIL_TEST);
				gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
				gl.stencilFunc(gl.EQUAL, 1, 0xFF);
			}
			maskState = mask;
		}
	}
	
	var blendState:Bool = false;
	var blendStateSeparate:Bool = false;
	var blendStateSrc:Int = 0;
	var blendStateDst:Int = 0;
	var blendStateSrcAlpha:Int = 0;
	var blendStateDstAlpha:Int = 0;
	
	var blendStateFuncSeparate:Bool = false;
	var blendStateFunc:Int = 0;
	var blendStateFuncAlpha:Int = 0;
	
	var blendStateColor:Int = 0;
	
	private inline function setGLBlend(blendEnabled:Bool, blendSeparate:Bool = false,
		blendSrc:Int = 0, blendDst:Int = 0, blendSrcAlpha:Int = 0, blendDstAlpha:Int = 0,
		funcSeparate:Bool = false, func:Int = 0, funcAlpha:Int = 0,
		color:Color = 0, useColor:Bool = false, useColorSeparate:Bool = false, r:Float = 0.0, g:Float = 0.0, b:Float = 0.0, a:Float = 0.0
	):Void
	{	
		if (blendEnabled) {
			if (!blendState) { blendState = true; gl.enable(gl.BLEND); }
			
			if (blendSeparate) {
				if ( !blendStateSeparate || (blendStateSrc != blendSrc) || (blendStateDst != blendDst) || (blendStateSrcAlpha != blendSrcAlpha) || (blendStateDstAlpha != blendDstAlpha)  ) {
					gl.blendFuncSeparate(blendStateSrc = blendSrc, blendStateDst = blendDst, blendStateSrcAlpha = blendSrcAlpha, blendStateDstAlpha = blendDstAlpha);
				}
				if (useColorSeparate && (blendStateColor != color)) {
					blendStateColor = color;
					gl.blendColor(r, g, b, a);
				}
			}
			else {
				if ( blendStateSeparate || (blendStateSrc != blendSrc) || (blendStateDst != blendDst) ) {
					gl.blendFunc(blendStateSrc = blendSrc, blendStateDst = blendDst);
				}
				if (useColor && (blendStateColor != color)) {
					blendStateColor = color;
					gl.blendColor(r, g, b, a);
				}
			}
			
			if (funcSeparate) {
				if ( !blendStateFuncSeparate || (blendStateFunc != func) || (blendStateFuncAlpha != funcAlpha) ) {
					gl.blendEquationSeparate(blendStateFunc = func, blendStateFuncAlpha = funcAlpha);
				}
			}
			else if ( blendStateFuncSeparate || (blendStateFunc != func) ) {
					gl.blendEquation(blendStateFunc = func);
			}
			
		}
		else if (blendState) {
			blendState = false;
			gl.disable(gl.BLEND);
		}
	}
	
	// ------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function initGLViewport(w:Int, h:Int):Void
	{
		gl.viewport (0, 0, w, h);
		
		gl.scissor(0, 0, w, h);
		gl.enable(gl.SCISSOR_TEST);	
		
		gl.clearColor(red, green, blue, alpha);
		
		// Optimize: only set depth and stencil bits here if used somewhere (hasDepth state und hasStencil)
		// CHECK: this may not need on HTML5 (look at preserveDrawingBuffer -> https://stackoverflow.com/questions/27746091/preservedrawingbuffer-false-is-it-worth-the-effort)
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
		
		// Optimize: only clear depth and stencil bits if is used somewhere (hasDepth und hasStencil)
		// TODO: let a program clear at start
		//gl.clearStencil(0);
		//gl.clearDepthf(1.0);
		
		// Optimize: only set if is in use somewhere (stencilON state!)
		gl.stencilMask(0xFF);
				
		gl.depthFunc(gl.LEQUAL);
	}
	
	var displayListItem:RenderListItem<Display>;

	private inline function renderFramebuffer(context:RenderContext = null):Void
	{	
		displayListItem = framebufferDisplayList.first;
		while (displayListItem != null)
		{
			if (displayListItem.value._renderFramebufferEnabled) 
			{
				if (displayListItem.value.renderFramebufferFrame == displayListItem.value.renderFramebufferSkipFrames) {
					_renderToTexture(displayListItem.value);
					displayListItem.value.renderFramebufferFrame = 0;
				} else displayListItem.value.renderFramebufferFrame++;
			}
			
			displayListItem = displayListItem.next;
		}
	}

	public function render(context:RenderContext = null):Void
	{	
		//trace("===peoteView.render===");
		renderFramebuffer(context);
		initGLViewport(width, height);		
		renderPart();
	}

	public inline function renderPart():Void
	{	
		//trace("===peoteView.renderPart===");

		displayListItem = displayList.first;
		while (displayListItem != null)
		{
			displayListItem.value.render(this);			
			displayListItem = displayListItem.next;
		}
		
	}
	


}