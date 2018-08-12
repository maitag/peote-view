package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;


class Main extends Application
{
    public var mouse_x: Int = 0;
    public var mouse_y: Int = 0;
    public var xOffset: Int = 0;
    public var yOffset: Int = 0;
    public var zoom: Int = 1;
	
	var test:Test;
	var renderTest:Bool = false;

	public function new() {
		super();
	}
	
	public override function onWindowCreate():Void
	{
		trace ("window.context.version:"+window.context.version);
		trace ("window.context.type:" + window.context.type);

		switch (window.context.type) {

		#if html5
			case WEBGL:
				if (window.context.webgl2 != null) trace("YEEEAHHH");
				test = new Test(window.context.webgl, window.width, window.height);
				renderTest = true;
		#else
			case OPENGL, OPENGLES:
				if (window.context.gles2 != null) trace("WOAHAHH");
				if (window.context.gles3 != null) trace("(^_^)");
				test = new Test(window.context.gl   , window.width, window.height);
				renderTest = true;
		#end
				
			default:
				trace("only opengl supported");
		}
	}
	
	// ------------------------------------------------------------	
	// ----------- Render Loop ------------------------------------
	public override function render(context:RenderContext):Void
	{	
		switch (window.context.type) {
			case OPENGL, OPENGLES, WEBGL:
				
				if (renderTest) test.render();
								
			default:
				trace("only opengl supported");
		}
	}

	// ------------------------------------------------------------
	// ----------- EVENT HANDLER ----------------------------------
	public override function onWindowResize (width:Int, height:Int):Void
	{
		if (renderTest) test.resize(width, height);
		//trace("onWindowResize:"+ width+','+ height);
		/*
		// hack for minimum width on cpp native
		var w = Math.floor(Math.max(200, width));
		var h = Math.floor(Math.max(200, height));
		
		if (w != width || h != height) window.resize(w, h);
		*/
	}
	
	public override function onMouseMove (x:Float, y:Float):Void
	{
		//trace("onMouseMove: " + x + "," + y );
		mouse_x = Std.int(x);
		mouse_y = Std.int(y);
		setOffsets();
	}
	
	public override function onTouchStart (touch:Touch):Void
	{
		trace("onTouchStart: " + touch.id );
		//trace("onTouchStart: " + touch.x + "," + touch.y );
	}
	
	public override function onTouchMove (touch:Touch):Void
	{
		trace("onTouchMove: " + touch.id + "," + touch.x + "," + touch.y );
		mouse_x = Std.int(touch.x); //* window.width;
		mouse_y = Std.int(touch.y);
		setOffsets();
	}
	
	public override function onTouchEnd (touch:Touch):Void
	{
		trace("onTouchEnd: " + touch.id );
		//trace("onTouchStart: " + touch.x + "," + touch.y );
	}
	
	public override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onMouseDown: x=" + x + " y="+ y);
		/*if ( button == 0) zoom++;
		else if (button == 1 && zoom > 1) zoom--;
		setOffsets();*/
	}
	
	public override function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onmouseup: "+button+" x=" + x + " y="+ y);
	}
	
	public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void
	{	
		//trace("onmousewheel: " + deltaX + ',' + deltaY );
		if ( deltaY>0 ) zoom++;
		else if (zoom > 1) zoom--;
		setOffsets();
	}

	public override function onRenderContextLost ():Void
	{		
		trace(" --------- ERROR :  LOST RENDERCONTEXT ----------- ");		
	}
	
	public override function onRenderContextRestored (context:RenderContext):Void
	{
		trace(" --------- onRenderContextRestored ----------- ");		
	}
	
	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.F:
				#if html5
				var e:Dynamic = untyped __js__("document.getElementById('content').getElementsByTagName('canvas')[0]");
				var noFullscreen:Dynamic = untyped __js__("(!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement)");
				
				if ( noFullscreen)
				{	// enter fullscreen
					if (e.requestFullScreen) e.requestFullScreen();
					else if (e.msRequestFullScreen) e.msRequestFullScreen();
					else if (e.mozRequestFullScreen) e.mozRequestFullScreen();
					else if (e.webkitRequestFullScreen) e.webkitRequestFullScreen();
				}
				else
				{	// leave fullscreen
					var d:Dynamic = untyped __js__("document");
					if (d.exitFullscreen) d.exitFullscreen();
					else if (d.msExitFullscreen) d.msExitFullscreen();
					else if (d.mozCancelFullScreen) d.mozCancelFullScreen();
					else if (d.webkitExitFullscreen) d.webkitExitFullscreen();					
				}
				#else
				window.fullscreen = !window.fullscreen;
				#end				
			default:
		}
	}
	
	// end Event Handler ------------------------------
	// ------------------------------------------------
	
	public function setOffsets():Void {
		xOffset = -mouse_x;
		yOffset = -mouse_y;
	}

	// -- Math-Stuff
	private inline function random(n:Int):Int
	{
		return Math.floor(Math.random() * n);
	}
	
	
}
