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
	
	public var zoom(default, set):Float = 1.0;
	public inline function set_zoom(z:Float):Float {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateZoom(gl, z);
		return zoom = z;
	}
	public var xOffset(default, set):Int = 0;
	public inline function set_xOffset(offset:Int):Int {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXOffset(gl, x + offset);
		return xOffset = offset;
	}
	public var yOffset(default, set):Int = 0;
	public inline function set_yOffset(offset:Int):Int {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYOffset(gl, y + offset);
		return yOffset = offset;
	}
	
	public var color(default,set):Color = 0x000000FF;
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

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x000000FF) 
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
			uniformBuffer.createGLBuffer(gl, x + xOffset, y + yOffset, zoom);
		}
		// for all programms in list
		var listItem:RenderListItem<Program> = programList.first;
		while (listItem != null)
		{
			listItem.value.setNewGLContext(gl);
			listItem = listItem.next;
		}
	}

	private inline function clearOldGLContext() 
	{
		trace("Display clearOldGLContext");
		if (PeoteGL.Version.isUBO) {
			uniformBuffer.deleteGLBuffer(gl);
		}
		// for all programms in list
		var listItem:RenderListItem<Program> = programList.first;
		while (listItem != null)
		{
			listItem.value.clearOldGLContext();
			listItem = listItem.next;
		}
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
	

	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function glScissor(gl:PeoteGL, width:Int, height:Int, zoom:Float, xOffset:Float, yOffset:Float):Void
	{
		var sx:Int = Math.floor((x + xOffset) * zoom);
		var sy:Int = Math.floor((y + yOffset) * zoom);
		var sw:Int = Math.floor(this.width  * zoom);
		var sh:Int = Math.floor(this.height * zoom);
		
		if (sx < 0) sw += sx;
		sx = Std.int( Math.max(0, Math.min(width, sx)) );
		sw = Std.int( Math.max(0, Math.min(width-sx, sw)) );
		
		if (sy < 0) sh += sy;
		sy = Std.int( Math.max(0, Math.min(height, sy)) );
		sh = Std.int( Math.max(0, Math.min(height-sy, sh)) );

		gl.scissor(sx, height - sh - sy, sw, sh);
	}
	
	var renderListItem:RenderListItem<Program>;
	var renderProgram:Program;
	
	private inline function render(peoteView:PeoteView):Void
	{	
		//trace("  ---display.render---");
		glScissor(peoteView.gl, peoteView.width, peoteView.height, peoteView.zoom, peoteView.xOffset, peoteView.yOffset);
		
		if (backgroundEnabled) {
			peoteView.setGLDepth(backgroundDepth);
			peoteView.setGLAlpha(backgroundAlpha);
			peoteView.background.render(red, green, blue, alpha);
		}
		
		renderListItem = programList.first;
		while (renderListItem != null)
		{
			renderProgram = renderListItem.value;
			renderProgram.render(peoteView, this);
			
			renderListItem = renderListItem.next;// next program in renderlist
		}
		
	}
	
	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private function pick( mouseX:Int, mouseY:Int, peoteView:PeoteView, program:Program):Void
	{
		glScissor(peoteView.gl, 1, 1, peoteView.zoom, peoteView.xOffset, peoteView.yOffset);
		// TODO
		
		program.pick( mouseX, mouseY, peoteView, this);
	}

}