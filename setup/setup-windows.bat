echo Installing dependencies...
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-tools
haxelib install flixel-ui
haxelib install hscript-iris
haxelib install hxcpp-debug-server
haxelib install hxdiscord_rpc --skip-dependencies
haxelib install hxvlc --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit master
haxelib install extension-androidtools
haxelib install hxgamemode
haxelib git astc-compressor https://github.com/KarimAkra/astc-compressor main
echo Finished!
pause