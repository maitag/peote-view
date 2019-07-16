package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

#if sampleTest
typedef Sample = Test;
#elseif sampleDepthBlend
typedef Sample = DepthBlend;
#elseif sampleTextureSimple
typedef Sample = TextureSimple;
#elseif sampleTextureSlotTiles
typedef Sample = TextureSlotTiles;
#elseif sampleMultiTextures
typedef Sample = MultiTextures;
#elseif sampleTextureCaching
typedef Sample = TextureCaching;
#elseif sampleTextureMipmapFilter
typedef Sample = TextureMipmapFilter;
#elseif sampleMultidisplay
typedef Sample = Multidisplay;
#elseif sampleMultibuffer
typedef Sample = Multibuffer;
#elseif sampleAnimation
typedef Sample = Animation;
#elseif sampleHitTest
typedef Sample = HitTest;
#elseif sampleElementInherit
typedef Sample = ElementInherit;
#elseif sampleGLPicking
typedef Sample = GLPicking;
#elseif sampleRenderToTexture
typedef Sample = RenderToTexture;
#elseif sampleGl3FontRendering
typedef Sample = Gl3FontRendering;
#elseif sampleTextRendering
typedef Sample = TextRendering;
#elseif sampleShaderInjection
typedef Sample = ShaderInjection;
#elseif sampleBunnyMark
typedef Sample = BunnyMark;
#elseif sampleBunnyMarkGPU
typedef Sample = BunnyMarkGPU;
#elseif sampleMouseEvents
typedef Sample = MouseEvents;
#elseif sampleUserInterface
typedef Sample = UserInterface;
#end 

class Main extends Application
{
    public var mouse_x: Int = 0;
    public var mouse_y: Int = 0;
    public var xOffset: Int = 0;
    public var yOffset: Int = 0;
    public var zoom: Int = 1;
	
	var test:Sample = null;
	var renderTest:Bool = false;

	public function new() {
		super();
	}
	
	public override function onWindowCreate():Void
	{
		trace (window.context.type +"" + window.context.version);
		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: test = new Sample(window);
				
			default: throw("Sorry, only works with OpenGL.");
		}
		
		if (test != null) renderTest = true;
	}
	
	// ------------------------------------------------------------	
	// ----------- Render Loop ------------------------------------
	public override function render(context:RenderContext):Void
	{	
		if (renderTest) test.render();
	}
	
	public override function update(deltaTime:Int):Void
	{
		if (renderTest) test.update(deltaTime);
	}

	// ------------------------------------------------------------
	// ----------- EVENT HANDLER ----------------------------------
	public override function onPreloadComplete ():Void {
		if (renderTest) test.onPreloadComplete();
	}
	
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
	
	public override function onMouseMoveRelative (x:Float, y:Float):Void {
		//trace("onMouseMoveRelative" + x + "," + y ); 	
	}
	
	public override function onMouseMove (x:Float, y:Float):Void
	{
		//trace("onMouseMove: " + x + "," + y );
		if (renderTest) test.onMouseMove(x, y);

		mouse_x = Std.int(x);
		mouse_y = Std.int(y);
		setOffsets();
	}
	
	public override function onTouchStart (touch:Touch):Void
	{
		//trace("onTouchStart: " + touch.id );
		//trace("onTouchStart: " + touch.x + "," + touch.y );
	}
	
	public override function onTouchMove (touch:Touch):Void
	{
		//trace("onTouchMove: " + touch.id + "," + touch.x + "," + touch.y );
		mouse_x = Std.int(touch.x); //* window.width;
		mouse_y = Std.int(touch.y);
		setOffsets();
	}
	
	public override function onTouchEnd (touch:Touch):Void
	{
		//trace("onTouchEnd: " + touch.id );
		//trace("onTouchStart: " + touch.x + "," + touch.y );
	}
	
	public override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{	
		//trace("onMouseDown: x=" + x + " y="+ y);
		/*if ( button == 0) zoom++;
		else if (button == 1 && zoom > 1) zoom--;
		setOffsets();*/
		if (renderTest) test.onMouseDown(x, y, button);
	}
	
	public override function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{	
		//trace("onmouseup: " + button + " x=" + x + " y=" + y);
		if (renderTest) test.onMouseUp(x, y, button);
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
		//trace("keydown",keyCode, modifier);
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			case KeyCode.F:
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
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			#end
			default:
		}
		
		if (renderTest) test.onKeyDown(keyCode, modifier);
	}
	
	public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void {
		//trace("keyup",keyCode, modifier);
	}

	public override function onWindowLeave ():Void {
		//trace("onWindowLeave"); 
		if (renderTest) test.onWindowLeave();
	}
	/*
	public override function onWindowActivate ():Void { trace("onWindowActivate"); }
	public override function onWindowClose ():Void { trace("onWindowClose"); }
	public override function onWindowDeactivate ():Void { trace("onWindowDeactivate"); }
	public override function onWindowDropFile (file:String):Void { trace("onWindowDropFile"); }
	public override function onWindowEnter ():Void { trace("onWindowEnter"); }
	public override function onWindowExpose ():Void { trace("onWindowExpose"); }
	public override function onWindowFocusIn ():Void { trace("onWindowFocusIn"); }
	public override function onWindowFocusOut ():Void { trace("onWindowFocusOut"); }
	public override function onWindowFullscreen ():Void { trace("onWindowFullscreen"); }
	public override function onWindowMove (x:Float, y:Float):Void { trace("onWindowMove"); }
	public override function onWindowMinimize ():Void { trace("onWindowMinimize"); }
	public override function onWindowRestore ():Void { trace("onWindowRestore"); }
	*/
	
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
