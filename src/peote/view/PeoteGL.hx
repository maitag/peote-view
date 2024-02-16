package peote.view;

import haxe.io.Bytes;
import haxe.io.UInt8Array;
import haxe.io.Int32Array;
import haxe.io.Float32Array;

import lime.utils.DataPointer;
import peote.view.intern.BufferBytes;
import peote.view.intern.GLBufferPointer;

typedef GLTexture           = lime.graphics.opengl.GLTexture;
typedef GLFramebuffer       = lime.graphics.opengl.GLFramebuffer;                    
typedef GLProgram           = lime.graphics.opengl.GLProgram;
typedef GLShader            = lime.graphics.opengl.GLShader;
typedef GLUniformLocation   = lime.graphics.opengl.GLUniformLocation;
typedef GLBuffer            = lime.graphics.opengl.GLBuffer;
typedef GLVertexArrayObject = lime.graphics.opengl.GLVertexArrayObject;
typedef GLRenderbuffer      = lime.graphics.opengl.GLRenderbuffer;

//typedef Image = lime.graphics.Image;

/*
#if html5
	#if peoteview_es3
		typedef LimeGLRenderContext = lime.graphics.WebGL2RenderContext;
	#elseif peoteview_es2
		typedef LimeGLRenderContext = lime.graphics.WebGLRenderContext;
	#else
		typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext; // Dynamic
	#end
#else
	#if peoteview_es3
		typedef LimeGLRenderContext = lime.graphics.OpenGLES3RenderContext;
	#elseif peoteview_es2
		typedef LimeGLRenderContext = lime.graphics.OpenGLES2RenderContext;
	#else
		typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext;
	#end
#end
*/
typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext;

@:forward()
abstract PeoteGL(LimeGLRenderContext) from LimeGLRenderContext to LimeGLRenderContext {
	#if html5
		public inline function bufferData (target:Int, size:Int, srcData:GLBufferPointer, usage:Int):Void {
			this.bufferData (target, srcData, usage);
		}
		
		public inline function bufferSubData (target:Int, offset:Int, size:Int, srcData:GLBufferPointer):Void {
			//this.bufferSubData (target, offset, srcData, srcData.byteOffset, size);
			this.bufferSubData (target, offset, srcData);
		}
		
		public inline function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, data:Dynamic):Void {
			if (data == 0)
			     this.texImage2D(target, level, internalformat, width, height, border, format, type, null);
			else this.texImage2D(target, level, internalformat, width, height, border, format, type, data);
		}
		
		public inline function texSubImage2D (target:Int, level:Int, x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, data:UInt8Array):Void {
			this.texSubImage2D(target, level, x, y, width, height, format, type, data);
		}
		public inline function texSubImage2D_Float (target:Int, level:Int, x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, data:Float32Array):Void {
			this.texSubImage2D(target, level, x, y, width, height, format, type, data);
		}
		
		public inline function readPixels(x:Int, y:Int, w:Int, h:Int, format:Int, type:Int, data:UInt8Array):Void {
			this.readPixels(x, y, w, h, format, type, data);
		}
		public inline function readPixels_Int32(x:Int, y:Int, w:Int, h:Int, format:Int, type:Int, data:Int32Array):Void {
			this.readPixels(x, y, w, h, format, type, data);
		}
		public inline function readPixels_Float32(x:Int, y:Int, w:Int, h:Int, format:Int, type:Int, data:Float32Array):Void {
			this.readPixels(x, y, w, h, format, type, data);
		}
		
	#else
		public inline function texSubImage2D(target:Int, level:Int, x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, data:UInt8Array):Void {
			this.texSubImage2D(target, level, x, y, width, height, format, type, data.view.buffer);
		}
		public inline function texSubImage2D_Float(target:Int, level:Int, x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, data:Float32Array):Void {
			this.texSubImage2D(target, level, x, y, width, height, format, type, data.view.buffer);
		}
				
		public inline function readPixels(x:Int, y:Int, w:Int, h:Int, format:Int, type:Int, data:UInt8Array):Void {
			this.readPixels(x, y, w, h, format, type, data.view.buffer);
		}
		public inline function readPixels_Int32(x:Int, y:Int, w:Int, h:Int, format:Int, type:Int, data:Int32Array):Void {
			this.readPixels(x, y, w, h, format, type, data.view.buffer);
		}
		public inline function readPixels_Float32(x:Int, y:Int, w:Int, h:Int, format:Int, type:Int, data:Float32Array):Void {
			this.readPixels(x, y, w, h, format, type, data.view.buffer);
		}
		
	/*
		#if peoteview_es2
			public inline function getShaderParameter (shader:GLShader, name:Int):Dynamic {
				return this.getShaderi (shader, name);
			}
			
			public inline function getProgramParameter (program:GLProgram, name:Int):Dynamic {
				return this.getProgrami (program, name);
			}
		#end
	*/
	#end

	// -------------------------------------------------------------------------------------------------
	// ---------------------------- downcasting the gl render context ----------------------------------

	@:from private static function fromRenderContext (context:lime.graphics.RenderContext):PeoteGL {

		#if html5
		
			#if peoteview_es3
				if (context.webgl2 == null) js.Browser.alert("Sorry, only works on Webbrowsers that supports WEBGL2 (OpenGL-ES3).");
				trace("Force WEBGL2.");
				return cast context.webgl2;
			#elseif peoteview_es2
				if (context.webgl == null) js.Browser.alert("Sorry, only works on Webbrowsers that supports WEBGL1 (OpenGL-ES2).");
				trace("Force WEBGL1.");
				return cast context.webgl;
			#else
				if (context.webgl2 != null) {
					trace("WEBGL2 detected.");
					Version.isES3 = true;
					return cast context.webgl2;
				}
				else if (context.webgl != null) {
					trace("WEBGL1 detected.");
					return cast context.webgl;
				}
				else {
					js.Browser.alert("Error: missing webgl context");
					return null;
				}
			#end				
			
		#else
			#if peoteview_es3
				if (context.gles3 == null) throw("Sorry, only works with OpenGL-ES3.");
				trace("Force OpenGL-ES3.");
				return cast context.gles3;
			#elseif peoteview_es2
				if (context.gles2 == null) throw("Sorry, only works with OpenGL-ES2.");
				trace("Force OpenGL-ES2.");
				return cast context.gles2;
			#else
				if (context.gles3 != null) {
					trace("OpenGL-ES3 detected.");
					Version.isES3 = true;
					return cast context.gles3;
				}
				else if (context.gles2 != null) {
					trace("OpenGL-ES2 detected.");
					return cast context.gles2;
				}
				else if (context.gl != null) {
					trace("OpenGL detected.");
					return cast context.gl;
				}
				else throw("Error: missing OpenGL context");
			#end
			
		#end
	}



}

