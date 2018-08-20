package peote.view;

import peote.view.utils.RenderList;
import peote.view.utils.RenderListItem;

@:allow(peote.view)
class Display 
{
	// params
	public var x:Int = 0; // x Position
	public var y:Int = 0; // y Position
	public var z:Int = 0; // z order
	public var width:Int = 0;  // width
	public var height:Int = 0; // height
	public var zoom:Float = 1.0;
	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	public var red:Float = 0.0;
	public var green:Float = 1.0;
	public var blue:Float = 0.0;
	public var alpha:Float = 0.0;
	
	var gl:PeoteGL = null; // TODO: multiple rendercontexts

	var programList:RenderList<Program>;
		
	public function new() 
	{
		programList = new RenderList<Program>(new Map<Program,RenderListItem<Program>>());
	}

	
	public function addProgram(program:Program, ?atProgram:Program, addBefore:Bool=false)
	{
		if (program.gl == null) // TODO: multiple rendercontexts
		{
			if (program.buffer._gl == null || program.buffer._gl == this.gl) // TODO: multiple rendercontexts
			{
				
				// TODO: multiple rendercontexts
				program.gl = this.gl;
				program.buffer._gl = this.gl;
				program.buffer.createGlBuffer();

				program.compile();
				
				programList.add(program, atProgram, addBefore);
				
			}
			else throw ("Error: buffer is already in use by another peoteView");
		}
		else throw ("Error: program is already added to this or another peoteView");
	}
	
	public function removeProgram(program:Program):Void
	{
		programList.remove(program);
		// TODO: multiple rendercontexts
		program.gl = null;
	}
	

	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function render_scissor(peoteView:PeoteView):Void
	{
		var sx:Int = Math.floor((x + peoteView.xOffset) * peoteView.zoom);
		var sy:Int = Math.floor((y + peoteView.yOffset) * peoteView.zoom);
		var sw:Int = Math.floor((width != 0) ? width * peoteView.zoom: peoteView.width * peoteView.zoom);
		var sh:Int = Math.floor((height != 0) ? height * peoteView.zoom: peoteView.height * peoteView.zoom);
		
		if (sx < 0) sw += sx;
		sx = Std.int( Math.max(0, Math.min(peoteView.width, sx)) );
		sw = Std.int( Math.max(0, Math.min(peoteView.width-sx, sw)) );
		
		if (sy < 0) sh += sy;
		sy = Std.int( Math.max(0, Math.min(peoteView.height, sy)) );
		sh = Std.int( Math.max(0, Math.min(peoteView.height-sy, sh)) );

		peoteView.gl.scissor(sx, peoteView.height - sh - sy, sw, sh);
	}
	
	var renderListItem:RenderListItem<Program>;
	var renderProgram:Program;
	
	private function render(peoteView:PeoteView):Void
	{
		//trace("  ---display.render---");
		
		render_scissor(peoteView);
		peoteView.background.render(red, green, blue, alpha);
		
		renderListItem = programList.first;
		while (renderListItem != null)
		{
			renderProgram = renderListItem.value;
			renderProgram.render(peoteView, this);
			
			renderListItem = renderListItem.next;// next displaylist in renderlist
		}
		
	}
	
	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private function pick(peoteView:PeoteView, mouseX:Int, mouseY:Int):Void
	{
		// TODO: in buffer
		// how to enable Element-access ???
	}

}