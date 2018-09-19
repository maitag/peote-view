package elements;

import peote.view.Element;

class ElementAnim implements Element
{
	@posX @anim("Position") @time("Position") @const public var x:Int=0;//:Array=[0,1];
	@posY @anim("Position") @time("Position") public var y:Int=0;
	
	public var xStart:Int = 0;
	public var xEnd:Int   = 0;
	public var yStart:Int = 0;
	public var yEnd:Int   = 0;
	
	public var timePositionStart    = 0.0;
	public var timePositionDuration = 0.0;
	
	@width  @anim("Width")  @time("Size") public var w:Int=100;
	@height @anim("Height") @time("Size") public var h:Int=100;
	
	public var wStart:Int = 100;
	public var wEnd:Int   = 100;
	
	public var hStart:Int = 100;
	public var hEnd:Int   = 100;
	
	public var timeSizeStart      = 0.0;
	public var timeSizeDuration   = 0.0;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}


	public function animPosition(xStart:Int, yStart:Int, xEnd:Int, yEnd:Int):Void
	{
		this.xStart = xStart;
		this.yStart = yStart;
		this.xEnd   = xEnd;
		this.yEnd   = yEnd;
	}
	public function timePosition(startTime:Float, duration:Float):Void
	{
		timePositionStart    = startTime;
		timePositionDuration = duration;		
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
