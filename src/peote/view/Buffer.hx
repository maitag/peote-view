package peote.view;

#if (!doc_gen)

#if !macro
@:genericBuild(peote.view.Buffer.BufferMacro.build())
class Buffer<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class BufferMacro
{
	static public function build()
	{	
		switch (Context.getLocalType()) {
			case TInst(_, [t]):
				switch (t) {
					case TInst(n, []):
						var g = n.get();
						var superName:String = null;
						var superModule:String = null;
						var s = g;
						while (s.superClass != null) {
							s = s.superClass.t.get(); //trace("->" + s.name);
							superName = s.name;
							superModule = s.module;
						}
						var missInterface = true;
						if (s.interfaces != null) for (i in s.interfaces) if (i.t.get().module == "peote.view.Element") missInterface = false;
						if (missInterface) throw Context.error('Error: Type parameter for buffer need to be generated by implementing "peote.view.Element"', Context.currentPos());
						
						return buildClass("Buffer",  g.pack, g.module, g.name, superModule, superName, TypeTools.toComplexType(t) );
					case t: Context.error("Class expected", Context.currentPos());
				}
			case t: Context.error("Class expected", Context.currentPos());
		}
		return null;
	}

	@:persistent static var generated = new Map<String, Bool>();

	static function isAlive(name:String):Bool {
		return try Context.getType(name) != null
			catch(s:String) {
				if (s != 'Type not found \'$name\'') throw(s);
				false;
			};
	}

