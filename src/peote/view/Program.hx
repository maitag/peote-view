package peote.view;

import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;

import peote.view.utils.GLTool;

@:allow(peote.view)
class Program 
{
	public var alphaEnabled:Bool;
	public var zIndexEnabled:Bool;
	
	var display:Display = null;
	var gl:PeoteGL = null;

	var glProgram:GLProgram = null;
	var glVertexShader:GLShader = null;
	var glFragmentShader:GLShader = null;
	
	var buffer:BufferInterface; // TODO: make public with getter/setter
	
	public var glShaderConfig = {
		isES3: false,
		isINSTANCED: false,
		isUBO: false,
		IN: "attribute",
		VARIN: "varying",
		VAROUT: "varying",
	};
	
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
		alphaEnabled = buffer.hasAlpha();
		zIndexEnabled = buffer.hasZindex();
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
			// if added to another one remove it frome there first
			if (this.display != null) this.display.removeProgram(this);
			
			this.display = display;
			
			if (gl != display.gl) // new or different GL-Context
			{
				if (gl != null) clearOldGLContext(); // different GL-Context
				setNewGLContext(display.gl);
			}
			else if (PeoteGL.Version.isUBO)
			{	// if Display is changed but same gl-context -> bind to UBO of new Display
				if (gl!=null) display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
			}
			
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
		
		if (PeoteGL.Version.isES3) {
			glShaderConfig.isES3 = true;
			glShaderConfig.IN = "in";
			glShaderConfig.VARIN = "in";
			glShaderConfig.VAROUT = "out";
		}
		if (PeoteGL.Version.isUBO)       glShaderConfig.isUBO = true;
		if (PeoteGL.Version.isINSTANCED) glShaderConfig.isINSTANCED = true;
		
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
		glVertexShader   = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   GLTool.parseShader(buffer.getVertexShader(), glShaderConfig) );
		glFragmentShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, GLTool.parseShader(buffer.getFragmentShader(), glShaderConfig) );
		
		glProgram = gl.createProgram();

		gl.attachShader(glProgram, glVertexShader);
		gl.attachShader(glProgram, glFragmentShader);
		
		buffer.bindAttribLocations(gl, glProgram);
		
		GLTool.linkGLProgram(gl, glProgram);
		
		if (PeoteGL.Version.isUBO)
		{
			display.peoteView.uniformBuffer.bindToProgram(gl, glProgram, "uboView", 0);
			display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
		}
		else
		{
			uRESOLUTION = gl.getUniformLocation(glProgram, "uResolution");
			uZOOM = gl.getUniformLocation(glProgram, "uZoom");
			uOFFSET = gl.getUniformLocation(glProgram, "uOffset");
		}
		uTIME = gl.getUniformLocation(glProgram, "uTime");
	}
	
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	
	var uTEXTURE:haxe.ds.Vector<GLUniformLocation>;
	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function render(peoteView:PeoteView, display:Display)
	{	
		//trace("    ---program.render---");
		gl.useProgram(glProgram); // ------ Shader Program
		
		
		// Texture Units
		/*
		 * TODO: lieber nicht mit "add" sondern program.setTexture(0, texture) um direkt in die Unit-Nummer zu setzen
		 *       im Element dann definieren welche Unitnummer welche Art von Texture (z.b. color, alpha-mask, uv ..usw) 
		 *    
		 * 
		textureListItem = textureList.first;
		var i = 0;
		while (textureListItem != null)
		{
			gl.activeTexture (gl.TEXTURE0+i);
			gl.bindTexture (gl.TEXTURE_2D, textureListItem.value); // <-- das hier optimieren!!!
			//gl.enable(gl.TEXTURE_2D); // is default ?
			
			// TODO: UBOs also
			gl.uniform1i (uTEXTURE.get(i), i); // Uniform 2d Sampler
			i++;
		}
		*/
		
		// TODO: from Program
		if (PeoteGL.Version.isUBO)
		{	
			// ------------- uniform block -------------
			//gl.bindBufferRange(gl.UNIFORM_BUFFER, 0, uProgramBuffer, 0, 8);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, peoteView.uniformBuffer.block , peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, display.uniformBuffer.block , display.uniformBuffer.uniformBuffer);
		}
		else
		{
			// ------------- simple uniform -------------
			gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			gl.uniform1f (uZOOM, peoteView.zoom * display.zoom);
			gl.uniform2f (uOFFSET, (display.x + display.xOffset + peoteView.xOffset) / display.zoom, 
											 (display.y + display.yOffset + peoteView.yOffset) / display.zoom);
		}
		
		gl.uniform1f (uTIME, peoteView.time);
		
		peoteView.setGLDepth(zIndexEnabled);
		peoteView.setGLAlpha(alphaEnabled);
		
		buffer.render(peoteView, display, this);
		gl.useProgram (null);
	}
	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private inline function pick( mouseX:Int, mouseY:Int, peoteView:PeoteView, display:Display):Void
	{
		// TODO
		// gl.useProgram(glProgramPick);
		// TODO -> translate peoteview relative to zoom and mouseposition before rendreing
		// no changes for the uniform-buffers for the picking-shader
	}
	
}