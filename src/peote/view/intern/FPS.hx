package peote.view.intern;

import haxe.Timer;
import peote.view.PeoteView;
import peote.view.text.TextProgram;
import peote.view.text.Text;
import peote.view.text.BMFontData;
import peote.view.Display;

@:allow(peote.view.PeoteView)
class FPS extends Display
{
	var textProgram:TextProgram;
	var fpsText:Text;

	var size(default, null):Int;

	var w(get, never):Int;
	inline function get_w():Int return size*7 + size - 2;
	
	var h(get, never):Int;
	inline function get_h():Int return size+7;	

	function new(peoteView:PeoteView, size:Int = 8)
	{
		if (size<8) size = 8;
		this.size = size;

		super(0, 0, w, h, 0x104407ea);

		this.peoteView = peoteView;
		setNewGLContext(peoteView.gl);

		textProgram = new TextProgram(
			new BMFontData(
				[	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 032  0x20  space
					0x7C, 0xCE, 0xDE, 0xF6, 0xE6, 0xC6, 0x7C, 0x00, // 048  0x30  0
					0x30, 0x70, 0x30, 0x30, 0x30, 0x30, 0xFC, 0x00, // 049  0x31  1
					0x78, 0xCC, 0x0C, 0x38, 0x60, 0xCC, 0xFC, 0x00, // 050  0x32  2
					0x78, 0xCC, 0x0C, 0x38, 0x0C, 0xCC, 0x78, 0x00, // 051  0x33  3
					0x1C, 0x3C, 0x6C, 0xCC, 0xFE, 0x0C, 0x1E, 0x00, // 052  0x34  4
					0xFC, 0xC0, 0xF8, 0x0C, 0x0C, 0xCC, 0x78, 0x00, // 053  0x35  5
					0x38, 0x60, 0xC0, 0xF8, 0xCC, 0xCC, 0x78, 0x00, // 054  0x36  6
					0xFC, 0xCC, 0x0C, 0x18, 0x30, 0x30, 0x30, 0x00, // 055  0x37  7
					0x78, 0xCC, 0xCC, 0x78, 0xCC, 0xCC, 0x78, 0x00, // 056  0x38  8
					0x78, 0xCC, 0xCC, 0x7C, 0x0C, 0x18, 0x70, 0x00, // 057  0x39  9
					0x38, 0x6C, 0x64, 0xF0, 0x60, 0x60, 0xF0, 0x00, // 102  0x66  f
					0x00, 0x00, 0xDC, 0x66, 0x66, 0x7C, 0x60, 0xF0, // 112  0x70  p
					0x00, 0x00, 0x7C, 0xC0, 0x70, 0x1C, 0xF8, 0x00, // 115  0x73  s
				],
				[	[32, 32], // space
					[48, 57], // 0-9
					[102, 102], // f
					[112, 112], // p
					[115, 115], // s
				]				
			),
			{
				fgColor:0xc9f027ff,
				letterSpace:0,
				letterWidth: size,
				letterHeight: size
			}
		);

		textProgram.add(new Text(size*3, 4, " fps ", {fgColor:0xa4e030f5}));

		fpsText = new Text(0, 4, ((peoteView.window.frameRate<10) ? "  " : ( (peoteView.window.frameRate<100) ? " " : "" )) + peoteView.window.frameRate);
		textProgram.add(fpsText);
		
		addProgram(textProgram);
		lastTime = Timer.stamp();
	}

	var lastTime:Float = 0;
	var frameCount:Int = 0;

	inline function step()
	{	
		var t = Timer.stamp() - lastTime;
		if (t >= 1.0)
		{
			#if html5 
			frameCount = Std.int((frameCount+1.1)/t);
			#else
			frameCount = Std.int((frameCount)/t);
			#end

			color = Color.mix(0x540804ea, 0x104407ea, Math.min(1.0,frameCount/60));

			fpsText.text = ((frameCount<10) ? "  " : ( (frameCount<100) ? " " : "" )) + frameCount;
			textProgram.updateText(fpsText);

			lastTime += t;
			frameCount = 0;
		}
		else frameCount++;
	}

}
