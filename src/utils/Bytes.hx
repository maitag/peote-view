package utils;

import haxe.io.BytesData;
import haxe.io.Error;
import haxe.Int64;

#if (!js)
typedef Bytes = haxe.io.Bytes;
#else

#if !nodejs
#if (haxe_ver < 4.0)
import js.html.compat.Uint8Array;
import js.html.compat.DataView;
#end
#end

#if !macro
@:autoBuild(lime._internal.macros.AssetsMacro.embedBytes()) // Enable @:bytes embed metadata
#end
class Bytes extends haxe.io.Bytes {
	var b_UFloat32 : js.html.Float32Array;
	var b_Int32    : js.html.Int32Array;
	var b_Uint16   : js.html.Uint16Array;
	
	function new(data:BytesData) {
		super(data);
		this.b_UFloat32 = new js.html.Float32Array(data);
		this.b_Int32    = new js.html.Int32Array(data);
		this.b_Uint16   = new js.html.Uint16Array(data);
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

	public static function ofString( s : String ) : Bytes {
		var a = new Array();
		// utf16-decode and utf8-encode
		var i = 0;
		while( i < s.length ) {
			var c : Int = StringTools.fastCodeAt(s,i++);
			// surrogate pair
			if( 0xD800 <= c && c <= 0xDBFF )
			    c = (c - 0xD7C0 << 10) | (StringTools.fastCodeAt(s,i++) & 0x3FF);
			if( c <= 0x7F )
				a.push(c);
			else if( c <= 0x7FF ) {
				a.push( 0xC0 | (c >> 6) );
				a.push( 0x80 | (c & 63) );
			} else if( c <= 0xFFFF ) {
				a.push( 0xE0 | (c >> 12) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			} else {
				a.push( 0xF0 | (c >> 18) );
				a.push( 0x80 | ((c >> 12) & 63) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			}
		}
		return new Bytes(new js.html.Uint8Array(a).buffer);
	}

	public static function ofData( b : BytesData ) : Bytes {
		var hb = untyped b.hxBytes;
		if( hb != null ) return hb;
		return new Bytes(b);
	}

}
/*
class LimeJSBytes {

	#if lime_bytes_length_getter
	public var length(get,set) : Int;
	var l : Int;
	#else
	public var length(default,null) : Int;
	#end
	var b : js.html.Uint8Array;
	var data : js.html.DataView;

	function new(data:BytesData) {
		this.length = data.byteLength;
		this.b = new js.html.Uint8Array(data);
		untyped {
			b.bufferValue = data; // some impl does not return the same instance in .buffer
			data.hxBytes = this;
			data.bytes = this.b;
		}
	}

	public inline function get( pos : Int ) : Int {
		return b[pos];
	}

	public inline function set( pos : Int, v : Int ) : Void {
		b[pos] = v & 0xFF; // the &0xFF is necessary for js.html.compat support
	}

	public function blit( pos : Int, src : Bytes, srcpos : Int, len : Int ) : Void {
		if( pos < 0 || srcpos < 0 || len < 0 || pos + len > length || srcpos + len > src.length ) throw Error.OutsideBounds;
		if( srcpos == 0 && len == src.b.byteLength )
			b.set(src.b,pos);
		else
			b.set(src.b.subarray(srcpos,srcpos+len),pos);
	}

	public function fill( pos : Int, len : Int, value : Int ) : Void {
		for( i in 0...len )
			set(pos++, value);
	}

	public function sub( pos : Int, len : Int ) : Bytes {
		if( pos < 0 || len < 0 || pos + len > length ) throw Error.OutsideBounds;
		return new Bytes(b.buffer.slice(pos+b.byteOffset,pos+b.byteOffset+len));
	}

	public function compare( other : Bytes ) : Int {
		var b1 = b;
		var b2 = other.b;
		var len = (length < other.length) ? length : other.length;
		for( i in 0...len )
			if( b1[i] != b2[i] )
				return b1[i] - b2[i];
		return length - other.length;
	}

	inline function initData() : Void {
		if( data == null ) data = new js.html.DataView(b.buffer, b.byteOffset, b.byteLength);
	}

	public function getDouble( pos : Int ) : Float {
		initData();
		return data.getFloat64(pos, true);
	}

	public function getFloat( pos : Int ) : Float {
		initData();
		return data.getFloat32(pos, true);
	}

	public function setDouble( pos : Int, v : Float ) : Void {
		initData();
		data.setFloat64(pos, v, true);
	}

	public function setFloat( pos : Int, v : Float ) : Void {
		initData();
		data.setFloat32(pos, v, true);
	}

	public function getUInt16( pos : Int ) : Int {
		initData();
		return data.getUint16(pos, true);
	}

	public function setUInt16( pos : Int, v : Int ) : Void {
		initData();
		data.setUint16(pos, v, true);
	}

	public function getInt32( pos : Int ) : Int {
		initData();
		return data.getInt32(pos, true);
	}

	public function setInt32( pos : Int, v : Int ) : Void {
		initData();
		data.setInt32(pos, v, true);
	}

	public function getInt64( pos : Int ) : Int64 {
		return Int64.make(getInt32(pos + 4),getInt32(pos));
	}

	public function setInt64( pos : Int, v : haxe.Int64 ) : Void {
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String {
		if( pos < 0 || len < 0 || pos + len > length ) throw Error.OutsideBounds;
		var s = "";
		var b = b;
		var fcc = String.fromCharCode;
		var i = pos;
		var max = pos+len;
		// utf8-decode and utf16-encode
		while( i < max ) {
			var c = b[i++];
			if( c < 0x80 ) {
				if( c == 0 ) break;
				s += fcc(c);
			} else if( c < 0xE0 )
				s += fcc( ((c & 0x3F) << 6) | (b[i++] & 0x7F) );
			else if( c < 0xF0 ) {
				var c2 = b[i++];
				s += fcc( ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | (b[i++] & 0x7F) );
			} else {
				var c2 = b[i++];
				var c3 = b[i++];
				var u = ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 & 0x7F) << 6) | (b[i++] & 0x7F);
				// surrogate pair
				s += fcc( (u >> 10) + 0xD7C0 );
				s += fcc( (u & 0x3FF) | 0xDC00 );
			}
		}
		return s;
	}

	@:deprecated("readString is deprecated, use getString instead")
	@:noCompletion
	public inline function readString(pos:Int, len:Int):String {
		return getString(pos, len);
	}

	public function toString() : String {
		return getString(0,length);
	}

	public function toHex() : String {
		var s = new StringBuf();
		var chars = [];
		var str = "0123456789abcdef";
		for( i in 0...str.length )
			chars.push(str.charCodeAt(i));
		for( i in 0...length ) {
			var c = get(i);
			s.addChar(chars[c >> 4]);
			s.addChar(chars[c & 15]);
		}
		return s.toString();
	}

	public inline function getData() : BytesData {
		return untyped b.bufferValue;
	}

	public static inline function alloc( length : Int ) : Bytes {
		return new Bytes(new BytesData(length));
	}

	public static function ofString( s : String ) : Bytes {
		var a = new Array();
		// utf16-decode and utf8-encode
		var i = 0;
		while( i < s.length ) {
			var c : Int = StringTools.fastCodeAt(s,i++);
			// surrogate pair
			if( 0xD800 <= c && c <= 0xDBFF )
			    c = (c - 0xD7C0 << 10) | (StringTools.fastCodeAt(s,i++) & 0x3FF);
			if( c <= 0x7F )
				a.push(c);
			else if( c <= 0x7FF ) {
				a.push( 0xC0 | (c >> 6) );
				a.push( 0x80 | (c & 63) );
			} else if( c <= 0xFFFF ) {
				a.push( 0xE0 | (c >> 12) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			} else {
				a.push( 0xF0 | (c >> 18) );
				a.push( 0x80 | ((c >> 12) & 63) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			}
		}
		return new Bytes(new js.html.Uint8Array(a).buffer);
	}

	public static function ofData( b : BytesData ) : Bytes {
		var hb = untyped b.hxBytes;
		if( hb != null ) return hb;
		return new Bytes(b);
	}

	public inline static function fastGet( b : BytesData, pos : Int ) : Int {
		// this requires that we have wrapped it with haxe.io.Bytes beforehand
		return untyped b.bytes[pos];
	}

	#if lime_bytes_length_getter
	private function get_length() : Int {
		return l;
	}

	private function set_length( v : Int ) : Int {
		return l = v;
	}
	#end

}
*/

#end