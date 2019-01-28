package peote.view;

import haxe.io.Bytes;

import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLBuffer;
import peote.view.PeoteGL.DataPointer;
import peote.view.PeoteGL.BytePointer;

class UniformBufferDisplay
{
	var xOffestDataPointer: DataPointer;
	var yOffestDataPointer: DataPointer;
	var xZoomDataPointer: DataPointer;
	var yZoomDataPointer: DataPointer;
	
	public var block:Int;
	public var uniformBuffer:GLBuffer;
	
	var uniformBytes:Bytes;
	

	public function new() 
	{
		//uniformBytes = Bytes.alloc(3 * 4);
		uniformBytes = Bytes.alloc(2 * 4*4);  // alignment to vec4 (2 values)
		xOffestDataPointer  = new BytePointer(uniformBytes, 0);
		yOffestDataPointer  = new BytePointer(uniformBytes, 4);
		xZoomDataPointer    = new BytePointer(uniformBytes, 8);
		yZoomDataPointer    = new BytePointer(uniformBytes, 12);
	}
	
	public inline function updateXOffset(gl:PeoteGL, xo:Float) {
		if (gl != null) {
			uniformBytes.setFloat(0, xo);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 0, 4, xOffestDataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateYOffset(gl:PeoteGL, yo:Float) {
		if (gl != null) {
			uniformBytes.setFloat(4, yo);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 4, 4, yOffestDataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateZoom(gl:PeoteGL, xz:Float, yz:Float) {
		uniformBytes.setFloat(8,  xz);
		uniformBytes.setFloat(12, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 8, xZoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateXZoom(gl:PeoteGL, xz:Float) {
		uniformBytes.setFloat(8, xz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 4, xZoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateYZoom(gl:PeoteGL, yz:Float) {
		uniformBytes.setFloat(12, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 12, 4, yZoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public function createGLBuffer(gl:PeoteGL, xOffest:Float, yOffest:Float, xz:Float, yz:Float)
	{
		uniformBuffer = gl.createBuffer();
		uniformBytes.setFloat(0,  xOffest);
		uniformBytes.setFloat(4,  yOffest);
		uniformBytes.setFloat(8,  xz);
		uniformBytes.setFloat(12, yz);
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
			//trace('has uniform $name, index=$index, block=$block');
			gl.uniformBlockBinding(glProgram, index, block);
		}
	}
	

	
}