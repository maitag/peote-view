package peote.view;

import peote.view.PeoteGL.GLUniformLocation;
import peote.view.math.*;

/**
	Interface to handle multiple uniform types by an Array.
**/
@:allow(peote.view.Program)
interface Uniform {
	private function glslType():String;
	private function updateGL(gl:PeoteGL, loc:GLUniformLocation):Void;
}

/**
	Set up a custom float uniform that can be accessed within glsl shadercode.
**/
class UniformFloat implements Uniform
{
	/**The value to change at runtime**/
	public var value:Float;

	/**
		Creates a new `UniformFloat` instance.
		@param value initial value
	**/
	public inline function new(value:Float) this.value = value;

	inline function glslType() return "float";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform1f (loc, value);
}

@:generic
private class UniformT<T:Uniform> implements Uniform
{
	/**The value to change at runtime**/
	public var value:T;

	/**
		Creates a new T:Uniform instance of the expected type.
		@param value initial value of type T:Uniform
	**/
	public inline function new(value:T) this.value = value;

	inline function glslType():String return value.glslType();
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) value.updateGL(gl, loc);
}

typedef UniformVec2 = UniformT<Vec2>;
// typedef UniformVec3 = UniformT<Vec3>;
// typedef UniformVec4 = UniformT<Vec4>;

// ok ... now we can --> S P A W N :
// more here (^_^)
