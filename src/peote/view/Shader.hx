package peote.view;

class Shader 
{
	// -------------------------- VERTEX SHADER TEMPLATE --------------------------------	
	@:allow(peote.view) static var vertexShader(default, null):String =
	
	
	"
	::if isES3::#version 300 es::end::
	
	// Uniforms -------------------------
	::if isUBO::
	layout(std140) uniform uboView
	{
		vec2 uResolution;
		vec2 uViewOffset;
		float uViewZoom;
	};
	layout(std140) uniform uboDisplay
	{
		vec2 uOffset;
		float uZoom;
	};
	::else::
	uniform vec2 uResolution;
	uniform vec2 uOffset;
	uniform float uZoom;
	::end::
	
	// Attributes -------------------------
	::IN:: vec2 aPosition;
	
	::if (isSIZE_X || isSIZE_Y)::
		::IN:: ::SIZE_TYPE:: aSize;
	::end::
	
	::if (isPOS_X || isPOS_Y)::
		::IN:: ::POS_TYPE:: aPos;
	::end::
	
	//aPivot
	//aRotation
	//aColor
	//aElement
	//aTexCoord
	//aTile
	//aZindex
	//aTime
	
	//aCustom0
	
	
	// custom Attributes ------------------

	// PICKING  ::if isES3:: flat out int instanceID; ::end::
	
	void main(void) {

		::if (isSIZE_X && isSIZE_Y):: vec2 size = aPosition * aSize;
		::elseif (isSIZE_X)::         vec2 size = aPosition * vec2(aSize, ::SIZE_CONST_Y::);
		::elseif (isSIZE_Y)::         vec2 size = aPosition * vec2(::SIZE_CONST_X::, aSize);
		::else::                      vec2 size = aPosition * vec2(::SIZE_CONST_X::, SIZE_CONST_Y::);
		::end::
		/*
		::if (isSIZE_ANIM)::
			::if (isSIZE_1_X && isSIZE_1_Y):: vec2 size1 = aPosition * aSize1;
			::elseif (isSIZE_1_X)::           vec2 size1 = aPosition * vec2(aSize1, ::SIZE_1_CONST_Y::);
			::elseif (isSIZE_1_Y)::           vec2 size1 = aPosition * vec2(::SIZE_1_CONST_X::, aSize1);
			::else::                          vec2 size1 = aPosition * vec2(::SIZE_1_CONST_X::, SIZE_1_CONST_Y::);
			::end::
						
			float timeStep = max( 0.0, min( (uTime-aTime.x) / (aTime.y - aTime.x), 1.0)); // todo: use clamp !
			size = size + (size1 - size) * timeStep;
		::end::
		*/		
		::if (isPOS_X && isPOS_Y):: vec2 pos = size + aPos;
		::elseif (isPOS_X)::        vec2 pos = size + vec2(aPos, ::POS_CONST_Y::);
		::elseif (isPOS_Y)::        vec2 pos = size + vec2(::POS_CONST_X::, aPos);
		::else::                    vec2 pos = size + vec2(::POS_CONST_X::, ::POS_CONST_Y::);
		::end::
		
		// PICKING instanceID = gl_InstanceID;
		
		float zoom = uZoom ::if isUBO:: * uViewZoom ::end::;
		float width = uResolution.x;
		float height = uResolution.y;
		::if isUBO::
		float deltaX = (uOffset.x  + uViewOffset.x) / uZoom;
		float deltaY = (uOffset.y  + uViewOffset.y) / uZoom;
		::else::
		float deltaX = uOffset.x;
		float deltaY = uOffset.y;
		::end::
		
		float right = width-deltaX*zoom;
		float left = -deltaX*zoom;
		float bottom = height-deltaY*zoom;
		float top = -deltaY * zoom;
			
		gl_Position = mat4 (
			vec4(2.0 / (right - left)*zoom, 0.0, 0.0, 0.0),
			vec4(0.0, 2.0 / (top - bottom)*zoom, 0.0, 0.0),
			vec4(0.0, 0.0, -1.0, 0.0),
			vec4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), 0.0, 1.0)
		)
		* vec4 (pos ,
			0.0
			, 1.0
			);
	}
	";
	
	
	
	// ------------------------ FRAGMENT SHADER TEMPLATE --------------------------------	
	@:allow(peote.view) static var fragmentShader(default, null):String =	

	
	"
	::if isES3::#version 300 es::end::
	
    precision highp float;
	
	::if isES3::
	flat in int instanceID;
	out vec4 color;
	// PICKING out int color;
	::end::

	
	void main(void)
	{	
		::if isES3::color::else::gl_FragColor::end:: = vec4 (1.0, 0.0, 0.0, 1.0);
		// PICKING ::if isES3::color::else::gl_FragColor::end:: =  instanceID*50;
	}
	";

	
	
	
	
}