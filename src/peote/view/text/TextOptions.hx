package peote.view.text;

import peote.view.Color;

/**
	This struct is to configure the properties of `Text` and `TextProgram` instances.
**/
@:structInit
@:publicFields
class TextOptions {
	/** foreground color **/
	var fgColor:Null<Color> = null;

	/** background color **/
	var bgColor:Null<Color> = null;

	/** width of each letter **/
	var letterWidth:Null<Int> = null;

	/** height of each letter **/
	var letterHeight:Null<Int> = null;

	/** horizontal space between letters in pixel **/
	var letterSpace:Null<Int> = null;

	/** space between lines in pixel **/
	var lineSpace:Null<Int> = null;

	/** z-depth index **/
	var zIndex:Null<Int> = null;

	/**
		Copy all non-null values of this instance to the values of another instance.
		@param options destination options where to copy from this
	**/
	public function copyNotNullValuesTo(options:TextOptions) {
		if (fgColor != null) options.fgColor = fgColor;
		if (bgColor != null) options.bgColor = bgColor;
		if (letterWidth != null) options.letterWidth = letterWidth;
		if (letterHeight != null) options.letterHeight = letterHeight;
		if (letterSpace != null) options.letterSpace = letterSpace;
		if (lineSpace != null) options.lineSpace = lineSpace;
		if (zIndex != null) options.zIndex = zIndex;
	}

	/**
		Returns a new instance with copyed values.
	**/
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