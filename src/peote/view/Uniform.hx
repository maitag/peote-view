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
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform1f(loc, value);
}

/**
	Set up a custom integer uniform that can be accessed within glsl shadercode.
**/
class UniformInt implements Uniform
{
	/**The value to change at runtime**/
	public var value:Int;

	/**
		Creates a new `UniformInt` instance.
		@param value initial value
	**/
	public inline function new(value:Int) this.value = value;

	inline function glslType() return "int";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform1i(loc, value);
}

/**
	Set up a custom unsigned integer uniform that can be accessed within glsl shadercode.
**/
class UniformUInt implements Uniform
{
	/**The value to change at runtime**/
	public var value:UInt;

	/**
		Creates a new `UniformUInt` instance.
		@param value initial value
	**/
	public inline function new(value:UInt) this.value = value;

	// opengl-ES2 not supports uniform1ui, so fallback to uniform1i
	inline function glslType() return PeoteGL.Version.isES3 ? "uint" : "int";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) if (PeoteGL.Version.isES3) gl.uniform1ui(loc, value) else gl.uniform1i(loc, value);
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

// float vectors
typedef UniformVec2 = UniformT<Vec2>;
typedef UniformVec3 = UniformT<Vec3>;
typedef UniformVec4 = UniformT<Vec4>;

// integer vectors
typedef UniformVec2i = UniformT<Vec2i>;
typedef UniformVec3i = UniformT<Vec3i>;
typedef UniformVec4i = UniformT<Vec4i>;

// unsigned integer vectors
// typedef UniformVec4ui = UniformT<Vec4ui>;

// TODO:
// float matrix