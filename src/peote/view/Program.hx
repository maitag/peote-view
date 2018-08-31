package peote.view;

import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;

import peote.view.utils.GLTool;

@:allow(peote.view)
class Program 
{
	var display:Display = null;
	var gl:PeoteGL = null;

	var glProgram:GLProgram = null;
	var glVertexShader:GLShader = null;
	var glFragmentShader:GLShader = null;
	
	var buffer:BufferInterface;
	//var uniforms:Vector<GLUniformLocation>;
	
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
	}
	
 	private inline function isIn(display:Display):Bool
	{
		return (this.display == display);
	}
			
	private inline function addToDisplay(display:Display):Bool
	{
		
		if (this.display == display) return false; // is already added
		else
		{
			if (this.display != null) {  // was added to another display
				trace("removing from " + ((this.display.blue == 1.0)?"blue":"green"));
				this.display.removeProgram(this); // removing from the other one
			}
			
			this.display = display;
			
			if (this.gl != display.gl) // new or different GL-Context
			{
				if (this.gl != null) clearOldGLContext(); // different GL-Context
				setNewGLContext(display.gl);
			} // if it's stay into same gl-context, no buffers had to recreate/fill
			#if (peoteview_es3 && peoteview_uniformbuffers)
			else if (gl!=null) display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
			#end
			return true;
		}	
	}

	private inline function removedFromDisplay():Void
	{
		display = null;
	}
		
	
	private inline function setNewGLContext(newGl:PeoteGL)
	{
		trace("Program setNewGLContext");
		gl = newGl;
		buffer._gl = gl;          // TODO: check here if buffer already inside another peoteView with different glContext (multiwindows)
		buffer.createGLBuffer();
		buffer.updateGLBuffer();
		createProgram();
	}

	private inline function clearOldGLContext() 
	{
		trace("Program clearOldGLContext");
		
		gl.deleteShader(glVertexShader);
		gl.deleteShader(glFragmentShader);
		gl.deleteProgram(glProgram);
		
		buffer.deleteGLBuffer();
	}
	
	
	public function addTexture(texture:Texture) 
	{
		// TODO
	}
	
	public function removeTexture(texture:Texture) 
	{
		// TODO
	}
	
	private function createProgram():Void  // TODO: do not compile twice if same program is used inside multiple displays
	{
		trace("create Program");
		glVertexShader   = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   buffer.getVertexShader() );
		glFragmentShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, buffer.getFragmentShader() );
		
		glProgram = gl.createProgram();

		gl.attachShader(glProgram, glVertexShader);
		gl.attachShader(glProgram, glFragmentShader);
		
		buffer.bindAttribLocations(gl, glProgram);
		
		GLTool.linkGLProgram(gl, glProgram);
		
		#if (peoteview_es3 && peoteview_uniformbuffers)
		display.peoteView.uniformBuffer.bindToProgram(gl, glProgram, "uboView", 0);
		display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
		#else
		uRESOLUTION = gl.getUniformLocation(glProgram, "uResolution");
		uZOOM = gl.getUniformLocation(glProgram, "uZoom");
		uOFFSET = gl.getUniformLocation(glProgram, "uOffset");
		#end	
	}
	
	#if !(peoteview_es3 && peoteview_uniformbuffers)
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	#end
	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function render(peoteView:PeoteView, display:Display)
	{	
		//trace("    ---program.render---");
		peoteView.gl.useProgram(glProgram); // ------ Shader Program
		
		#if (peoteview_es3 && peoteview_uniformbuffers)
		// ------------- uniform block -------------
		//peoteView.gl.bindBufferRange(peoteView.gl.UNIFORM_BUFFER, 0, uProgramBuffer, 0, 8);
		peoteView.gl.bindBufferBase(peoteView.gl.UNIFORM_BUFFER, peoteView.uniformBuffer.block , peoteView.uniformBuffer.uniformBuffer);
		peoteView.gl.bindBufferBase(peoteView.gl.UNIFORM_BUFFER, display.uniformBuffer.block , display.uniformBuffer.uniformBuffer);
		#else
		// ------------- simple uniform -------------
		peoteView.gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
		peoteView.gl.uniform1f (uZOOM, peoteView.zoom * display.zoom);
		peoteView.gl.uniform2f (uOFFSET, (display.x + display.xOffset + peoteView.xOffset) / display.zoom, 
		                                 (display.y + display.yOffset + peoteView.yOffset) / display.zoom);
		// TODO: from Program
		#end
		
		buffer.render(peoteView, display, this);
		peoteView.gl.useProgram (null);
	}
	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private inline function pick( mouseX:Int, mouseY:Int, peoteView:PeoteView, display:Display):Void
	{
		// TODO
		// peoteView.gl.useProgram(glProgramPick);
		// TODO -> translate peoteview relative to zoom and mouseposition before rendreing
		// no changes for the uniform-buffers for the picking-shader
	}
	
}