	static public function buildClass(className:String, elementPack:Array<String>, elementModule:String, elementName:String, superModule:String, superName:String, elementType:ComplexType):ComplexType
	{		
		className += "_" + elementName;
		var classPackage = Context.getLocalClass().get().pack;
		
		var fullyQualifiedName:String = classPackage.concat([className]).join('.');
		
		var tp = TPath({ pack:classPackage, name:className, params:[] });
		if ( generated.exists(fullyQualifiedName)  &&  isAlive(fullyQualifiedName) ) return tp;

		generated.set(fullyQualifiedName, true);
			
		var elemField:Array<String>;
		if (superName == null) elemField = elementModule.split(".").concat([elementName]);
		else elemField = superModule.split(".").concat([superName]);
		
		#if peoteview_debug_macro
		trace('generating Class: ' + fullyQualifiedName);
		/*
		trace("ClassName:"+className);           // Buffer_ElementSimple
		trace("classPackage:" + classPackage);   // [peote,view]	
		
		trace("ElementPackage:" + elementPack);  // [elements]
		trace("ElementModule:" + elementModule); // elements.ElementSimple
		trace("ElementName:" + elementName);     // ElementSimple
		
		trace("ElementType:" + elementType);     // TPath({ name => ElementSimple, pack => [elements], params => [] })
		trace("ElemField:" + elemField);
		*/
		#end
		
		var c = macro // ---------------- Buffer -----------------------

/**
A Buffer stores all graphic elements and handles the data for an OpenGL-`vertex buffer`, for `<T>` it has to use a macro generated `Element` type.  
Used by a `Program` all contained elements will be rendered by the corresponding shaders/textures and the same buffer can also be shared by several programs.
**/
class $className implements peote.view.intern.BufferInterface
{
	var _gl: peote.view.PeoteGL = null;
	var _glBuffer: peote.view.PeoteGL.GLBuffer;
	var _glInstanceBuffer: peote.view.PeoteGL.GLBuffer = null;
	var _glVAO: peote.view.PeoteGL.GLVertexArrayObject = null;

	var _elements: haxe.ds.Vector<$elementType>;
	var _maxElements:Int = 0; // amount of added elements (pos of last element)
	var _elemBuffSize:Int;

	var _minSize:Int;
	var _growSize:Int = 0;
	var _shrinkAtSize:Int = 0;

	// local bytes-buffer
	var _bytes: peote.view.intern.BufferBytes;

	#if peoteview_queueGLbuffering
	var updateGLBufferElementQueue:Array<$elementType>;
	var setNewGLContextQueue:Array<PeoteGL>;
	/*var queueCreateGLBuffer:Bool = false;
	var queueDeleteGLBuffer:Bool = false;
	var queueUpdateGLBuffer:Bool = false;*/
	#end

	/**
		Creates a new `Buffer` instance.
		@param minSize how many elements a buffer should contain as a minimum
		@param growSize the size by which the buffer should grow when it is full
		@param autoShrink whether the buffer should also automatically shrink again (by the growsize)
	**/
	public function new(minSize:Int, growSize:Int = 0, autoShrink:Bool = false)
	{
		if (minSize <= 0) throw("Error: Buffer need a minimum size of 1 to store an Element.");
		_minSize = minSize;
		_growSize = (growSize < 0) ? 0 : growSize;
		if (autoShrink) _shrinkAtSize = growSize + Std.int(growSize/2);
		
		#if peoteview_queueGLbuffering
		updateGLBufferElementQueue = new Array<$elementType>();
		setNewGLContextQueue = new Array<PeoteGL>();
		#end
		
		_elements = new haxe.ds.Vector<$elementType>(_minSize);
		
		if (peote.view.PeoteGL.Version.isINSTANCED) // TODO can be missing if buffer created before peoteView
		{
			$p{elemField}.createInstanceBytes();
			_elemBuffSize = $p{elemField}.BUFF_SIZE_INSTANCED;
		}
		else _elemBuffSize = $p{elemField}.BUFF_SIZE * $p{elemField}.VERTEX_COUNT;
		
		#if peoteview_debug_buffer
		trace("create bytes for GLbuffer");
		#end
		_bytes = peote.view.intern.BufferBytes.alloc(_elemBuffSize * _minSize);
		_bytes.fill(0, _elemBuffSize * _minSize, 0);		
	}

	inline function setNewGLContext(newGl:PeoteGL)
	{
		#if peoteview_queueGLbuffering
		setNewGLContextQueue.push(newGl);
		#else
		_setNewGLContext(newGl);
		#end
	}
	inline function _setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != _gl) // only if different GL - Context	
		{
			if (_gl != null) deleteGLBuffer(); // < ------- TODO BUGGY with different gl-context (see multiwindow sample)
			
			#if peoteview_debug_buffer
			trace("Buffer setNewGLContext");
			#end
			_gl = newGl;
			createGLBuffer();
			//updateGLBuffer();
		}
	}
	/*
	inline function createGLBuffer():Void
	{
		#if peoteview_queueGLbuffering
		queueCreateGLBuffer = true;
		#else
		_createGLBuffer();
		#end
	}*/
	inline function createGLBuffer():Void
	{
		#if peoteview_debug_buffer
		trace("create new GlBuffer");
		#end
		_glBuffer = _gl.createBuffer();
		
		_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
		_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, new peote.view.intern.GLBufferPointer(_bytes), _gl.STREAM_DRAW); // STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW 
		_gl.bindBuffer (_gl.ARRAY_BUFFER, null);
		
