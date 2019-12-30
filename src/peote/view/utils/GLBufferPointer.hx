package peote.view.utils;

import peote.view.utils.BufferBytes;

// to wrap around cpp Pointer and cffi Datapointer of Lime

#if (!html5)

	import lime.utils.DataPointer;
	import lime.utils.BytePointer;

	@:forward()
	abstract GLBufferPointer(DataPointer) from DataPointer to DataPointer
	{	
		public inline function new(bytes:BufferBytes, offset:Int=0, size:Int=0):Void
		{
			this = new BytePointer(bytes, offset);
		}	
	}


#else  // HTML 5 ---------------------------------------------

	#if (haxe_ver < 4.0)
	import js.html.Uint8Array;
	#else
	import js.lib.Uint8Array;
	#end

	@:forward()
	abstract GLBufferPointer(Uint8Array) from Uint8Array to Uint8Array
	{
		public inline function new(bytes:BufferBytes, offset:Int=0, size:Int=0):Void
		{
			if (size > 0)
				this = new Uint8Array(bytes.getData(), offset, size);
			else
				this = new Uint8Array(bytes.getData(), offset);
		}	
	}


#end