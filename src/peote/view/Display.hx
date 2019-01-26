package peote.view;

import peote.view.utils.RenderList;
import peote.view.utils.RenderListItem;

@:allow(peote.view)
class Display 
{
	// params
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;
	
	public var backgroundAlpha:Bool = false;
	public var backgroundDepth:Bool = false;
	public var backgroundEnabled:Bool = false;
	
	private var xz(default, null):Float = 1.0;
	private var yz(default, null):Float = 1.0;

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
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXOffset(gl, x + xo);
		return xOffset = xo;
	}
	public var yOffset(default, set):Float = 0;
	public inline function set_yOffset(yo:Float):Float {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYOffset(gl, y + yo);
		return yOffset = yo;
	}
	
	public var color(default,set):Color = 0x00000000;
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
	
	var peoteView:PeoteView = null;
	var gl:PeoteGL = null;

	var programList:RenderList<Program>;
		
	var uniformBuffer:UniformBufferDisplay;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) 
	{	
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		set_color(color);
		
		programList = new RenderList<Program>(new Map<Program,RenderListItem<Program>>());
		
		if (PeoteGL.Version.isUBO) uniformBuffer = new UniformBufferDisplay();
	}

	private inline function addToPeoteView(peoteView:PeoteView):Bool
	{
		trace("Display added to PeoteView");
		if (this.peoteView == peoteView) return false; // is already added
		else
		{
			if (this.peoteView != null) {  // was added to another peoteView
				this.peoteView.removeDisplay(this); // removing from the other one
			}
			
			this.peoteView = peoteView;
			
			if (this.gl != peoteView.gl) // new or different GL-Context
			{
				if (this.gl != null) clearOldGLContext(); // different GL-Context
				setNewGLContext(peoteView.gl);
			} 
			// if it's stay into same gl-context, no buffers had to recreate/fill
			return true;
		}
	}
	
	private inline function removedFromPeoteView():Void
	{
		peoteView = null;
	}
		
	private inline function setNewGLContext(newGl:PeoteGL) 
	{
		trace("Display setNewGLContext");
		gl = newGl;
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.createGLBuffer(gl, x + xOffset, y + yOffset, xz, yz);
		}
		for (program in programList) program.setNewGLContext(newGl);
		if (fbTexture != null) fbTexture.setNewGLContext(newGl);
	}

	private inline function clearOldGLContext() 
	{
		trace("Display clearOldGLContext");
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.deleteGLBuffer(gl);
		}
		for (program in programList) program.clearOldGLContext();
		if (fbTexture != null) fbTexture.clearOldGLContext();
	}

	
 	private inline function isIn(peoteView:PeoteView):Bool
	{
		return (this.peoteView == peoteView);
	}
			
 	public inline function hasProgram(program:Program):Bool
	{
		return program.isIn(this);
	}
			
   /**
        Adds an Program instance to the RenderList. If it's already added it can be used to 
		change the order of rendering relative to another program in the List.

        @param  program Program instance to add into the RenderList or to change it's order
        @param  atProgram (optional) to add or move the program before or after another program in the Renderlist (at default it adds at start or end)
        @param  addBefore (optional) set to `true` to add the program before another program or at start of the Renderlist (at default it adds after atProgram or at end of the list)
    **/
	public function addProgram(program:Program, ?atProgram:Program, addBefore:Bool=false)
	{
		if (program.addToDisplay(this)) programList.add(program, atProgram, addBefore);
		else throw ("Error: program is already added to this display");
	}
	
    /**
        This function removes an Program instance from the RenderList.
    **/
	public function removeProgram(program:Program):Void
	{
		programList.remove(program);
		program.removedFromDisplay();
	}
	
	var fbTexture:Texture = null;
	public function setTextureToRenderIn(texture:Texture) {
		if (fbTexture == texture) throw("Error, texture already in use as Framebuffer for Display");
		if (fbTexture != null) fbTexture.removeFramebufferFromDisplay(this);
		fbTexture = texture;
		if (! fbTexture.setFramebufferToDisplay(this) ) throw("Error, texture already used into different gl-context");
	}
	public function removeTextureToRenderIn() {
		fbTexture.removeFramebufferFromDisplay(this);
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
		//trace("  ---display.render---");
		glScissor(peoteView.gl, peoteView.width, peoteView.height, peoteView.xOffset, peoteView.yOffset, peoteView.xz, peoteView.yz);
		
		if (backgroundEnabled) {
			peoteView.setGLDepth(backgroundDepth);
			peoteView.setGLAlpha(backgroundAlpha);
			peoteView.background.render(red, green, blue, alpha);
		}
		
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
	public inline function renderToTexture(peoteView:PeoteView) peoteView.renderToTexture(this);
	
	private inline function renderFramebuffer(peoteView:PeoteView):Void
	{
		// TODO: change the uniform-buffers for peote-view and display (to match new size)
		// get width and height from fbTexture!
		// no scissoring need here!
		if (backgroundEnabled) {
			peoteView.setGLAlpha(backgroundAlpha);
			peoteView.background.render(red, green, blue, alpha);
		}
		
		programListItem = programList.first;
		while (programListItem != null)
		{
			programListItem.value.render(peoteView, this);			
			programListItem = programListItem.next;
		}
	}
	
	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private inline function pick( xOff:Float, yOff:Float, peoteView:PeoteView, program:Program):Void
	{
		glScissor(peoteView.gl, 1, 1, xOff, yOff, peoteView.xz, peoteView.yz);
		program.pick( xOff, yOff, peoteView, this);
	}

}