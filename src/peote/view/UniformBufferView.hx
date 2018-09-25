package peote.view;

import haxe.io.Bytes;

import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLBuffer;
import peote.view.PeoteGL.DataPointer;
import peote.view.PeoteGL.BytePointer;

class UniformBufferView 
{

	var resolutionDataPointer: DataPointer;
	var xOffestDataPointer: DataPointer;
	var yOffestDataPointer: DataPointer;
	var zoomDataPointer: DataPointer;

	public var block:Int;
	public var uniformBuffer:GLBuffer;
	
	var uniformBytes:Bytes;
	
	public function new() 
	{
		//uniformBytes = Bytes.alloc(5 * 4);
		uniformBytes = Bytes.alloc(3 * 4*4); // alignment to vec4 (3 values)
		resolutionDataPointer = new BytePointer(uniformBytes, 0);
		xOffestDataPointer = new BytePointer(uniformBytes, 8);
		yOffestDataPointer = new BytePointer(uniformBytes, 12);
		zoomDataPointer    = new BytePointer(uniformBytes, 16);
	}
	
	public inline function updateResolution(gl:PeoteGL, width:Float, height:Float) {
		uniformBytes.setFloat(0, width);
		uniformBytes.setFloat(4, height);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 0, 8, resolutionDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public inline function updateXOffset(gl:PeoteGL, xOffset:Float) {
		uniformBytes.setFloat(8, xOffset);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 4, xOffestDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateYOffset(gl:PeoteGL, yOffset:Float) {
		uniformBytes.setFloat(12, yOffset);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 12, 4, yOffestDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public inline function updateZoom(gl:PeoteGL, zoom:Float) {
		uniformBytes.setFloat(16, zoom);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 16, 4, zoomDataPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public function createGLBuffer(gl:PeoteGL, width:Float, height:Float, xOffest:Float, yOffest:Float, zoom:Float)
	{
		uniformBuffer = gl.createBuffer();
		uniformBytes.setFloat(0,  width);
		uniformBytes.setFloat(4,  height);
		uniformBytes.setFloat(8,  xOffest);
		uniformBytes.setFloat(12, yOffest);
		uniformBytes.setFloat(16, zoom);
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