		if (peote.view.PeoteGL.Version.isINSTANCED) { // init and update instance buffer
			_glInstanceBuffer = _gl.createBuffer();
			$p{elemField}.updateInstanceGLBuffer(_gl, _glInstanceBuffer);
		}
		if (peote.view.PeoteGL.Version.isVAO) { // init VAO 		
			_glVAO = _gl.createVertexArray();
			_gl.bindVertexArray(_glVAO);
			if (peote.view.PeoteGL.Version.isINSTANCED)
				$p{elemField}.enableVertexAttribInstanced(_gl, _glBuffer, _glInstanceBuffer);
			else $p{elemField}.enableVertexAttrib(_gl, _glBuffer);
			_gl.bindVertexArray(null);
		}
	}
	/*
	inline function deleteGLBuffer():Void
	{
		#if peoteview_queueGLbuffering
		queueDeleteGLBuffer = true;
		#else
		_deleteGLBuffer();
		#end
	}
	*/
	inline function deleteGLBuffer():Void
	{
		#if peoteview_debug_buffer
		trace("delete GlBuffer");
		#end
		_gl.deleteBuffer(_glBuffer);
		
		if (peote.view.PeoteGL.Version.isINSTANCED)	_gl.deleteBuffer(_glInstanceBuffer);
		if (peote.view.PeoteGL.Version.isVAO) _gl.deleteVertexArray(_glVAO);
	}
	/*
	inline function updateGLBuffer():Void
	{
		#if peoteview_queueGLbuffering
		queueUpdateGLBuffer = true;
		#else
		//var t = haxe.Timer.stamp();
		_updateGLBuffer();
		//trace("updateGLBuffer time:"+(haxe.Timer.stamp()-t));
		#end
	}
	*/
	inline function updateGLBuffer():Void
	{
		_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
		//_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, _bytes, _gl.STATIC_DRAW); // _gl.DYNAMIC_DRAW _gl.STREAM_DRAW
		//_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, _bytes, _gl.STREAM_DRAW); // more performance if allways updating (on IE better then DYNAMIC_DRAW)
		
		//_gl.bufferSubData(_gl.ARRAY_BUFFER, 0, _elemBuffSize*_maxElements, _bytes );
		_gl.bufferSubData(_gl.ARRAY_BUFFER, 0, _elemBuffSize*_maxElements, new peote.view.intern.GLBufferPointer(_bytes) );
		
		_gl.bindBuffer (_gl.ARRAY_BUFFER, null);
	}

	inline function changeBufferSize(newSize:Int):Void
	{
		var _newBytes = peote.view.intern.BufferBytes.alloc(_elemBuffSize * newSize);
		_newBytes.blit(0, _bytes, 0, _elemBuffSize * _maxElements);
		_bytes = _newBytes;
		
		// TODO: optimization maybe can be here for cpp, hl, hlc by this:
		// untyped _elements.resize(newSize);
		// instead of:
		var _newElements = new haxe.ds.Vector<$elementType>(newSize);
		//haxe.ds.Vector.blit(_elements, 0, _newElements, 0, _maxElements);
		for (i in 0..._maxElements) {
			var element = _elements.get(i);
			element.bufferPointer = new peote.view.intern.GLBufferPointer(_bytes, element.bytePos, _elemBuffSize);
			_newElements.set(i, element); 
		}
		_elements = _newElements;


		if (_gl != null) {
			_gl.deleteBuffer(_glBuffer);
			_glBuffer = _gl.createBuffer();
			_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
			_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, new peote.view.intern.GLBufferPointer(_bytes), _gl.STREAM_DRAW); // STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW 
			_gl.bindBuffer (_gl.ARRAY_BUFFER, null);
			if (peote.view.PeoteGL.Version.isVAO) { // rebind VAO	
				_gl.bindVertexArray(_glVAO);
				if (peote.view.PeoteGL.Version.isINSTANCED)
					$p{elemField}.enableVertexAttribInstanced(_gl, _glBuffer, _glInstanceBuffer);
				else $p{elemField}.enableVertexAttrib(_gl, _glBuffer);
				_gl.bindVertexArray(null);
			}
		}
	}

	/**
		The number of elements inside the buffer.
	**/
	public var length(get, never):Int;
	inline function get_length():Int return _maxElements;
		
	/**
		Adds an element to the buffer for rendering and returns it.
		@param  element Element instance
	**/
	public function addElement(element: $elementType):$elementType
	{	
		if (element.bytePos == -1) {
			if (_maxElements == _elements.length) {
				if (_growSize == 0) throw("Error: Can't add new Element. Buffer is full and automatic growing Buffersize is disabled.");
				#if peoteview_debug_buffer
				trace("grow up the Buffer to new size", _maxElements + _growSize);
				#end
				changeBufferSize(_maxElements + _growSize);
			}
			element.bytePos = _maxElements * _elemBuffSize;
			element.bufferPointer = new peote.view.intern.GLBufferPointer(_bytes, element.bytePos, _elemBuffSize);
			//trace("Buffer.addElement", _maxElements, element.bytePos);
			_elements.set(_maxElements++, element);
			updateElement(element);		
		} 
		else throw("Error: Element is already inside a Buffer");
		// TODO: set buffIndex inside element if that is generated by macro

		return element;
	}

	/**
		Updates the changes of an contained element to the rendering process.
		@param  element Element instance
	**/
	public function updateElement(element: $elementType):Void
	{
		if (peote.view.PeoteGL.Version.isINSTANCED)
			element.writeBytesInstanced(_bytes);
		else 
			element.writeBytes(_bytes);
			
		#if peoteview_queueGLbuffering
		updateGLBufferElementQueue.push(element);
		#else
		_updateElement(element);
		#end
	}

	/**
		Updates the complete buffer, so the changes of all contained elements at once to the rendering process.
	**/
	public function update():Void
	{
		//var t = haxe.Timer.stamp();
		for (i in 0..._maxElements) {
			if (peote.view.PeoteGL.Version.isINSTANCED)
				_elements.get(i).writeBytesInstanced(_bytes);
			else
				_elements.get(i).writeBytes(_bytes);
		}
		//trace("updateElement Bytes time:"+(haxe.Timer.stamp()-t));
		// TODO: peoteview_queueGLbuffering
		updateGLBuffer();
	}

	inline function _updateElement(element: $elementType):Void
	{	
		//trace("Buffer.updateElement at position" + element.bytePos);
		if (element.bytePos == -1) throw ("Error, Element is not added to Buffer");		
		if (_gl != null) element.updateGLBuffer(_gl, _glBuffer, _elemBuffSize);
	}

	/**
		Removes an element from the buffer, so it will not be rendered anymore.
		@param  element Element instance
	**/
	public function removeElement(element: $elementType):Void
	{	
		if (element.bytePos != -1) {
			if (_maxElements > 1 && element.bytePos < (_maxElements-1) * _elemBuffSize ) {
				#if peoteview_debug_buffer
				trace("Buffer.removeElement", element.bytePos);
				#end
				var lastElement: $elementType = _elements.get(--_maxElements);
				lastElement.bytePos = element.bytePos;
				//trace(lastElement.);
				lastElement.bufferPointer = new peote.view.intern.GLBufferPointer(_bytes, element.bytePos, _elemBuffSize);
				updateElement(lastElement);
				_elements.set( Std.int(  element.bytePos / _elemBuffSize ), lastElement);
			}
			else _maxElements--;
			element.bytePos = -1;
			if (_shrinkAtSize > 0 && _elements.length - _growSize >= _minSize && _maxElements <= _elements.length - _shrinkAtSize) {
				#if peoteview_debug_buffer
				trace("shrink Buffer to size", _elements.length - _growSize);
				#end
				changeBufferSize(_elements.length - _growSize);
			}			
		}
		else throw("Error: Element is not inside a Buffer");
		// TODO: set buffIndex inside element if that is generated by macro
	}

	/**
		Removes all elements from the buffer, so they will not be rendered anymore. 
		For GC you can use `clear(true)` to set all element references to `null` (a bit faster by `clear(true, true)`).
		@param  clearElementsRefs `true` to also set all element-references to null (false by default)
		@param  notUseElementsLater `true` a bit faster if you can not need to add the elements to a Buffer again (false by default)
	**/
	public function clear(clearElementsRefs:Bool = false, notUseElementsLater:Bool = false):Void
	{
		if (notUseElementsLater) clearElementsRefs = true;
		if (_shrinkAtSize > 0) clearElementsRefs = false;
		if ( clearElementsRefs || (!notUseElementsLater) ) {
			for (i in 0..._maxElements) {
				if (!notUseElementsLater) _elements.get(i).bytePos = -1;
				if (clearElementsRefs) _elements.set(i, null);
			}
		}
		_maxElements = 0;
		if (_shrinkAtSize > 0) {
			#if peoteview_debug_buffer
			trace("shrink Buffer to size", _minSize);
			#end
			changeBufferSize(_minSize);
		}	
	}

	/**
		Returns the element from buffer at index position.
		@param  elementIndex index of the element inside the buffer
	**/
	public function getElement(elementIndex:Int): $elementType
	{
		return _elements.get(elementIndex);
	}

	/**
		Returns the index position of an element inside the buffer.
		@param  element Element instance
	**/
	public function getElementIndex(element:$elementType):Int
	{
		if (element.bytePos != -1) {
			return Std.int(  element.bytePos / _elemBuffSize );
		}
		else throw("Error: Element is not inside a Buffer");
	}

	/**
		Swaps the order of two elements inside the buffer. This will change the drawing order if no z-index is used.
		@param  element1 first Element instance
		@param  element2 second Element instance
	**/
	public function swapElements(element1: $elementType, element2: $elementType):Void
	{	
		#if peoteview_debug_buffer
		trace("Buffer.swapElements", element.bytePos);
		#end
		
		if (element1.bytePos == -1) throw("Error: first Element is not inside a Buffer");
		if (element2.bytePos == -1) throw("Error: second Element is not inside a Buffer");
		
		var bytePos1 = element1.bytePos;
		var bufferPointer1 = element1.bufferPointer;
		
		element1.bufferPointer = element2.bufferPointer;//new peote.view.intern.GLBufferPointer(_bytes, element2.bytePos, _elemBuffSize);
		element1.bytePos = element2.bytePos;
		//updateElement(element1);
		
		//element2.bufferPointer = new peote.view.intern.GLBufferPointer(_bytes, bytePos1, _elemBuffSize);
		element2.bufferPointer = bufferPointer1;
		element2.bytePos = bytePos1;
		//updateElement(element2);
		
		_elements.set( Std.int(  element1.bytePos / _elemBuffSize ), element1);
		_elements.set( Std.int(  element2.bytePos / _elemBuffSize ), element2);
		
		// TODO: set buffIndex inside element if that is generated by macro
	}

	// ---------------------------

	private function getElementWithHighestZindex(elementIndices:Array<Int>): Int
	{
		var lastZindex:Int = - $p{elemField}.MAX_ZINDEX;
		var highest:Int = -1;
		var e:$elementType;
		for (i in elementIndices) {
			e = _elements.get(i);
			if (e.getZINDEX() > lastZindex) {
				lastZindex = e.getZINDEX();
				highest = i;
			}
		}
		return highest;
	}

	// TODO: if alpha + zIndex this will be needed 
	/*public function sortTransparency():Void
	{
	}*/

	inline function getVertexShader():String return $p{elemField}.vertexShader;
	inline function getFragmentShader():String return $p{elemField}.fragmentShader;
	inline function getTextureIdentifiers():Array<String> return ($p{elemField}.IDENTIFIERS_TEXTURE == "") ? [] : $p{elemField}.IDENTIFIERS_TEXTURE.split(",");
	inline function getColorIdentifiers():Array<String> return ($p{elemField}.IDENTIFIERS_COLOR == "") ? [] :  $p{elemField}.IDENTIFIERS_COLOR.split(",");
	inline function getCustomIdentifiers():Array<String> return ($p{elemField}.IDENTIFIERS_CUSTOM == "") ? [] :  $p{elemField}.IDENTIFIERS_CUSTOM.split(",");
	inline function getCustomVaryings():Array<String> return ($p{elemField}.VARYINGS_CUSTOM == "") ? [] :  $p{elemField}.VARYINGS_CUSTOM.split(",");
	inline function getDefaultColorFormula():String return $p{elemField}.DEFAULT_COLOR_FORMULA;
	inline function getDefaultFormulaVars():haxe.ds.StringMap<peote.view.Color> return $p{elemField}.DEFAULT_FORMULA_VARS;

	inline function getFormulas():haxe.ds.StringMap<String> return $p{elemField}.FORMULAS;
	inline function getAttributes():haxe.ds.StringMap<String> return $p{elemField}.ATTRIBUTES;
	inline function getFormulaNames():haxe.ds.StringMap<String> return $p{elemField}.FORMULA_NAMES;

	inline function getFormulaVaryings():Array<String> return ($p{elemField}.FORMULA_VARYINGS == "") ? [] :  $p{elemField}.FORMULA_VARYINGS.split(",");
	inline function getFormulaConstants():Array<String> return ($p{elemField}.FORMULA_CONSTANTS == "") ? [] :  $p{elemField}.FORMULA_CONSTANTS.split(",");
	inline function getFormulaCustoms():Array<String> return ($p{elemField}.FORMULA_CUSTOMS == "") ? [] :  $p{elemField}.FORMULA_CUSTOMS.split(",");

	inline function getMaxZindex():Int return $p{elemField}.MAX_ZINDEX;
	inline function hasBlend():Bool return $p{elemField}.BLEND_ENABLED;
	inline function hasZindex():Bool return $p{elemField}.ZINDEX_ENABLED;
	inline function hasPicking():Bool return $p{elemField}.PICKING_ENABLED;
	inline function hasTime():Bool return $p{elemField}.TIME_ENABLED;
	inline function needFragmentPrecision():Bool return $p{elemField}.NEED_FRAGMENT_PRECISION;

	inline function bindAttribLocations(gl: peote.view.PeoteGL, glProgram: peote.view.PeoteGL.GLProgram):Void
	{
		if (peote.view.PeoteGL.Version.isINSTANCED)
			$p{elemField}.bindAttribLocationsInstanced(gl, glProgram);
		else $p{elemField}.bindAttribLocations(gl, glProgram);
	}

	inline function render(peoteView:peote.view.PeoteView, display:peote.view.Display, program:peote.view.Program)
	{
		renderFromTo( peoteView, display, program, _maxElements );
	}

	inline function pick(peoteView:peote.view.PeoteView, display:peote.view.Display, program:peote.view.Program, toElement:Int)
	{
		renderFromTo( peoteView, display, program, (toElement < 0) ? _maxElements : toElement );
	}	

	inline function renderFromTo(peoteView:peote.view.PeoteView, display:peote.view.Display, program:peote.view.Program, toElement:Int)
	{		
		//trace("        ---buffer.render---");
		#if peoteview_queueGLbuffering
		//TODO: put all in one glCommandQueue (+ loop)
		if (updateGLBufferElementQueue.length > 0) _updateElement(updateGLBufferElementQueue.shift());
		if (setNewGLContextQueue.length > 0) _setNewGLContext(setNewGLContextQueue.shift());
		/*if (queueDeleteGLBuffer) {
			queueDeleteGLBuffer = false;
			_deleteGLBuffer();
		}
		if (queueCreateGLBuffer) {
			queueCreateGLBuffer = false;
			_createGLBuffer();
		}
		if (queueUpdateGLBuffer) {
			queueUpdateGLBuffer = false;
			_updateGLBuffer();
		}*/
		#end
		
		//var t = haxe.Timer.stamp();
		if (peote.view.PeoteGL.Version.isINSTANCED) {
			if (peote.view.PeoteGL.Version.isVAO) _gl.bindVertexArray(_glVAO);
			else $p{elemField}.enableVertexAttribInstanced(_gl, _glBuffer, _glInstanceBuffer);
			
			_gl.drawArraysInstanced (_gl.TRIANGLE_STRIP, 0, $p{elemField}.VERTEX_COUNT, toElement);
			
			if (peote.view.PeoteGL.Version.isVAO) _gl.bindVertexArray(null);
			else $p{elemField}.disableVertexAttribInstanced(_gl);
			
			_gl.bindBuffer (_gl.ARRAY_BUFFER, null); // TODO: check if this is obsolete on all platforms !
		}
		else {
			if (peote.view.PeoteGL.Version.isVAO) _gl.bindVertexArray(_glVAO);
			else $p{elemField}.enableVertexAttrib(_gl, _glBuffer);
			
			_gl.drawArrays (_gl.TRIANGLE_STRIP, 0, toElement * $p{elemField}.VERTEX_COUNT);
			
			if (peote.view.PeoteGL.Version.isVAO) _gl.bindVertexArray(null);
			else $p{elemField}.disableVertexAttrib(_gl);
			
			_gl.bindBuffer (_gl.ARRAY_BUFFER, null); // TODO: check if this is obsolete on all platforms !
		}
		//trace("render time:"+(haxe.Timer.stamp()-t));
	}
};



