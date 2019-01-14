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
	var zoomDataPointer: DataPointer;
	
	public var block:Int;
	public var uniformBuffer:GLBuffer;
	
	var uniformBytes:Bytes;
	

	public function new() 
	{
		//uniformBytes = Bytes.alloc(3 * 4);
		uniformBytes = Bytes.alloc(2 * 4*4);  // alignment to vec4 (2 values)
		xOffestDataPointer    = new BytePointer(uniformBytes, 0);
		yOffestDataPointer    = new BytePointer(uniformBytes, 4);
		zoomDataPointer = new BytePointer(uniformBytes, 8);
		//xZoomDataPointer    = new BytePointer(uniformBytes, 8);
		//yZoomDataPointer    = new BytePointer(uniformBytes, 12);
	}
	
	public inline function updateXOffset(gl:PeoteGL, offset:Float) {
		if (gl != null) {
			uniformBytes.setFloat(0, offset);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 0, 4, xOffestDataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateYOffset(gl:PeoteGL, offset:Float) {
		if (gl != null) {
			uniformBytes.setFloat(4, offset);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 4, 4, yOffestDataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateZoom(gl:PeoteGL, zoom:Float) {
		if (gl != null) {
			uniformBytes.setFloat(8, zoom);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 4, zoomDataPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}
	/*
	public inline function updateZoom(gl:PeoteGL, xZoom:Float, yZoom:Float) {
		uniformBytes.setFloat(8, xZoom);
		uniformBytes.setFloat(12, yZoom);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 8, xZoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	public inline function updateXZoom(gl:PeoteGL, xZoom:Float) {
		uniformBytes.setFloat(8, xZoom);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 4, xZoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateYZoom(gl:PeoteGL, yZoom:Float) {
		uniformBytes.setFloat(12, yZoom);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 12, 4, yZoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	*/

	public function createGLBuffer(gl:PeoteGL, xOffest:Float, yOffest:Float, zoom:Float)
	{
		uniformBuffer = gl.createBuffer();
		uniformBytes.setFloat(0, xOffest);
		uniformBytes.setFloat(4, yOffest);
		uniformBytes.setFloat(8, zoom);
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