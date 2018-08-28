package peote.view;

import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;

@:allow(peote.view)
class Program 
{
	var display:Display = null;
	var gl:PeoteGL = null;

	var glProgram:GLProgram = null;
	var buffer:BufferInterface;
	//var uniforms:Vector<GLUniformLocation>;
	
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
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
		buffer._gl = gl;
		buffer.createGLBuffer();
		buffer.updateGLBuffer();
		compile();
	}

	private inline function clearOldGLContext() 
	{
		trace("Program clearOldGLContext");
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
	
	function compile():Void  // TODO: do not compile twice if same program is used inside multiple displays
	{
		trace("compile shader");
		//trace("EXTENSIONS:\n"+gl.getSupportedExtensions());
		
		var vertexShaderSrc = buffer.getVertexShader();
		var fragmentShaderSrc =  buffer.getFragmentShader();
		
		var fs = gl.createShader(gl.FRAGMENT_SHADER);
		gl.shaderSource(fs, fragmentShaderSrc);
		gl.compileShader(fs);
		
		var vs = gl.createShader(gl.VERTEX_SHADER);
		gl.shaderSource(vs, vertexShaderSrc);
		gl.compileShader(vs);
		
		if      (gl.getShaderParameter(fs, gl.COMPILE_STATUS) == 0) trace("ERROR fragmentShader: " + gl.getShaderInfoLog(fs));
		else if (gl.getShaderParameter(vs, gl.COMPILE_STATUS) == 0) trace("ERROR vertexShader: " + gl.getShaderInfoLog(vs));
		else
		{
			glProgram = gl.createProgram();

			gl.attachShader(glProgram, vs);
			gl.attachShader(glProgram, fs);
			
			gl.deleteShader(vs);
			gl.deleteShader(fs);
			
			buffer.bindAttribLocations(gl, glProgram);
		
			gl.linkProgram(glProgram);

			if (gl.getProgramParameter(glProgram, gl.LINK_STATUS) == 0) // glsl compile error
			{
				trace(gl.getProgramInfoLog(glProgram)
					+ "VALIDATE_STATUS: " + gl.getProgramParameter(glProgram, gl.VALIDATE_STATUS)
					+ "ERROR: " + gl.getError()
				);
			}
			else
			{
				#if (peoteview_es3 && peoteview_uniformbuffers)
				display.peoteView.uniformBuffer.bindToProgram(gl, glProgram, "uboView", 0);
				display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
				#else
				uRESOLUTION = gl.getUniformLocation(glProgram, "uResolution");
				uOFFSET = gl.getUniformLocation(glProgram, "uOffset");
				#end
				
			}
		}

	}
	
	#if !(peoteview_es3 && peoteview_uniformbuffers)
	var uRESOLUTION:GLUniformLocation;
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
		peoteView.gl.uniform2f (uOFFSET, display.xOffset+display.x, display.yOffset+display.y);
		// TODO: from Program
		#end
		
		buffer.render(peoteView, display, this);
		peoteView.gl.useProgram (null);
	}
	
}