// ---------------- end Buffer --------

		Context.defineModule(fullyQualifiedName,[c]);
		return tp;
	}
}
#end




#else

// ----------------------------------------------------------------
// -------------------- ONLY FOR DOX ------------------------------
// ----------------------------------------------------------------

/**
A Buffer stores all graphic elements and handles the data for an OpenGL-`vertex buffer`, for `<T>` it has to use a macro generated `Element` type.  
Used by a `Program` all contained elements will be rendered by the corresponding shaders/textures and the same buffer can also be shared by several programs.
**/
class Buffer<T>
{
	/**
		The number of elements inside the buffer.
	**/
	public var length(get, never):Int;
	inline function get_length():Int return 0;

	/**
		Creates a new `Buffer` instance.
		@param minSize how many elements a buffer should contain as a minimum
		@param growSize the size by which the buffer should grow when it is full
		@param autoShrink whether the buffer should also automatically shrink again (by the growsize)
	**/
	public function new(minSize:Int, growSize:Int = 0, autoShrink:Bool = false) {}

	/**
		Adds an element to the buffer for rendering and returns it.
		@param  element Element instance
	**/
	public function addElement(element:T):T { return null; }

	/**
		Updates the changes of an contained element to the rendering process.
		@param  element Element instance
	**/
	public function updateElement(element:T):Void {}

