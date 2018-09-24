package elements;

import peote.view.Element;

class ElementAnim implements Element
{
	@posX @set("Position") @const(10)//@anim("Position") @time("Position") @constStart(10) @constEnd(100)
	public var x:Int=0;
	@posY @set("Position") //@anim("Position") @time("Position") @constStart(10) @constEnd(100)
	public var y:Int=0;
	
	@sizeX @set("animWidth")  @time("Size") public var w:Int=100; //@constStart(300) @constEnd(400) 
	@sizeY @set("animHeight") @time("Size") public var h:Int=100; //@constEnd(200)
	
	public var wStart:Int = 100;
	public var wEnd:Int   = 100;
	
	public var hStart:Int = 100;
	public var hEnd:Int   = 100;
	
	public var timeSizeStart      = 1.0;
	public var timeSizeDuration   = 1.0;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}

	public function animWidth(wStart:Int, wEnd:Int):Void
	{
		this.wStart = wStart;
		this.wEnd   = wEnd;
	}
	public function animHeight(hStart:Int, hEnd:Int):Void
	{
		this.hStart = hStart;
		this.hEnd   = hEnd;
	}
	public function timeSize(startTime:Float, duration:Float):Void
	{
		timeSizeStart    = startTime;
		timeSizeDuration = duration;
	}
	
}
