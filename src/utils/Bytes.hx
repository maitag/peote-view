package utils;

#if (!js)
typedef Bytes = haxe.io.Bytes;
#else

import haxe.io.BytesData;

#if (haxe_ver < 4.0)
//import js.html.compat.Uint8Array; 
//import js.html.compat.DataView;
import js.html.Uint8Array; 
import js.html.Float32Array;
import js.html.Int32Array;
import js.html.Uint16Array;
#else
import js.lib.Uint8Array;
import js.lib.Float32Array;
import js.lib.Int32Array;
import js.lib.Uint16Array;
#end

class Bytes extends haxe.io.Bytes {
	var b_UFloat32 : Float32Array;
	var b_Int32    : Int32Array;
	var b_Uint16   : Uint16Array;
	
	function new(data:BytesData) {
		super(data);
		this.b_UFloat32 = new Float32Array(data);
		this.b_Int32    = new Int32Array(data);
		this.b_Uint16   = new Uint16Array(data);
	}
	
	override public function setFloat( pos : Int, v : Float ) : Void {
		b_UFloat32[pos >> 2] = v;
	}
	
	override public function setInt32( pos : Int, v : Int ) : Void {
		b_Int32[pos >> 2] = v;
	}
	
	override public function setUInt16( pos : Int, v : Int ) : Void {
		b_Uint16[pos >> 1] = v & 0xFFFF;
	}
	
	// static function to do same like in Limes haxe.io.Bytes ---------------------------------
	
	public static inline function alloc( length : Int ) : Bytes {
		return new Bytes(new BytesData(length));
	}

}
#end
