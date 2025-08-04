package peote.view;

import peote.view.PeoteView;
import peote.view.intern.RenderList;
import peote.view.intern.RenderListItem;
import peote.view.intern.UniformBufferView;
import peote.view.intern.UniformBufferDisplay;

/*
    o-o    o-o  o-o-o  o-o
   o   o  o        o      o
  o-o-o  o-o  \|/   o    o-o
 o      o     <O>    o      o
o      o-o    /|\     o    o-o

*/

/**
	A Display represents an rectangular area inside the `PeoteView` what contains a `Program` list for rendering.  
	All the inner content can be shifted and zoomed.
**/
@:allow(peote.view)
class Display 
{
	/**
		The `PeoteView` instance in which the display is contained.
	**/
	public var peoteView(default, null):PeoteView;

	var gl:PeoteGL = null;

	var programList:RenderList<Program>;
		
	var uniformBuffer:UniformBufferDisplay;
	var uniformBufferFB:UniformBufferDisplay;
	var uniformBufferViewFB:UniformBufferView;
	
	/**
		Horizontal position in pixels (distance to left edge of the view).
	**/
	public var x(default, set):Int;
	inline function set_x(_x:Int):Int {
		if (PeoteGL.Version.isUBO && gl != null) uniformBuffer.updateXOffset(gl, _x + xOffset);
		return x = _x;
	}

	/**
		Vertical position in pixels (distance to upper edge of the view).
	**/
	public var y(default, set):Int;
	inline function set_y(_y:Int):Int {
		if (PeoteGL.Version.isUBO && gl != null) uniformBuffer.updateYOffset(gl, _y + yOffset);
		return y = _y;
	}

	/**
		Horizontal size in pixels.
	**/
	public var width:Int;

	/**
		Vertical size in pixels.
	**/
	public var height:Int;
	
	/**
		Background color.
	**/
	public var color(default, set):Color = 0x00000000;
	inline function set_color(c:Color):Color {
		red   = c.red   / 255.0;
		green = c.green / 255.0;
		blue  = c.blue  / 255.0;
		alpha = c.alpha / 255.0;
		backgroundEnabled = (alpha > 0.0) ? true : false;
		backgroundAlpha   = (alpha < 1.0) ? true : false;
		return c;
	}
	var red:Float = 0.0;
	var green:Float = 0.0;
	var blue:Float = 0.0;
	var alpha:Float = 1.0;
		
	/**
		Background use transparency.
	**/
	public var backgroundAlpha:Bool = false;

	/**
		Background use depth value.
	**/
	public var backgroundDepth:Bool = false;

	/**
		To turn the background rendering on/off.
	**/
	public var backgroundEnabled:Bool = false;
	
	/**
		To shift the render content horizontal.
	**/
	public var xOffset(default, set):Float = 0;
	inline function set_xOffset(xo:Float):Float {
		if (PeoteGL.Version.isUBO && gl != null) {
			uniformBuffer.updateXOffset(gl, x + xo);
			uniformBufferFB.updateXOffset(gl, xo);
		}
		return xOffset = xo;
	}

	/**
		To shift the render content vertical.
	**/
	public var yOffset(default, set):Float = 0;
	inline function set_yOffset(yo:Float):Float {
		if (PeoteGL.Version.isUBO && gl != null) {
			uniformBuffer.updateYOffset(gl, y + yo);
			uniformBufferFB.updateYOffset(gl, yo - height);
		}
		return yOffset = yo;
	}

	/**
		Total horizontal zoom factor, calculated by `zoom * xZoom`.
	**/
	public var xz(default, null):Float = 1.0;

	/**
		Total vertical zoom factor, calculated by `zoom * yZoom`.
	**/
	public var yz(default, null):Float = 1.0;
	
	/**
		To zoom the render content (value `> 1.0` to expand and `< 1.0` to shrink).
	**/
	public var zoom(default, set):Float = 1.0;
	inline function set_zoom(z:Float):Float {
		xz = xZoom * z;
		yz = yZoom * z;
		if (PeoteGL.Version.isUBO && gl != null) {
			uniformBuffer.updateZoom(gl, xz, yz);
			uniformBufferFB.updateZoom(gl, xz, yz);
		}
		return zoom = z;
	}