@:allow(peote.view)
class Version {
	#if peoteview_es3
	
		static inline public var isES3 = true; // force compiling without runtimecheck for UBOs/InstanceDrawing

		#if peoteview_uniformbuffers
			static inline var isUBO = true;
		#else 
			static inline var isUBO = false;
		#end
		#if peoteview_instancedrawing
			static inline var isINSTANCED = true;
		#else 
			static inline var isINSTANCED = false;
		#end
		#if peoteview_vertexarrayobjects
			static inline var isVAO = true;
		#else 
			static inline var isVAO = false;
		#end
		
	#elseif peoteview_es2  // force compiling without runtimecheck for UBOs/InstanceDrawing
	
		static inline public var isES3 = false;
		static inline var isUBO = false;
		static inline var isINSTANCED = false;
		static inline var isVAO = false;
		
	#else // check at runtime (depends on available es-version) 

		static public var isES3(default, set) = false;		// <---- set this true if detected gl-Version is es3
		static inline function set_isES3(b:Bool):Bool {
			#if peoteview_uniformbuffers
				isUBO = b;
			#end
			#if peoteview_instancedrawing
				isINSTANCED = b;
			#end
			#if peoteview_vertexarrayobjects
				isVAO = b;
			#end
			return isES3 = b;
		}
		
		#if peoteview_uniformbuffers
			static var isUBO = false; // is set at runtime throught isES3
		#else
			static inline var isUBO = false; // force compiling without runtimecheck for UBOs
		#end
		#if peoteview_instancedrawing
			static var isINSTANCED = false;  // is set at runtime throught isES3
		#else
			static inline var isINSTANCED = false; // force compiling without runtimecheck for InstanceDrawing
		#end
		#if peoteview_vertexarrayobjects
			static var isVAO = false;  // is set at runtime throught isES3
		#else
			static inline var isVAO = false; // force compiling without runtimecheck for vertex array objects
		#end
		
	#end	
}

@:allow(peote.view)
class Precision {
	static var VertexFloat    :PrecType = {high:0, medium:0, low:0};
	static var VertexInt      :PrecType = {high:0, medium:0, low:0};
	static var VertexSampler  :PrecType = {high:0, medium:0, low:0};
	static var FragmentFloat  :PrecType = {high:0, medium:0, low:0};
	static var FragmentInt    :PrecType = {high:0, medium:0, low:0};
	static var FragmentSampler:PrecType = {high:0, medium:0, low:0};
	
	static public inline function _init(gl:PeoteGL, shaderType:Int, t:PrecType) {
		var p = gl.getShaderPrecisionFormat(shaderType, gl.HIGH_FLOAT);
		if (p != null) t.high = p.precision;
		p = gl.getShaderPrecisionFormat(shaderType, gl.MEDIUM_FLOAT);
		if (p != null) t.medium = p.precision;
		p = gl.getShaderPrecisionFormat(shaderType, gl.LOW_FLOAT);
		if (p != null) t.low = p.precision;
	}
	
	static public inline function init(gl:PeoteGL) {
		_init(gl, gl.VERTEX_SHADER, VertexFloat);
		_init(gl, gl.VERTEX_SHADER, VertexInt);
		_init(gl, gl.VERTEX_SHADER, VertexSampler);
		_init(gl, gl.FRAGMENT_SHADER, FragmentFloat);
		_init(gl, gl.FRAGMENT_SHADER, FragmentInt);
		_init(gl, gl.FRAGMENT_SHADER, FragmentSampler);
	}
	
	static public inline function highest(t:PrecType, p:Null<String>):Null<String> {
		if (p == null) return null;
		if (t.high > 0 && p == "highp") return "highp";
		else if (t.medium > 0 && (p == "highp" || p == "mediump")) return "mediump";
		else if (t.low > 0) return "lowp";
		else return null;
	}
	static public inline function availVertexFloat(precision:Null<String>):Null<String> return highest(VertexFloat, precision);
	static public inline function availVertexInt(precision:Null<String>):Null<String> return highest(VertexInt, precision);
	static public inline function availVertexSampler(precision:Null<String>):Null<String> return highest(VertexSampler, precision);
	static public inline function availFragmentFloat(precision:Null<String>):Null<String> return highest(FragmentFloat, precision);
	static public inline function availFragmentInt(precision:Null<String>):Null<String> return highest(FragmentInt, precision);
	static public inline function availFragmentSampler(precision:Null<String>):Null<String> return highest(FragmentSampler, precision);
}

typedef PrecType = {high:Int, medium:Int, low:Int};
