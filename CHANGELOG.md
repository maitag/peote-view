Changelog
=========

1.05 (08/26/2025)
-----------------
* compiler define (`peoteview_fps`) option to enable visualization of the rendertime (per second .)
* Fixing bug in View and Display while set up the colors, also each colorchannel is avail at now by Float
* Added `HSV` and `HSL` colorspace functions to Color.hx
* Added `mix` and `rnd` function spice to Color.hx
* Changed `Program`s function name `updateTextures()` into `update()` (updates texture-changes automatic or by argument)
* Added element iterator to `Buffer` to use loops like: `for (element in buffer)`


1.04 (12/31/2024)
-----------------
* Fixed bug in `Element` generation where getter/setter not work if no default value is set
* Added feature `peote.view.text.TextProgram` to easy create text by using embedded bitmap font
* `vTexCoord` is also accessable now if its only used inside a programs ColorFormula


1.03 (09/28/2024)
-----------------
* Added `dispose()` for 'Texture' to free opengl-ram
* Added feature that the texture-layer identifier can be optional now while set, add or remove textures to a `Program`
* Fixed (partial) old glitch with lanugage-server cache and macros, where into this case the Buffer-macro checks that the type was not already generated
* Fixed Element-generation into case where only use of @posY, @sizeY or @pivotY as alternative Float Datatype


1.02 (06/12/2024)
-----------------
* Added `public` for the `.fbTexture` to make it read-access for Framebuffer-`Display`s
* Fixed `FBO/float-Texture` glitch where gl-EXT_color_buffer_float/OES_texture_float-extension was not set in time


1.01 (05/01/2024)
-----------------
* Added optional param for `Color.random(?alpha:Int)` and `randomize(?alpha:Int)`
* Completed inline documentation and DOX-API
* Completed `TextureData` functions for converting `TextureFormat`s
* Fixed `Texture` glitch while setting up the slots
* Fixed `TextureCache` and renamed `setImage()` into `setData()`
