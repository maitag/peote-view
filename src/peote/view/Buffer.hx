package peote.view;

#if !macro
@:genericBuild(peote.view.Buffer.BufferMacro.build())
class Buffer<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class BufferMacro
{
	public static var cache = new Map<String, Bool>();
	
	static public function build()
	{	
		switch (Context.getLocalType()) {
			case TInst(_, [t]):
				switch (t) {
					case TInst(n, []):
						//trace("interfaces:"+n.get().interfaces);   // TODO: check that super-class implements Element!
						return buildClass("Buffer", n.get().name, n.get().pack, TypeTools.toComplexType(t) );
					case t: Context.error("Class expected", Context.currentPos());
				}
			case t: Context.error("Class expected", Context.currentPos());
		}
		return null;
	}
	
	static public function buildClass(className:String, elementName:String, elementPack:Array<String>, elementType:ComplexType):ComplexType
	{		
		className += "_" + elementName;
		var classPackage = Context.getLocalClass().get().pack;

		if (!cache.exists(className))
		{
			cache[className] = true;
			var elemField = elementPack.concat([elementName]);
			
			
			trace("ClassName:"+className); // Program_ElementSimple
			trace("classPackage:" + classPackage); // [peote,view]	
			trace("ElementName:" + elementName);   // ElementSimple
			trace("ElementPackage:" + elementPack);// [elements]
			trace("ElementType:" + elementType); // TPath({ name => ElementSimple, pack => [elements], params => [] })
			
			trace('generating class: '+classPackage.concat([className]).join('.'));	

			var c = macro		
// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className implements BufferInterface
{
	var _gl: peote.view.PeoteGL = null;
	var _glBuffer: peote.view.PeoteGL.GLBuffer;
	var _glInstanceBuffer: peote.view.PeoteGL.GLBuffer = null;

	var _elements: haxe.ds.Vector<$elementType>; // var elements:Int; TAKE CARE if same name as package! -> TODO!!
	var _maxElements:Int = 0; // amount of added elements (pos of last element)
	
	// local bytes-buffer
	var _bytes: haxe.io.Bytes;
	
	#if peoteview_queueGLbuffering
	var updateGLBufferElementQueue:Array<$elementType>;
	var queueCreateGLBuffer:Bool = false;
	var queueDeleteGLBuffer:Bool = false;
	var queueUpdateGLBuffer:Bool = false;
	#end

	public function new(size:Int)
	{
		#if peoteview_queueGLbuffering
		updateGLBufferElementQueue = new Array<$elementType>();
		#end
		
		_elements = new haxe.ds.Vector<$elementType>(size);
		
		trace("create bytes for GLbuffer");
		var buffSize:Int = Std.int(size * $p{elemField}.BUFF_SIZE);
		_bytes = haxe.io.Bytes.alloc(buffSize);
		_bytes.fill(0, buffSize, 0);
		
		$p{elemField}.createInstanceBytes();
	}
	
	inline function createGLBuffer():Void
	{
		trace("create new GlBuffer");
		#if peoteview_queueGLbuffering
		queueCreateGLBuffer = true;
		#else
		_glBuffer         = _gl.createBuffer();
		_glInstanceBuffer = _gl.createBuffer();
		#end
	}
	
	inline function deleteGLBuffer():Void
	{
		trace("delete GlBuffer");
		#if peoteview_queueGLbuffering
		queueDeleteGLBuffer = true;
		#else
		_gl.deleteBuffer(_glBuffer);
		_gl.deleteBuffer(_glInstanceBuffer);
		#end
	}
	
	inline function updateGLBuffer():Void
	{
		trace("fill full GlBuffer", _bytes.length);
		#if peoteview_queueGLbuffering
		queueUpdateGLBuffer = true;
		#else
		_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
		_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, _bytes, _gl.STATIC_DRAW); // _gl.DYNAMIC_DRAW _gl.STREAM_DRAW
		_gl.bindBuffer (_gl.ARRAY_BUFFER, null);		
		$p{elemField}.updateInstanceGLBuffer(_gl, _glInstanceBuffer);
		#end
	}
	
	/**
        Updates all element-changes to the rendering process of this buffer.
    **/
	public function update():Void
	{
		updateGLBuffer();
	}
	
	/**
        Updates all changes of an element to the rendering process.
        @param  element Element instance to update
    **/
	public inline function updateElement(element: $elementType):Void
	{	
		trace("Buffer.updateElement at position" + element.bytePos);
		element.writeBytes(_bytes);
		#if peoteview_queueGLbuffering
		updateGLBufferElementQueue.push(element);
		#else
		if (_gl != null) element.updateGLBuffer(_gl, _glBuffer);
		#end
	}
	
	/**
        Adds an element to the buffer and renderers it.
        @param  element Element instance to add
    **/
	public function addElement(element: $elementType):Void
	{	
		if (element.bytePos == -1) {
			element.bytePos = _maxElements * $p{elemField}.BUFF_SIZE;
			element.dataPointer = new peote.view.PeoteGL.BytePointer(_bytes, element.bytePos);
			trace("Buffer.addElement", _maxElements, element.bytePos);
			_elements.set(_maxElements++, element);
			updateElement(element);		
		} 
		else throw("Error: Element is already inside Buffer");
	}
		
	/**
        Removes an element from the buffer so it did nor renderer anymore.
        @param  element Element instance to remove
    **/
	public function removeElement(element: $elementType):Void
	{
		if (element.bytePos != -1) {
			if (_maxElements > 1 && element.bytePos < (_maxElements-1) * $p{elemField}.BUFF_SIZE ) {
				trace("Buffer.removeElement", element.bytePos);
				var lastElement: $elementType = _elements.get(--_maxElements);
				lastElement.bytePos = element.bytePos;
				lastElement.dataPointer = new peote.view.PeoteGL.BytePointer(_bytes, element.bytePos);
				updateElement(lastElement);
				_elements.set( Std.int(  element.bytePos / $p{elemField}.BUFF_SIZE ), lastElement);
			}
			else _maxElements--;
			element.bytePos = -1;			
		}
		else throw("Error: Element is not inside Buffer");
	}
	
	private inline function getVertexShader():String
	{
		return $p{elemField}.vertexShader;
	}

	private inline function getFragmentShader():String
	{
		return $p{elemField}.fragmentShader;
	}

	private inline function bindAttribLocations(gl: peote.view.PeoteGL, glProgram: peote.view.PeoteGL.GLProgram):Void
	{
		$p{elemField}.bindAttribLocations(gl, glProgram);
	}
	
	/**
        Gets the element at screen position.
        @param  program the program this buffer is bind to
    **/
	public function pickElementAt(x:Int, y:Int, program:peote.view.Program ): $elementType
	{
		//var elementNumber:Int = program.pickElementAt(x, y);
		//trace("---------PICKED elementNumber:" + elementNumber);
		return null;//TODO
	}

	private inline function render(peoteView:PeoteView, display:Display, program:Program)
	{		
		//trace("        ---buffer.render---");
		#if peoteview_queueGLbuffering
		//TODO: a while loop but only a limited number at the same time
		if (updateGLBufferElementQueue.length > 0) updateGLBufferElementQueue.shift().updateGLBuffer(_gl, _glBuffer);
		if (queueCreateGLBuffer) { queueCreateGLBuffer = false;
			_glBuffer         = _gl.createBuffer();
			_glInstanceBuffer = _gl.createBuffer();
		}
		if (queueDeleteGLBuffer) { queueDeleteGLBuffer = false;
			_gl.deleteBuffer(_glBuffer);
			_gl.deleteBuffer(_glInstanceBuffer);
		}
		if (queueUpdateGLBuffer) { queueUpdateGLBuffer = false;
			_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
			_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, _bytes, _gl.STATIC_DRAW); // _gl.DYNAMIC_DRAW _gl.STREAM_DRAW
			_gl.bindBuffer (_gl.ARRAY_BUFFER, null);		
			$p{elemField}.updateInstanceGLBuffer(_gl, _glInstanceBuffer);
		}
		#end
		
		$p{elemField}.render(_maxElements, peoteView.gl, _glBuffer, _glInstanceBuffer);
	}

	
};



// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------			
			//Context.defineModule(classPackage.concat([className]).join('.'),[c],Context.getLocalImports());
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
			//Context.defineType(c);
		}	
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
