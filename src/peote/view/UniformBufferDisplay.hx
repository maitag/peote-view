package peote.view;

import peote.view.PeoteGL.GLProgram;

class UniformBufferDisplay
{
	var xOffestdataPointer: lime.utils.DataPointer;
	var yOffsetdataPointer: lime.utils.DataPointer;
	
	public var block:Int;
	public var uniformBuffer:lime.graphics.opengl.GLBuffer;
	
	var uniformBytes:haxe.io.Bytes;
	

	public function new() 
	{
		uniformBytes = haxe.io.Bytes.alloc(2 * 4);
		xOffestdataPointer = new lime.utils.BytePointer(uniformBytes, 0);
		yOffsetdataPointer = new lime.utils.BytePointer(uniformBytes, 4);
	}
	
	public inline function updateXOffset(gl:PeoteGL, offset:Int) {
		if (gl != null) {
			uniformBytes.setFloat(0, offset);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 0, 4, xOffestdataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateYOffset(gl:PeoteGL, offset:Int) {
		if (gl != null) {
			uniformBytes.setFloat(4, offset);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 4, 4, yOffsetdataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public function createGLBuffer(gl:PeoteGL, xOffest:Int, yOffest:Int)
	{
		uniformBuffer = gl.createBuffer();
		uniformBytes.setFloat(0, xOffest);
		uniformBytes.setFloat(4, yOffest);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferData(gl.UNIFORM_BUFFER, uniformBytes.length, uniformBytes, gl.STATIC_DRAW);
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public function deleteGLBuffer(gl:PeoteGL)
	{
		gl.deleteBuffer(uniformBuffer);
	}
	
	public function bindToProgram(gl:PeoteGL, glProgram:GLProgram, name:String, block:Int) {
		this.block = block;
		var index:Int = gl.getUniformBlockIndex(glProgram, name);
		if (index != gl.INVALID_INDEX) {
			trace('has uniform $name, index=$index, block=$block');
			gl.uniformBlockBinding(glProgram, index, block);
		}
	}
	

	
}