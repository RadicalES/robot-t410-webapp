@echo off

REM set variables
set _CURR_DIR=%cd%
REM set _ISP="c:\Program Files (x86)\Atmel\Flip 3.4.5\bin\batchisp.exe"
set _TOOL="C:\ti\simplelink_msp432e4_sdk_4_20_00_12\source\ti\ndk\tools\binsrc\binsrc.exe"
set _DEST="d:\Development\ccs\workspace\robots\robot-t202\resfw\filesystem\static"

%_TOOL% index.html %_DEST%\index_html.c INDEX_HTML
%_TOOL% output\jx.js %_DEST%\jx_js.c JX_JS
%_TOOL% output\robot.js %_DEST%\robot_js.c ROBOT_JS
%_TOOL% robot.png %_DEST%\robot_png.c ROBOT_PNG
%_TOOL% site.css %_DEST%\site_css.c SITE_CSS
%_TOOL% w3.css %_DEST%\w3_css.c W3_CSS
%_TOOL% favicon.png %_DEST%\favicon_png.c FAVICON_PNG
%_TOOL% output\validation.js %_DEST%\validation_js.c VALIDATION_JS
