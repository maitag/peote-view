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
	var _gl: peote.view.PeoteGL = null; // TODO: multiple rendercontexts
	var _glBuffer: lime.graphics.opengl.GLBuffer;  // TODO: multiple rendercontexts

	// local bytes-buffer
	var _elements: haxe.ds.Vector<$elementType>;
	// var elements:Int; TAKE CARE if same name as package! -> TODO!!
	var _maxElements:Int = 0; // amount of added elements (pos of last element)
	
	var _bytes: haxe.io.Bytes;
	
	public function new(size:Int)
	{
		//var elements:Int; //TAKE CARE for vars with same name as package! -> TODO!!
		_elements = new haxe.ds.Vector<$elementType>(size);
		
		var buffSize:Int = Std.int(size * $p{elemField}.BUFF_SIZE);
		_bytes = haxe.io.Bytes.alloc(buffSize);
		_bytes.fill(0, buffSize, 0);
	}
	
	// creates new opengl buffer 
	inline function createGlBuffer():Void
	{
		trace("createGlBuffer", _bytes.length);
		_glBuffer = _gl.createBuffer();
		_gl.bindBuffer (_gl.ARRAY_BUFFER, _glBuffer);
		_gl.bufferData (_gl.ARRAY_BUFFER, _bytes.length, _bytes, _gl.STATIC_DRAW); // _gl.DYNAMIC_DRAW _gl.STREAM_DRAW
		_gl.bindBuffer (_gl.ARRAY_BUFFER, null);
		
		#if peoteview_instancedrawing
		$p{elemField}.createInstanceBuffer(_gl);
		#end		
	}
	
	// rewrite element-buffer to GL-buffer
	public inline function updateElement(element: $elementType):Void
	{	
		trace("Buffer.updateElement", element.bytePos);
		element.updateGlBuffer(_gl, _glBuffer);		
	}
	
	// adds an element to empty place inside buffer
	public function addElement(element: $elementType):Void
	{	
		if (element.bytePos == -1) {
			element.bytePos = _maxElements * $p{elemField}.BUFF_SIZE;
			element.dataPointer = new lime.utils.BytePointer(_bytes, element.bytePos);
			trace("Buffer.addElement", _maxElements, element.bytePos);
			_elements.set(_maxElements++, element);
			element.writeBytes(_bytes);
			updateElement(element);		
		} 
		else throw("Error: Element is already inside Buffer");
	}
		
	public function removeElement(element: $elementType):Void
	{
		if (element.bytePos != -1) {
			if (_maxElements > 1 && element.bytePos < (_maxElements-1) * $p{elemField}.BUFF_SIZE ) {
				trace("Buffer.removeElement", element.bytePos);
				var lastElement: $elementType = _elements.get(--_maxElements);
				updateElement(lastElement);
				lastElement.bytePos = element.bytePos;
				lastElement.dataPointer = new lime.utils.BytePointer(_bytes, element.bytePos);
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

	private inline function bindAttribLocations(gl: peote.view.PeoteGL, glProgram: lime.graphics.opengl.GLProgram):Void
	{
		$p{elemField}.bindAttribLocations(gl, glProgram);
	}

	private inline function render(peoteView:PeoteView, display:Display, program:Program)
	{
		//trace("        ---buffer.render---");
		$p{elemField}.render(_maxElements, peoteView.gl, _glBuffer);
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
