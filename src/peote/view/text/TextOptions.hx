package peote.view.text;

import peote.view.Color;

@:structInit
@:publicFields
class TextOptions {
	@:optional var fgColor:Color;
	@:optional var bgColor:Color;
	@:optional var letterWidth:Int;
	@:optional var letterHeight:Int;
	@:optional var letterSpace:Int;
	@:optional var lineSpace:Int;
	@:optional var zIndex:Int;

	public function copyNotNullValuesTo(options:TextOptions) {
		if (fgColor != null) options.fgColor = fgColor;
		if (bgColor != null) options.bgColor = bgColor;
		if (letterWidth != null) options.letterWidth = letterWidth;
		if (letterHeight != null) options.letterHeight = letterHeight;
		if (letterSpace != null) options.letterSpace = letterSpace;
		if (lineSpace != null) options.lineSpace = lineSpace;
		if (zIndex != null) options.zIndex = zIndex;
	}

	public function copy():TextOptions {
		return {
			fgColor:fgColor,
			bgColor:bgColor,
			letterWidth:letterWidth,
			letterHeight:letterHeight,
			letterSpace:letterSpace,
			lineSpace:lineSpace,	
			zIndex:zIndex	
		};
	}
}