# Peote View - 2D Render Library (haxe/lime/opengl)

This library is to simplify opengl-usage for 2D rendering and to easy  
handle procedural shadercode and imagedata from texture-atlases.
  
It's written in [Haxe](http://haxe.org) and runs multiplatform with [Lime](https://github.com/openfl/lime)s [GL-context](https://github.com/openfl/lime/tree/develop/src/lime/graphics/opengl) and environment.  


## Installation
by [haxelib](https://lib.haxe.org) -> [peote-view](https://lib.haxe.org/p/peote-view/)
```
haxelib install peote-view
```
  
or use the latest developement version by:
```
haxelib git peote-view https://github.com/maitag/peote-view
```


## Samples

start here: [peote-view-samples](https://github.com/maitag/peote-view-samples) to test out some core features  
or [play](http://maitag.de/~half/peote-playground/) around into: [peote-playground](https://github.com/maitag/peote-playground)  
  
You can test some of them also [here](http://maitag.de/semmi/haxelime/peote-view-remaster/?C=M;O=D).  
  

## API

is still [work in progress](http://maitag.de/semmi/haxelime/peote-view-api/)
(can be generated locally by [Dox](https://lib.haxe.org/p/dox/) and [generateAPIdoc.sh](https://github.com/maitag/peote-view/blob/master/generateAPIdoc.sh))


## Features

- runs native on linux/bsd/windows/android, neko/hashlink-vm, javascript-webbrowser
  (macOS and iOS should run but not much tested yet)  
- can be compiled for a special OpenGL version (ES 2/3 - webgl 1/2) or with version-detection at runtime
- optimized to draw many elements thats sharing the same shader and textures
- simple usage of textureatlases (parted into slots and tiles)
- multitexture usage per shader
- supports shadertemplates and opengl-extensions
- simple formula- and glslcode-injection
- animation by gpu transition-rendering of vertexattributes
- opengl-picking for fast detection of elements that hits a point at screen
- renderToTextures (framebuffer)
- easy to interpolate element attributes over time (linear) e.g. for particleanimation


## Scenegraph and Namespace

![scenegraph](doc/PeoteView.png?raw=true)

`PeoteView`
- main screenarea that contains all Displays
- zoom- and scrollable


`Display`
- rectangle area inside the View (using gl-scissoring for masking)
- contains Programs to render
- zoom- and scrollable
- content can be rendered into a texture

	  
`Element`
- rectangle graphics like Sprites
- can have position, size and many other kind of attributes to render inside displayarea
- different types of Element-classes with rquivalent shadertemplate is macro-generated by meta-data
- only properties/shaderattribures that is need will be generated (to have optimized types of Elements for any purpose)


`Buffer<Element>`
- depends on type of generated Element
- stores many Element-instances to build up an equivalent gl-vertexbuffer
- can be dynamically grow/shrink
- using fast opengl instance-drawing for all contained Elements
- can be bind to one or many Programs 


`Program`
- combines Textures and shadercode for one Buffer
- can use formulas for fragmentshader to compose Texturedata 
- can use formulas to change other attributes inside shader
- can inject GLSL-code directly into shader


`Texture`
- represents the opengl-texture what is used by the shader program
- supports multiple amount of colorchannels (by `TextureFormat`) and can be filled by `TextureData`
- can be splitted into Slots to store many texture data at once
- can calculates best size for gl-texture (also into power-of-two size)
- slots can be parted into tiles for textureatlases
- supports mipmapping and min/mag filtering


`TextureData`
- stores imagedata into different `TextureFormat`s
- automatically converts lime image or some other libs data
- can be used to set or get pixel colors
- converts from and to different textureformats (e.g. RGBA into RGB etc)


`TextureCache`
- handle multiple textures, imageloading and texture reusage





## Todo
- better documentation (more readmes for each part)
- multiwindows (did not work with textures yet)