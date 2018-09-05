package peote.view.utils;

import haxe.io.Bytes;
import peote.view.PeoteGL;
import peote.view.PeoteGL.GLBuffer;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.DataPointer;


class UniformBuffer 
{
	var dataPointer: DataPointer;
	
	var uProgramBytes:Bytes;
	
	var uProgramIndex:Int;
	var uProgramBuffer:GLBuffer;

	public function new(gl:PeoteGL, glProgram:GLProgram) 
	{
		uProgramIndex = gl.getUniformBlockIndex(glProgram, 'UProgram');
		gl.uniformBlockBinding(glProgram, uProgramIndex, 0);
		
		uProgramBuffer = gl.createBuffer();
		
		uProgramBytes = Bytes.alloc(2 * 4);
		uProgramBytes.setFloat(0, 800);
		uProgramBytes.setFloat(4, 600);
		
		gl.bindBuffer(gl.UNIFORM_BUFFER, uProgramBuffer);
		gl.bufferData(gl.UNIFORM_BUFFER, uProgramBytes.length, uProgramBytes, gl.STATIC_DRAW);
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
}