	/**
		Multiplicator for horizontal zoom.
	**/
	public var xZoom(default, set):Float = 1.0;
	inline function set_xZoom(z:Float):Float {
		xz = zoom * z;
		if (PeoteGL.Version.isUBO && gl != null) {
			uniformBuffer.updateXZoom(gl, xz);
			uniformBufferFB.updateXZoom(gl, xz);
		}
		return xZoom = z;
	}

	/**
		Multiplicator for vertical zoom.
	**/
	public var yZoom(default, set):Float = 1.0;
	inline function set_yZoom(z:Float):Float {
		yz = zoom * z;
		if (PeoteGL.Version.isUBO && gl != null) {
			uniformBuffer.updateYZoom(gl, yz);
			uniformBufferFB.updateYZoom(gl, yz);
		}
		return yZoom = z;
	}
	
	/**
		Shows or hides the display during rendering.
	**/
	public var isVisible:Bool = true;

	/**
		Shows the display during rendering.
	**/
	public function show() isVisible = true;	

	/**
		Hides the display during rendering.
	**/
	public function hide() isVisible = false;

	/**
		Creates a new `Display` instance.
		@param x x-position of the upper left corner
		@param y y-position of the upper left corner
		@param width horizontal size of the display
		@param height vertical size of the display
		@param color background color (by default the alpha value is fully transparent and so also no background is rendered)
	**/
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) 
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		set_color(color);
		
		programList = new RenderList<Program>(new Map<Program,RenderListItem<Program>>());
		
		if (PeoteGL.Version.isUBO) {
			uniformBuffer = new UniformBufferDisplay();
			uniformBufferFB = new UniformBufferDisplay();
			uniformBufferViewFB = new UniformBufferView();
		}
	}

	/**
		Returns true is this display is inside the RenderList of a `PeoteView` instance.
		@param peoteView PeoteView instance
	**/
	public inline function isIn(peoteView:PeoteView):Bool return (this.peoteView == peoteView);			

	/**
		Adds this display to the RenderList of a `PeoteView` instance.
		Can be also used to change the order (relative to another display) if it is already added.
		@param peoteView PeoteView instance
		@param atDisplay (optional) to add or move before or after another display in the RenderList (by default at start or at end)
		@param addBefore (optional) if 'true' it's added before another display or at start of the Renderlist (by default it's added after atDisplay or at end)
	**/
	public function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		if ( ! isIn(peoteView) ) {
			#if peoteview_debug_display
			trace("Add Display to PeoteView");
			#end
			this.peoteView = peoteView;
			setNewGLContext(peoteView.gl);
		}
		#if peoteview_debug_display
		else trace("Change order of Display");
		#end
		peoteView.displayList.add(this, atDisplay, addBefore);
	}

	/**
		Removes this display from the RenderList of a `PeoteView` instance.
		@param peoteView PeoteView instance
	**/
	public function removeFromPeoteView(peoteView:PeoteView)
	{
		#if peoteview_debug_display
		trace("Removed Display from PeoteView");
		#end
		if ( !isIn(peoteView) ) throw("Error, display is not inside peoteView");
		if ( !peoteView.framebufferDisplayList.has(this) ) this.peoteView = null;
		peoteView.displayList.remove(this);
	}

	/**
		Adds this display to the hidden framebuffer RenderList (what only render to textures) of a `PeoteView` instance.
		Can be also used to change the order (relative to another display) if it is already added.
		@param peoteView PeoteView instance
		@param atDisplay (optional) to add or move before or after another display in the framebuffer RenderList (by default at start or at end)
		@param addBefore (optional) if 'true' it's added before another display or at start of the framebuffer Renderlist (by default it's added after atDisplay or at end)
	**/
	public function addToPeoteViewFramebuffer(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		if ( ! isIn(peoteView) ) {
			#if peoteview_debug_display
			trace("Add Display to PeoteViews Framebuffer list");
			#end
			this.peoteView = peoteView;
			setNewGLContext(peoteView.gl);
		}
		#if peoteview_debug_display
		else trace("Change order of Display");
		#end
		peoteView.framebufferDisplayList.add(this, atDisplay, addBefore);
	}

	/**
		Removes this display from the hidden framebuffer RenderList (what only render to textures) of a peoteView.
		@param peoteView PeoteView instance
	**/
	public function removeFromPeoteViewFramebuffer(peoteView:PeoteView)
	{
		#if peoteview_debug_display
		trace("Removed Display from PeoteView");
		#end
		if ( !isIn(peoteView) ) throw("Error, display is not inside peoteView");
		if ( !peoteView.displayList.has(this) ) this.peoteView = null;
		peoteView.framebufferDisplayList.remove(this);
	}

	/**
		Swaps the order of this Display instances with another one inside the RenderList.
		@param  display Display instance
	**/
	public function swapDisplay(display:Display):Void
	{
		if (peoteView != null && display.peoteView != null) peoteView.displayList.swap(this, display);
		else throw("Error, display is not added to peoteView");
	}

	/**
		Swaps the order of two `Program`s inside the RenderList.
		@param  program Program instance
		@param  programToSwapWith Program instance to swap with
	**/
	public function swapPrograms(program:Program, programToSwapWith:Program):Void
	{
		programList.swap(program, programToSwapWith);
	}

	private function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// clear old gl-context if there is one
			if (gl != null) clearOldGLContext();
			#if peoteview_debug_display
			trace("Display setNewGLContext");
			#end
			gl = newGl;			
			if (PeoteGL.Version.isUBO) {
				uniformBuffer.createGLBuffer(gl, x + xOffset, y + yOffset, xz, yz);
				uniformBufferFB.createGLBuffer(gl, xOffset, yOffset - height, xz, yz);
				uniformBufferViewFB.createGLBuffer(gl, width, -height, 0.0, 0.0, 1.0, 1.0);
			}
			
			// setNewGLContext for all programs
			for (program in programList) program.setNewGLContext(newGl);			
			if (fbTexture != null) fbTexture.setNewGLContext(newGl);			
		}
	}

	private inline function clearOldGLContext()
	{
		#if peoteview_debug_display
		trace("Display clearOldGLContext");
		#end
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.deleteGLBuffer(gl);
			uniformBufferFB.deleteGLBuffer(gl);
			uniformBufferViewFB.deleteGLBuffer(gl);
		}
	}

	
	/**
		Returns true if the program is added to the RenderList already.
		@param program Program instance
	**/
	public inline function hasProgram(program:Program):Bool return program.isIn(this);
	
	/**
		Adds a `Program` instance to the RenderList of this Display.
		Can be also used to change the order relative to another program if it's already added.
		@param program Program instance to add into the RenderList or to change it's order
		@param atProgram (optional) to add or move the program before or after another program in the Renderlist (by default it's added at start or end)
		@param addBefore (optional) if 'true' it's added before another program or at start of the Renderlist (by default it's added after atProgram or at end of the list)
	**/
	public function addProgram(program:Program, ?atProgram:Program, addBefore:Bool=false)
	{
		program.addToDisplay(this, atProgram, addBefore);
	}
	
	/**
		Removes a `Program` instance from the RenderList.
		@param program Program instance
	**/
	public function removeProgram(program:Program):Void
	{
		program.removeFromDisplay(this);
	}
	
	
	// -------------------- set Framebuffer Texture ------------------------------

	/**
		Set a `Texture` instance to use as a framebuffer for renderToTexture()
		@param texture Texture instance to render into
		@param textureSlot number of texture-slot to render into (can be changed by set the 'framebufferTextureSlot' property)
		@param peoteView optional parameter that is need if the display not already added to a RenderList
	**/
	public function setFramebuffer(texture:Texture, ?textureSlot:Null<Int>, ?peoteView:PeoteView) {
		if (fbTexture == texture) throw("Error, texture is already in use as Framebuffer for Display");
		if (textureSlot != null && textureSlot >= texture.slots) throw("Error, maximum texture slot of framebufferTexture is" + (texture.slots - 1));
		
		if (peoteView == null) {
			if (gl == null) throw("Error, if the display is not added it needs the gl-context of a peoteView to set a framebuffer texture");
		}
		else if ( ! isIn(peoteView) ) {
			this.peoteView = peoteView;
			setNewGLContext(peoteView.gl);
		}
		
		if (textureSlot != null) framebufferTextureSlot = textureSlot;
		
		if (fbTexture != null) fbTexture.removeFromDisplay(this);
		fbTexture = texture;
		fbTexture.addToDisplay(this);
		if (renderFramebufferEnabled) _renderFramebufferEnabled = true;
	}

	/**
		Clears the framebuffer for renderToTexture()
	**/
	public function removeFramebuffer() {
		_renderFramebufferEnabled = false;
		fbTexture.removeFromDisplay(this);
		fbTexture = null;
		framebufferTextureSlot = 0;
	}
	
	/**
		The texture to render the display content inside if using into framebuffer-mode.
	**/
	public var fbTexture(default, null):Texture = null;
	
	/**
		The texture-slot where to render into by renderToTexture().
	**/
	public var framebufferTextureSlot:Int = 0;

	/**
		Enable or disable texture-rendering if the display is inside the framebuffer chain.
	**/
	public var renderFramebufferEnabled(default, set):Bool = true;
	inline function set_renderFramebufferEnabled(b:Bool):Bool {
		if (b && fbTexture != null) _renderFramebufferEnabled = true;
		else _renderFramebufferEnabled = false;
		return renderFramebufferEnabled = b;
	}
	var _renderFramebufferEnabled:Bool = false;
	
	/**
		If the display is inside the framebuffer chain, this defines how many frames are skipped before it renders into the texture again.
	**/
	public var renderFramebufferSkipFrames:Int = 0;
	var renderFramebufferFrame:Int = 0;


	// ----------------------------- Helpers ----------------------------------------

	/**
		Gives true if a point at global screenposition px and py is inside the Display-area.
		@param px global x-position
		@param py global y-position
		@param peoteView (optional) if not already added to a peoteView you can set one here to include it's zoom and offset into calculation
	**/
	public inline function isPointInside(px:Int, py:Int, peoteView:PeoteView = null):Bool {
		if (peoteView == null) peoteView = this.peoteView;
		if (peoteView != null) {
			px = Std.int(px/peoteView.xz - peoteView.xOffset);
			py = Std.int(py/peoteView.yz - peoteView.yOffset);			
		}
		return (px >= x && px < x + width && py >= y && py < y + height);
	}

	/**
		Converts a local x-position from display-coordinates to the correspondending global screen ones.
		@param localX x-position inside of the display
		@param peoteView (optional) if not already added to a peoteView you can set one here to include it's zoom and offset into calculation
	**/
	public inline function globalX(localX:Float, peoteView:PeoteView = null):Float {
		if (peoteView == null) peoteView = this.peoteView;
		if (peoteView != null) return (localX * xz + peoteView.xOffset + xOffset + x) * peoteView.xz;
		else return localX * xz + xOffset + x;
	}

	/**
		Converts a global x-position from screen-coordinates to the correspondending local display ones.
		@param globalX x-position at screen
		@param peoteView (optional) if not already added to a peoteView you can set one here to include it's zoom and offset into calculation
	**/
	public inline function localX(globalX:Float, peoteView:PeoteView = null):Float {
		if (peoteView == null) peoteView = this.peoteView;
		if (peoteView != null) return (globalX / peoteView.xz - peoteView.xOffset - xOffset - x) / xz;
		else return (globalX - xOffset - x) / xz;
	}

	/**
		Converts a local y-position from display-coordinates to the correspondending global screen ones.
		@param localY y-position inside of the display
		@param peoteView (optional) if not already added to a peoteView you can set one here to include it's zoom and offset into calculation
	**/
	public inline function globalY(localY:Float, peoteView:PeoteView = null):Float {
		if (peoteView == null) peoteView = this.peoteView;
		if (peoteView != null) return (localY * yz + peoteView.yOffset + yOffset + y) * peoteView.yz;
		else return localY * yz + yOffset + y;
	}

	/**
		Converts a global y-position from screen-coordinates to the correspondending local display ones.
		@param globalY y-position at screen
		@param peoteView (optional) if not already added to a peoteView you can set one here to include it's zoom and offset into calculation
	**/
	public inline function localY(globalY:Float, peoteView:PeoteView = null):Float {
		if (peoteView == null) peoteView = this.peoteView;
		if (peoteView != null) return (globalY / peoteView.yz - peoteView.yOffset - yOffset - y) / yz;
		else return (globalY - yOffset - y) / yz;
	}

	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function glScissor(gl:PeoteGL, w:Int, h:Int, xo:Float, yo:Float, xz:Float, yz:Float):Void
	{	
		var sx:Int = Math.floor((x + xo) * xz);
		var sy:Int = Math.floor((y + yo) * yz);
		var sw:Int = Math.floor(width  * xz);
		var sh:Int = Math.floor(height * yz);
		
		if (sx < 0) sw += sx;
		sx = Std.int( Math.max(0, Math.min(w, sx)) );
		sw = Std.int( Math.max(0, Math.min(w-sx, sw)) );
		
		if (sy < 0) sh += sy;
		sy = Std.int( Math.max(0, Math.min(h, sy)) );
		sh = Std.int( Math.max(0, Math.min(h-sy, sh)) );

		gl.scissor(sx, h - sh - sy, sw, sh);
	}
	
	var programListItem:RenderListItem<Program>;
	
	private inline function render(peoteView:PeoteView):Void
	{
		if (isVisible)
		{
			//trace("  ---display.render---");
			glScissor(peoteView.gl, peoteView.width, peoteView.height, peoteView.xOffset, peoteView.yOffset, peoteView.xz, peoteView.yz);
			
			if (backgroundEnabled) {
				peoteView.setColor(true);
				peoteView.setGLDepth(backgroundDepth);				
				peoteView.setGLBlend(backgroundAlpha, false, peoteView.gl.SRC_ALPHA, peoteView.gl.ONE_MINUS_SRC_ALPHA, 0, 0, false, peoteView.gl.FUNC_ADD, 0, 0, false, false, 0.0, 0.0, 0.0, 0.0);				
				peoteView.setMask(Mask.OFF, false);
				peoteView.background.render(red, green, blue, alpha);
			}
			
			renderProgram(peoteView);
		}		
	}

	// -- let write custom GL code inside a Childclass by overriding this --
	#if !peoteview_customdisplay inline #end
	private function renderProgram(peoteView:PeoteView):Void
	{
		programListItem = programList.first;
		while (programListItem != null)
		{
			programListItem.value.render(peoteView, this);			
			programListItem = programListItem.next;
		}
	}

	// ------------------------------------------------------------------------------
	// ------------------------ RENDER TO TEXTURE ----------------------------------- 
	// ------------------------------------------------------------------------------

	/**
		Renders the content of this Display into a texture.
		@param peoteView PeoteView instance
		@param slot (0 by default) the image-slot inside of the texture (if the framebuffer texture can contain more then one)
	**/
	public inline function renderToTexture(peoteView:PeoteView, ?textureSlot:Null<Int>) peoteView.renderToTexture(this, textureSlot);
	
	private inline function renderFramebuffer(peoteView:PeoteView):Void
	{
		if (backgroundEnabled) {
			peoteView.setColor(true);
			peoteView.setGLBlend(backgroundAlpha, false, peoteView.gl.SRC_ALPHA, peoteView.gl.ONE_MINUS_SRC_ALPHA, 0, 0, false, peoteView.gl.FUNC_ADD, 0, 0, false, false, 0.0, 0.0, 0.0, 0.0);
			peoteView.setMask(Mask.OFF, false);
			peoteView.background.render(red, green, blue, alpha);
		}		
		renderFramebufferProgram(peoteView);
	}

	// -- let write custom GL code inside a Childclass by overriding this --
	#if !peoteview_customdisplay inline #end
	private function renderFramebufferProgram(peoteView:PeoteView):Void
	{
		programListItem = programList.first;
		while (programListItem != null)
		{
			programListItem.value.renderFramebuffer(peoteView, this);			
			programListItem = programListItem.next;
		}
	}

	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private inline function pick( xOff:Float, yOff:Float, peoteView:PeoteView, program:Program, toElement:Int = -1):Void
	{
		glScissor(peoteView.gl, 1, 1, xOff, yOff, peoteView.xz, peoteView.yz);
		program.pick( xOff, yOff, peoteView, this, toElement);
	}

}