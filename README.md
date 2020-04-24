# Peote View - 2D OpenGL Render Library

This library is to simplify opengl-usage for 2D rendering and to  
easy handle procedural shadercode and imagedata from texture-atlases.
  
It's written in [Haxe](http://haxe.org) and runs multiplatform with  
[Limes](https://github.com/openfl/lime) GL-context and environment.  

## Installation:
```
haxelib git peote-view https://github.com/maitag/peote-view
```


## Features

- multiplatform: nativ on linux, windows, macOS, android and iOS, js inside webbrowser, neko/hashlink vm
- can be compiled to use OpenGL ES 2 or 3 version (or with detection at runtime)
  
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