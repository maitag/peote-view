package peote.view.utils;

#if (neko || cpp) // ----------- neko, cpp

typedef BufferBytes = haxe.io.Bytes;


#elseif html5 // ------------------ javascript

import haxe.io.BytesData;

#if (haxe_ver < 4.0)
//import js.html.compat.Uint8Array; 
//import js.html.compat.DataView;
import js.html.Uint8Array; 
//import js.html.DataView; 
import js.html.Float32Array;
import js.html.Int32Array;
import js.html.Uint16Array;
#else
import js.lib.Uint8Array;
//import js.lib.DataView;
import js.lib.Float32Array;
import js.lib.Int32Array;
import js.lib.Uint16Array;
#end

class BufferBytes {
	
	public var length(default, null):Int;

	var b:Uint8Array;
	//var data:DataView;
	var b_UFloat32 : Float32Array;
	var b_Int32    : Int32Array;
	var b_Uint16   : Uint16Array;
	
	function new(data:BytesData) {
		this.length = data.byteLength;
		this.b = new Uint8Array(data);
		untyped
		{
			b.bufferValue = data; // some impl does not return the same instance in .buffer
			data.hxBytes = this;
			data.bytes = this.b;
		}
		this.b_UFloat32 = new Float32Array(data);
		this.b_Int32    = new Int32Array(data);
		this.b_Uint16   = new Uint16Array(data);
	}
	
	public inline function set(pos:Int, v:Int):Void {
		b[pos] = v;
		// for js.html.compat: b[pos] = v & 0xFF;
	}

	public inline function setFloat( pos : Int, v : Float ) : Void {
		b_UFloat32[pos >> 2] = v;
	}
	
	public inline function setInt32( pos : Int, v : Int ) : Void {
		b_Int32[pos >> 2] = v;
	}
	
	public inline function setUInt16( pos : Int, v : Int ) : Void {
		b_Uint16[pos >> 1] = v & 0xFFFF;
	}
	
	public function blit(pos:Int, src:BufferBytes, srcpos:Int, len:Int):Void {
		if (srcpos == 0 && len == src.b.byteLength) b.set(src.b, pos);
		else b.set(src.b.subarray(srcpos, srcpos + len), pos);
	}

	public function fill(pos:Int, len:Int, value:Int):Void {
		for (i in 0...len) set(pos++, value);
	}
	
	public inline function getData():BytesData {
		return untyped b.bufferValue;
	}
	
	public static inline function alloc(length:Int):BufferBytes {
		return new BufferBytes(new BytesData(length));
	}

}
#end
