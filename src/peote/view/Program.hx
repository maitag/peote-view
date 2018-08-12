package peote.view;

import haxe.io.Bytes;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;

@:allow(peote.view)
class Program 
{
	var gl:PeoteGL = null; // TODO: multiple rendercontexts
	var glProgram:GLProgram = null;
	var buffer:BufferInterface;
	//var uniforms:Vector<GLUniformLocation>;
	
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
		
		trace("new Program");
	}
	
	public function addTexture(texture:Texture) 
	{
		
	}
	
	public function removeTexture(texture:Texture) 
	{
		
	}
	
	function compile():Void
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
				#if peoteview_ubo
				// ------------- uniform block -------------
				uProgramIndex = gl.getUniformBlockIndex(glProgram, 'UProgram');
				gl.uniformBlockBinding(glProgram, uProgramIndex, 0);
				
				uProgramBuffer = gl.createBuffer();
				
				uProgramBytes = Bytes.alloc(2 * 4);
				uProgramBytes.setFloat(0, 800);
				uProgramBytes.setFloat(4, 600);
				
				gl.bindBuffer(gl.UNIFORM_BUFFER, uProgramBuffer);
				gl.bufferData(gl.UNIFORM_BUFFER, uProgramBytes.length, uProgramBytes, gl.STATIC_DRAW);
				gl.bindBuffer(gl.UNIFORM_BUFFER, null);
				#else
				// ------------- uniforms location ---------
				uRESOLUTION = gl.getUniformLocation(glProgram, "uResolution");
				#end
				
			}
		}

	}
	
	#if peoteview_ubo
	var uProgramBytes:Bytes;
	var uProgramIndex:Int;
	var uProgramBuffer:GLBuffer;
	#else
	var uRESOLUTION:GLUniformLocation;
	#end
	
	private inline function render(peoteView:PeoteView, display:Display)
	{
		//trace("    ---program.render---");
		peoteView.gl.useProgram(glProgram); // ------ Shader Program
		
		#if peoteview_ubo
		// ------------- uniform block -------------
		//peoteView.gl.bindBufferRange(peoteView.gl.UNIFORM_BUFFER, 0, uProgramBuffer, 0, 8);
		peoteView.gl.bindBufferBase(peoteView.gl.UNIFORM_BUFFER, 0, uProgramBuffer);
		#else
		// ------------- simple uniform -------------
		peoteView.gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
		#end
		
		buffer.render(peoteView, display, this);
		peoteView.gl.useProgram (null);
	}
	
}