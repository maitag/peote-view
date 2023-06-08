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

import peote.view.utils.BlendFactor;
import peote.view.utils.BlendFunc;

class ElementSimple implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var c:Color = 0xff0000ff;
		
	@zIndex public var z:Int = 0;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
	
	var OPTIONS = {	
		//blend:true,		
	};
}


class BlendAlphaMode extends Application
{
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
		var peoteView = new PeoteView(window);
		var display   = new Display(0,0, window.width, window.height);

		var buffer = new Buffer<ElementSimple>(4, 4, true);
		var program = new Program(buffer);
		
		peoteView.addDisplay(display);
		display.addProgram(program);
		
		var element0 = new ElementSimple(100,100,100,100, 0xFF0000FF);
		buffer.addElement(element0);

		var element1 = new ElementSimple(150,150,100,100, 0x00FF0099);
		buffer.addElement(element1);
		
		
		// look at here for blend modes: https://www.andersriggelsen.dk/glblendfunc.php
		
		program.blendEnabled = true; // false by default
		
		// --- value for constant blend-color ---
		program.blendColor = Color.RED;
		
		// ---------- blendmode --------
		program.blendSrc = BlendFactor.SRC_ALPHA;
		program.blendDst = BlendFactor.ONE_MINUS_SRC_ALPHA;

		// --- separate blendmode for Alpha channel ------
		program.blendSeparate = true; // false by default
		program.blendSrcAlpha = BlendFactor.SRC_ALPHA;
		program.blendDstAlpha = BlendFactor.ONE_MINUS_SRC_ALPHA;
		
		// ------- blend equation function ---------
		program.blendFunc = BlendFunc.ADD;
		
		// -- separate blend equation functions Alpha channel --
		program.blendFuncSeparate = true; // false by default
		program.blendFuncAlpha = BlendFunc.ADD;		
	}
		
}