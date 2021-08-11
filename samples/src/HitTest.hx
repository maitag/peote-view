package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;

import utils.Loader;

class Elem implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var c:Color;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, color:Color=Color.RED )
	{
		x = positionX;
		y = positionY;
		w = width;
		h = height;
		c = color;
	}

	// --------------------------------
	// ----------- hit-test -----------   (   TODO !!! )
	// --------------------------------
	
	public function getIntersectionAt(deltaX:Int, deltaY:Int):Array<Elem> {
		
		var intersected = new Array<Elem>();
		
		if (deltaX < 0) {                      // simple traverse left (..at FIRST;)
			var e:Elem = xwLeft;
			while (e != null )
			{
				if ( xIntersects(e, x + deltaX) && yIntersects(e, y + deltaY) ) {
					intersected.push(e);
					e = e.xwLeft;
				}
				else e = null;
			}
			// TODO:
			//xwRemove...(); xRemove...();
			//xwInsertLeft(intersected[intersected.length - 1]); // <- CHECK
			//xInsertLeft( ====???TheSame????==== ); // Left or Right :) ?
		}
		else if (deltaX > 0) {
			// TODO
		}
		
		// Question: how to interleave with Y (^_^) ???		
		
		return intersected;
	}
	
		
	inline function xIntersects(e:Elem, x:Int):Bool
		return ((x >= e.x && x <= e.x + e.w) || (e.x >= x && e.x <= x + w));
	
	inline function yIntersects(e:Elem, y:Int):Bool
		return ((y >= e.y && y <= e.y + e.h) || (e.y >= y && e.y <= y + h));

		
	
	// --------------------------------
	// ----------- insertSort --------- (works)
	// --------------------------------
	
	// double linked list for boundaries
	public var xLeft:Elem;
	public var xRight:Elem;
	public var xwLeft:Elem;
	public var xwRight:Elem;
	public var yTop:Elem;
	public var yBottom:Elem;
	public var yhTop:Elem;
	public var yhBottom:Elem;
	
	public function insertAt(e:Elem) {
		if (x >= e.x) xInsertRight(e);
		else xInsertLeft(e);
		
		if (x+w >= e.x+e.w) xwInsertRight(e);
		else xwInsertLeft(e);
		
		if (y >= e.y) yInsertBottom(e);
		else yInsertTop(e);
		
		if (y+h >= e.y+e.h) yhInsertBottom(e);
		else yhInsertTop(e);
		
	}
	
	inline function xInsertRight(e:Elem):Void {
		if (e.xRight == null)     { xLeft = e; xRight = e.xRight; e.xRight = this; }
		else if (x <= e.xRight.x) { xLeft = e; xRight = e.xRight; e.xRight = xRight.xLeft = this; }
		else xInsertRight(e.xRight);
	}
	inline function xInsertLeft(e:Elem):Void {
		if (e.xLeft == null)     { xRight = e; xLeft = e.xLeft; e.xLeft = this; }
		else if (e.xLeft.x <= x) { xRight = e; xLeft = e.xLeft; e.xLeft = xLeft.xRight = this; }
		else xInsertLeft(e.xLeft);
	}
	inline function xwInsertRight(e:Elem):Void {
		if (e.xwRight == null)                     { xwLeft = e; xwRight = e.xwRight; e.xwRight = this; }
		else if (x+w <= e.xwRight.x + e.xwRight.w) { xwLeft = e; xwRight = e.xwRight; e.xwRight = xwRight.xwLeft = this; }
		else xwInsertRight(e.xwRight);
	}
	inline function xwInsertLeft(e:Elem):Void {
		if (e.xwLeft == null)                    { xwRight = e; xwLeft = e.xwLeft; e.xwLeft = this; }
		else if (e.xwLeft.x + e.xwLeft.w <= x+w) { xwRight = e; xwLeft = e.xwLeft; e.xwLeft = xwLeft.xwRight = this; }
		else xwInsertLeft(e.xwLeft);
	}
	
	inline function yInsertBottom(e:Elem):Void {
		if (e.yBottom == null)     { yTop = e; yBottom = e.yBottom; e.yBottom = this; }
		else if (y <= e.yBottom.y) { yTop = e; yBottom = e.yBottom; e.yBottom = yBottom.yTop = this; }
		else yInsertBottom(e.yBottom);
	}
	inline function yInsertTop(e:Elem):Void {
		if (e.yTop == null)     { yBottom = e; yTop = e.yTop; e.yTop = this; }
		else if (e.yTop.y <= y) { yBottom = e; yTop = e.yTop; e.yTop = yTop.yBottom = this; }
		else yInsertTop(e.yTop);
	}
	inline function yhInsertBottom(e:Elem):Void {
		if (e.yhBottom == null)                      { yhTop = e; yhBottom = e.yhBottom; e.yhBottom = this; }
		else if (y+h <= e.yhBottom.y + e.yhBottom.h) { yhTop = e; yhBottom = e.yhBottom; e.yhBottom = yhBottom.yhTop = this; }
		else yhInsertBottom(e.yhBottom);
	}
	inline function yhInsertTop(e:Elem):Void {
		if (e.yhTop == null)                   { yhBottom = e; yhTop = e.yhTop; e.yhTop = this; }
		else if (e.yhTop.y + e.yhTop.h <= y+h) { yhBottom = e; yhTop = e.yhTop; e.yhTop = yhTop.yhBottom = this; }
		else yhInsertTop(e.yhTop);
	}
	
}


class HitTest extends Application
{
	var peoteView:PeoteView;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{	
		peoteView = new PeoteView(window);
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		display.addProgram(program);
		
		var e0  = new Elem(0, 0);
		buffer.addElement(e0);
		
		var e1  = new Elem(100, 0, 100, 100, Color.BLUE);	e1.insertAt(e0);
		buffer.addElement(e1);
		
		var e2  = new Elem(200, 0, 100, 100, Color.YELLOW);	e2.insertAt(e0);
		buffer.addElement(e2);
		
		// Hit-Testing (only at X-Direction now!)
		trace( "at x+50  e2 hits " + e2.getIntersectionAt(  50, 0).length  + " elements");
		trace( "at x-50  e2 hits " + e2.getIntersectionAt( -50, 0).length  + " elements");
		trace( "at x-150 e2 hits " + e2.getIntersectionAt( -150, 0).length + " elements");
	}
	
}
