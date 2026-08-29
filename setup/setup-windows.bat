echo Installing dependencies...
haxelib install lime --quiet
haxelib install openfl --quiet
haxelib install flixel --skip-dependencies --quiet
haxelib install flixel-addons --skip-dependencies --quiet
haxelib install flixel-tools --quiet
haxelib install flixel-ui --quiet
haxelib install hscript-iris --quiet
haxelib install hxcpp-debug-server --quiet
haxelib install hxdiscord_rpc --skip-dependencies --quiet
haxelib install hxvlc --skip-dependencies --quiet
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit master
haxelib install extension-androidtools --skip-dependencies --quiet
haxelib install hxgamemode --skip-dependencies --quiet
haxelib git hxcpp https://github.com/FunkinCrew/hxcpp 82b5bb7913e2eb8d9e8141da0dd8cd3bdc3f16c5
haxelib install hxp --quiet
haxelib install format --quiet
echo Finished!
pause