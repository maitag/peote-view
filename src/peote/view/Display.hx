package peote.view;

import peote.view.utils.RenderList;
import peote.view.utils.RenderListItem;

@:allow(peote.view)
class Display 
{
	public var width:Int = 0;
	public var height:Int = 0;
	
	#if jasper // cassowary constraints (jasper lib)
	public var layout(default, null) = new peote.ui.Layout.Layout();
	public function updateLayout() {
		//trace("update display");
		if (x != Std.int(layout.x.m_value)) x = Std.int(layout.x.m_value);
		if (y != Std.int(layout.y.m_value)) y = Std.int(layout.y.m_value);
		width  = Std.int(layout.width.m_value);
		height = Std.int(layout.height.m_value);
	}
	#end
	
	public var x(default, set):Int = 0;
	public inline function set_x(_x:Int):Int {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXOffset(gl, _x + xOffset);
		return x = _x;
	}
	public var y(default, set):Int = 0;
	public inline function set_y(_y:Int):Int {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYOffset(gl, _y + yOffset);
		return y = _y;
	}
	public var xOffset(default, set):Float = 0;
	public inline function set_xOffset(xo:Float):Float {
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.updateXOffset(gl, x + xo);
			uniformBufferFB.updateXOffset(gl, xo);
		}
		return xOffset = xo;
	}
	public var yOffset(default, set):Float = 0;
	public inline function set_yOffset(yo:Float):Float {
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.updateYOffset(gl, y + yo);
			uniformBufferFB.updateYOffset(gl, yo - height);
		}
		return yOffset = yo;
	}

	private var xz(default, null):Float = 1.0;
	private var yz(default, null):Float = 1.0;

	public var zoom(default, set):Float = 1.0;
	public inline function set_zoom(z:Float):Float {
		xz = xZoom * z;
		yz = yZoom * z;
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.updateZoom(gl, xz, yz);
			uniformBufferFB.updateZoom(gl, xz, yz);
		}
		return zoom = z;
	}
	public var xZoom(default, set):Float = 1.0;
	public inline function set_xZoom(z:Float):Float {
		xz = zoom * z;
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.updateXZoom(gl, xz);
			uniformBufferFB.updateXZoom(gl, xz);
		}
		return xZoom = z;
	}
	public var yZoom(default, set):Float = 1.0;
	public inline function set_yZoom(z:Float):Float {
		yz = zoom * z;
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.updateYZoom(gl, yz);
			uniformBufferFB.updateYZoom(gl, yz);
		}
		return yZoom = z;
	}
	
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
	
	public var backgroundAlpha:Bool = false;
	public var backgroundDepth:Bool = false;
	public var backgroundEnabled:Bool = false;
	
	var red:Float = 0.0;
	var green:Float = 0.0;
	var blue:Float = 0.0;
	var alpha:Float = 1.0;

	
	var peoteViews = new Array<PeoteView>();
	var gl:PeoteGL = null;

	var programList:RenderList<Program>;
		
	var uniformBuffer:UniformBufferDisplay;
	var uniformBufferFB:UniformBufferDisplay;
	var uniformBufferViewFB:UniformBufferView;
	
	var fbTexture:Texture = null;
	
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) 
	{
		#if jasper // cassowary constraints (jasper lib)
		layout.update = updateLayout;
		#end
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

 	public inline function isIn(peoteView:PeoteView):Bool return (peoteViews.indexOf(peoteView) >= 0);			

	public function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		#if peoteview_debug_display
		trace("Add Display to PeoteView");
		#end
		if ( isIn(peoteView) ) throw("Error, display is already added to this peoteView");
		peoteViews.push(peoteView);
		setNewGLContext(peoteView.gl);
		peoteView.displayList.add(this, atDisplay, addBefore);
	}
	
	public function removeFromPeoteView(peoteView:PeoteView)
	{
		#if peoteview_debug_display
		trace("Removed Display from PeoteView");
		#end
		if (!peoteViews.remove(peoteView)) throw("Error, display is not inside peoteView");
		peoteView.displayList.remove(this);
	}
	
	private function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// check gl-context of all parents
			for (peoteView in peoteViews)
				if (peoteView.gl != null && peoteView.gl != newGl)  throw("Error, display can not used inside different gl-contexts");
			
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

	
 	public inline function hasProgram(program:Program):Bool return program.isIn(this);
			
   /**
        Adds an Program instance to the RenderList. If it's already added it can be used to 
		change the order of rendering relative to another program in the List.

        @param  program Program instance to add into the RenderList or to change it's order
        @param  atProgram (optional) to add or move the program before or after another program in the Renderlist (at default it adds at start or end)
        @param  addBefore (optional) set to `true` to add the program before another program or at start of the Renderlist (at default it adds after atProgram or at end of the list)
    **/
	public function addProgram(program:Program, ?atProgram:Program, addBefore:Bool=false)
	{
		program.addToDisplay(this, atProgram, addBefore);
	}
	
    /**
        This function removes an Program instance from the RenderList.
    **/
	public function removeProgram(program:Program):Void
	{
		program.removeFromDisplay(this);
	}
	
	public function setFramebuffer(texture:Texture) {
		if (fbTexture == texture) throw("Error, texture is already in use as Framebuffer for Display");
		if (fbTexture != null) fbTexture.removeFromDisplay(this);
		fbTexture = texture;
		fbTexture.addToDisplay(this);
	}

	public function removeFramebuffer() {
		fbTexture.removeFromDisplay(this);
		fbTexture = null;
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
		if (backgroundEnabled) {
			peoteView.setGLAlpha(backgroundAlpha);
			peoteView.background.render(red, green, blue, alpha);
		}
		
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