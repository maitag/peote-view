# Peote View - 2D Render Library (haxe/lime/opengl)

This library is to simplify opengl-usage for 2D rendering and to easy  
handle procedural shadercode and imagedata from texture-atlases.
  
It's written in [Haxe](http://haxe.org) and runs multiplatform with [Lime](https://github.com/haxelime/lime)s [GL-context](https://github.com/haxelime/lime/tree/develop/src/lime/graphics/opengl) and environment.  

## Installation:
```
haxelib git peote-view https://github.com/maitag/peote-view
```


## Features

- runs native on linux/bsd/windows/android, neko/hashlink-vm, javascript-webbrowser
  (macOS and iOS should run but not much tested yet)  
- can be compiled for a special OpenGL version (ES 2/3 - webgl 1/2) or with version-detection at runtime
  
- optimized to draw many elements thats sharing the same shader and textures
- simple usage of textureatlases (parted into slots and tiles)
- supports shadertemplates and opengl-extensions
- simple formula- and glslcode-injection
- animation by gpu transition-rendering of vertexatrributes
- ...


(todo)




## Todo
- documentation
- custom uniforms per program
- better texture/imagehandling and more texture-colortypes
- z-depth via texture-channel
- uv-mapping
- multiwindows (did not work with textures yet)