	/**
		Updates the complete buffer, so the changes of all contained elements at once to the rendering process.
	**/
	public function update():Void {}

	/**
		Removes an element from the buffer, so it will not be rendered anymore.
		@param  element Element instance
	**/
	public function removeElement(element:T):Void {}

	/**
		Removes all elements from the buffer, so they will not be rendered anymore. 
		For GC you can use `clear(true)` to set all element references to `null` (a bit faster by `clear(true, true)`).
		@param  clearElementsRefs `true` to also set all element-references to null (false by default)
		@param  notUseElementsLater `true` a bit faster if you can not need to add the elements to a Buffer again (false by default)
	**/
	public function clear(clearElementsRefs:Bool = false, notUseElementsLater:Bool = false):Void {}

	/**
		Returns the element from buffer at index position.
		@param  elementIndex index of the element inside the buffer
	**/
	public function getElement(elementIndex:Int):T return null;

	/**
		Returns the index position of an element inside the buffer.
		@param element Element instance
	**/
	public function getElementIndex(element:T):Int return 0;

	/**
		Swaps the order of two elements inside the buffer. This will change the drawing order if no z-index is used.
		@param element1 first Element instance
		@param element2 second Element instance
	**/
	public function swapElements(element1:T, element2:T):Void {}
}
#end