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
						//trace("interfaces:"+n.get().interfaces); // TODO: put out ERROR if super-class not implements Element!
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
					
			trace("ClassName:"+className); // Buffer_ElementSimple
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
	var _glVAO: peote.view.PeoteGL.GLVertexArrayObject = null;

	var _elements: haxe.ds.Vector<$elementType>; // var elements:Int; TAKE CARE if same name as package! -> TODO!!
	var _maxElements:Int = 0; // amount of added elements (pos of last element)
	var _elemBuffSize:Int;
	
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
		
		if (peote.view.PeoteGL.Version.isINSTANCED)
		{
			$p{elemField}.createInstanceBytes();
		    _elemBuffSize = $p{elemField}.BUFF_SIZE_INSTANCED;
		}
		else _elemBuffSize = $p{elemField}.BUFF_SIZE;
		
		trace("create bytes for GLbuffer");
		_bytes = haxe.io.Bytes.alloc(_elemBuffSize * size);
		_bytes.fill(0, _elemBuffSize * size, 0);		
	}
	
	inline function createGLBuffer():Void
	{
		#if peoteview_queueGLbuffering
		queueCreateGLBuffer = true;
		#else
		_createGLBuffer();
		#end
	}	
	inline function _createGLBuffer():Void
	{
		trace("create new GlBuffer");
		_glBuffer = _gl.createBuffer();
		if (peote.view.PeoteGL.Version.isINSTANCED) {
			_glInstanceBuffer = _gl.createBuffer();
			_glVAO = _gl.createVertexArray();
		}
	}
	
	inline function deleteGLBuffer():Void
	{
		#if peoteview_queueGLbuffering
		queueDeleteGLBuffer = true;
		#else
		_deleteGLBuffer();
		#end
	}
	
	inline function _deleteGLBuffer():Void
	{
		trace("delete GlBuffer");
		_gl.deleteBuffer(_glBuffer);
		if (peote.view.PeoteGL.Version.isINSTANCED) {
			_gl.deleteBuffer(_glInstanceBuffer);
			_gl.deleteVertexArray(_glVAO);
		}
	}
	
	inline function updateGLBuffer():Void
	{
		#if peoteview_queueGLbuffering
		queueUpdateGLBuffer = true;
		#else
		_updateGLBuffer();
		#end
	}
	
	inline function _updateGLBuffer():Void
	{
		trace("fill full GlBuffer", _bytes.length);
		_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
		_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, _bytes, _gl.STATIC_DRAW); // _gl.DYNAMIC_DRAW _gl.STREAM_DRAW
		_gl.bindBuffer (_gl.ARRAY_BUFFER, null);
		
		if (peote.view.PeoteGL.Version.isINSTANCED) {
			// instance buffer
			$p{elemField}.updateInstanceGLBuffer(_gl, _glInstanceBuffer);
			// init VAO 
			_gl.bindVertexArray(_glVAO);
			$p{elemField}.enableVertexAttribInstanced(_gl, _glBuffer, _glInstanceBuffer);
			_gl.bindVertexArray(null);
		}
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
		element.writeBytes(_bytes);
		#if peoteview_queueGLbuffering
		updateGLBufferElementQueue.push(element);
		#else
		_updateElement(element);
		#end
	}
	
	public inline function _updateElement(element: $elementType):Void
	{	
		trace("Buffer.updateElement at position" + element.bytePos);
		if (_gl != null) element.updateGLBuffer(_gl, _glBuffer, _elemBuffSize);
	}
	
	/**
        Adds an element to the buffer and renderers it.
        @param  element Element instance to add
    **/
	public function addElement(element: $elementType):Void
	{	
		if (element.bytePos == -1) {
			element.bytePos = _maxElements * _elemBuffSize;
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
			if (_maxElements > 1 && element.bytePos < (_maxElements-1) * _elemBuffSize ) {
				trace("Buffer.removeElement", element.bytePos);
				var lastElement: $elementType = _elements.get(--_maxElements);
				lastElement.bytePos = element.bytePos;
				lastElement.dataPointer = new peote.view.PeoteGL.BytePointer(_bytes, element.bytePos);
				updateElement(lastElement);
				_elements.set( Std.int(  element.bytePos / _elemBuffSize ), lastElement);
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
		//TODO: put all in one glCommandQueue (+ loop)
		if (updateGLBufferElementQueue.length > 0) _updateElement(updateGLBufferElementQueue.shift());
		if (queueCreateGLBuffer) {
			queueCreateGLBuffer = false;
			_createGLBuffer();
		}
		if (queueDeleteGLBuffer) {
			queueDeleteGLBuffer = false;
			_deleteGLBuffer();
		}
		if (queueUpdateGLBuffer) {
			queueUpdateGLBuffer = false;
			_updateGLBuffer();
		}
		#end
		
		if (peote.view.PeoteGL.Version.isINSTANCED) {
			// $p{elemField}.enableVertexAttribInstanced(_gl, _glBuffer, _glInstanceBuffer);
			_gl.bindVertexArray(_glVAO); // use VAO
			_gl.drawArraysInstanced (_gl.TRIANGLE_STRIP,  0, $p{elemField}.VERTEX_COUNT, _maxElements);
			_gl.bindVertexArray(null);
			// $p{elemField}.disableVertexAttrib(_gl); _gl.bindBuffer (_gl.ARRAY_BUFFER, null);
		} else {
			$p{elemField}.enableVertexAttrib(_gl, _glBuffer);
			_gl.drawArrays (_gl.TRIANGLE_STRIP,  0, _maxElements * $p{elemField}.VERTEX_COUNT);
			$p{elemField}.disableVertexAttrib(_gl);
			_gl.bindBuffer (_gl.ARRAY_BUFFER, null);
		}
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
