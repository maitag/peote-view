package peote.view.text;

import peote.view.Color;

@:structInit
@:publicFields
class TextOptions {
	var fgColor:Null<Color> = null;
	var bgColor:Null<Color> = null;
	var letterWidth:Null<Int> = null;
	var letterHeight:Null<Int> = null;
	var letterSpace:Null<Int> = null;
	var lineSpace:Null<Int> = null;
	var zIndex:Null<Int> = null;

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